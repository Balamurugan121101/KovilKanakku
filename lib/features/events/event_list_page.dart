import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../models/event_model.dart';
import '../../../repositories/event_repository.dart';

class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() =>
      _EventListPageState();
}

class _EventListPageState
    extends State<EventListPage> {
  final EventRepository _repository =
  EventRepository();

  List<EventModel> events = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final result =
      await _repository.getEvents();

      if (!mounted) return;

      setState(() {
        events = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  Future<void> _refreshEvents() async {
    setState(() {
      isLoading = true;
    });

    await _loadEvents();
  }

  Future<void> _addEvent() async {
    await context.push(
      AppRoutes.eventAdd,
    );

    if (mounted) {
      _loadEvents();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue;

      case 'ongoing':
        return Colors.green;

      case 'completed':
        return Colors.grey;

      case 'cancelled':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Events',
        ),
      ),

      floatingActionButton:
      FloatingActionButton(
        onPressed: _addEvent,
        child: const Icon(
          Icons.add,
        ),
      ),

      body: isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : events.isEmpty
          ? RefreshIndicator(
        onRefresh: _refreshEvents,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(
              height: 180,
            ),
            Center(
              child: Text(
                'No events found',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _refreshEvents,
        child: ListView.builder(
          padding:
          const EdgeInsets.all(12),
          itemCount: events.length,
          itemBuilder:
              (context, index) {
            final event =
            events[index];

            return _eventCard(
              event,
            );
          },
        ),
      ),
    );
  }

  Widget _eventCard(
      EventModel event,
      ) {
    final statusColor =
    _statusColor(event.status);

    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 8,
      ),

      child: InkWell(
        borderRadius:
        BorderRadius.circular(12),

        onTap: () async {
          await context.push(
            AppRoutes.eventDetails,
            extra: event,
          );

          if (mounted) {
            _loadEvents();
          }
        },

        child: Padding(
          padding:
          const EdgeInsets.all(14),

          child: Row(
            children: [
              // Date
              Container(
                width: 55,
                padding:
                const EdgeInsets.symmetric(
                  vertical: 8,
                ),

                decoration:
                BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(8),
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                ),

                child: Column(
                  children: [
                    Text(
                      event.date.day
                          .toString(),
                      style:
                      const TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    Text(
                      _monthName(
                        event.date.month,
                      ),
                      style:
                      const TextStyle(
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              // Event information
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      event.name,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,

                      style:
                      const TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey,
                        ),

                        const SizedBox(
                          width: 3,
                        ),

                        Expanded(
                          child: Text(
                            event.location,
                            maxLines: 1,
                            overflow:
                            TextOverflow
                                .ellipsis,
                            style:
                            const TextStyle(
                              fontSize: 12,
                              color:
                              Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),

                      decoration:
                      BoxDecoration(
                        color: statusColor
                            .withOpacity(
                          0.1,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(20),
                      ),

                      child: Text(
                        event.status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                          FontWeight.w600,
                          color:
                          statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(
      int month,
      ) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return months[month - 1];
  }
}
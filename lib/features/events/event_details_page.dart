import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../models/event_model.dart';
import '../../../repositories/event_repository.dart';

class EventDetailsPage extends StatefulWidget {
  const EventDetailsPage({
    super.key,
    required this.event,
  });

  final EventModel event;

  @override
  State<EventDetailsPage> createState() =>
      _EventDetailsPageState();
}

class _EventDetailsPageState
    extends State<EventDetailsPage> {
  final EventRepository _repository =
  EventRepository();

  late EventModel event;

  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    event = widget.event;
  }

  // --------------------------------------------------
  // DATE FORMAT
  // --------------------------------------------------

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatDay(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[date.weekday - 1];
  }

  // --------------------------------------------------
  // STATUS COLOR
  // --------------------------------------------------

  Color _statusColor() {
    switch (event.status.toLowerCase()) {
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

  // --------------------------------------------------
  // EDIT
  // --------------------------------------------------

  Future<void> _editEvent() async {
    final updatedEvent =
    await context.push<EventModel>(
      AppRoutes.eventEdit,
      extra: event,
    );

    if (updatedEvent != null && mounted) {
      setState(() {
        event = updatedEvent;
      });
    }
  }

  // --------------------------------------------------
  // DELETE
  // --------------------------------------------------

  Future<void> _deleteEvent() async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Event',
          ),
          content: Text(
            'Are you sure you want to delete '
                '"${event.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'CANCEL',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'DELETE',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _deleting = true;
    });

    try {
      await _repository.deleteEvent(
        event.id,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Event deleted successfully',
          ),
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _deleting = false;
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

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Details',
        ),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed:
            _deleting ? null : _editEvent,
            icon: const Icon(
              Icons.edit,
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            onPressed:
            _deleting ? null : _deleteEvent,
            icon: const Icon(
              Icons.delete_outline,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ========================================
              // EVENT SUMMARY CARD
              // ========================================

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            child: const Icon(
                              Icons.event,
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              event.name,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                            child: Text(
                              event.status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (event.description
                          .trim()
                          .isNotEmpty) ...[
                        const SizedBox(height: 12),

                        const Divider(height: 1),

                        const SizedBox(height: 10),

                        Text(
                          event.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.3,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ========================================
              // DATE
              // ========================================

              _infoCard(
                icon:
                Icons.calendar_today,
                title: 'Date',
                value:
                '${_formatDate(event.date)}'
                    ' • '
                    '${_formatDay(event.date)}',
              ),

              // ========================================
              // LOCATION
              // ========================================

              _infoCard(
                icon: Icons.location_on,
                title: 'Location',
                value: event.location,
              ),

              const SizedBox(
                height: 20,
              ),

              // ========================================
              // EDIT BUTTON
              // ========================================

              SizedBox(
                width: double.infinity,
                height: 48,
                child:
                OutlinedButton.icon(
                  onPressed: _deleting
                      ? null
                      : _editEvent,
                  icon: const Icon(
                    Icons.edit,
                  ),
                  label: const Text(
                    'EDIT EVENT',
                  ),
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              // ========================================
              // DELETE BUTTON
              // ========================================

              SizedBox(
                width: double.infinity,
                height: 48,
                child:
                OutlinedButton.icon(
                  onPressed: _deleting
                      ? null
                      : _deleteEvent,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  label: const Text(
                    'DELETE EVENT',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // INFO CARD
  // --------------------------------------------------

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 4,
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
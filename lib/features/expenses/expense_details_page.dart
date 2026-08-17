import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../models/event_model.dart';
import '../../../models/expense_model.dart';
import '../../../providers/event_provider.dart';

class ExpenseDetailsPage
    extends ConsumerWidget {
  const ExpenseDetailsPage({
    super.key,
    required this.expense,
  });

  final ExpenseModel expense;

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final formattedDate =
    DateFormat('dd MMM yyyy')
        .format(expense.date);

    final formattedCreatedAt =
    DateFormat('dd MMM yyyy, hh:mm a')
        .format(expense.createdAt);

    final eventAsync =
    expense.eventId == null ||
        expense.eventId!.isEmpty
        ? null
        : ref.watch(
      eventByIdProvider(
        expense.eventId!,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Details',
        ),

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
          ),

          onPressed: () {
            context.pop();
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // ======================================
            // AMOUNT CARD
            // ======================================

            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(24),

                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 30,

                      child: Icon(
                        Icons.money_off,
                        size: 30,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const Text(
                      'Expense Amount',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      NumberFormat.currency(
                        locale: 'en_IN',
                        symbol: '₹ ',
                        decimalDigits: 2,
                      ).format(
                        expense.amount,
                      ),

                      style:
                      const TextStyle(
                        fontSize: 30,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            // ======================================
            // DETAILS
            // ======================================

            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(16),

                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons
                          .description_outlined,
                      label: 'Description',
                      value:
                      expense.description,
                    ),

                    const Divider(),

                    _DetailRow(
                      icon: Icons
                          .category_outlined,
                      label: 'Category',
                      value:
                      expense.category,
                    ),

                    const Divider(),

                    // ==================================
                    // EVENT
                    // ==================================

                    _EventDetailRow(
                      eventAsync: eventAsync,
                    ),

                    const Divider(),

                    _DetailRow(
                      icon: Icons
                          .calendar_today_outlined,
                      label: 'Expense Date',
                      value: formattedDate,
                    ),

                    if (expense.notes != null &&
                        expense.notes!
                            .trim()
                            .isNotEmpty) ...[
                      const Divider(),

                      _DetailRow(
                        icon: Icons
                            .notes_outlined,
                        label: 'Notes',
                        value:
                        expense.notes!,
                      ),
                    ],

                    const Divider(),

                    _DetailRow(
                      icon:
                      Icons.access_time,
                      label: 'Created',
                      value:
                      formattedCreatedAt,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================================================
// EVENT ROW
// ==================================================

class _EventDetailRow
    extends StatelessWidget {
  const _EventDetailRow({
    required this.eventAsync,
  });

  final AsyncValue<EventModel?>?
  eventAsync;

  @override
  Widget build(BuildContext context) {
    if (eventAsync == null) {
      return const _DetailRow(
        icon: Icons.event_outlined,
        label: 'Event',
        value: 'General / No Event',
      );
    }

    return eventAsync!.when(
      loading: () {
        return const Padding(
          padding:
          EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: Row(
            children: [
              Icon(
                Icons.event_outlined,
                size: 22,
              ),
              SizedBox(width: 12),
              Text(
                'Loading event...',
              ),
            ],
          ),
        );
      },

      error: (_, __) {
        return const _DetailRow(
          icon: Icons.event_outlined,
          label: 'Event',
          value: 'Event not found',
        );
      },

      data: (event) {
        return _DetailRow(
          icon: Icons.event_outlined,
          label: 'Event',
          value:
          event?.name ??
              'Event not found',
        );
      },
    );
  }
}

// ==================================================
// DETAIL ROW
// ==================================================

class _DetailRow
    extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Padding(
      padding:
      const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            size: 22,
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  label,
                  style:
                  const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  value,
                  style:
                  const TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
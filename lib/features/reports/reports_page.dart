import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../providers/report_provider.dart';
import '../../../repositories/settings_repository.dart';
import '../../../services/report_pdf_service.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() =>
      _ReportPageState();
}

class _ReportPageState
    extends ConsumerState<ReportPage> {
  ReportPeriod selectedPeriod =
      ReportPeriod.thisMonth;

  String? selectedEventId;

  DateTime? customStart;
  DateTime? customEnd;

  // ------------------------------------------------------------
  // FILTER
  // ------------------------------------------------------------

  ReportFilter get currentFilter {
    return ReportFilter(
      period: selectedPeriod,
      customStart: customStart,
      customEnd: customEnd,
      eventId: selectedEventId,
    );
  }

  // ------------------------------------------------------------
  // DATE PICKER
  // ------------------------------------------------------------

  Future<void> _selectCustomDateRange() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange:
      customStart != null &&
          customEnd != null
          ? DateTimeRange(
        start: customStart!,
        end: customEnd!,
      )
          : DateTimeRange(
        start: DateTime(
          now.year,
          now.month,
          1,
        ),
        end: now,
      ),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      customStart = picked.start;
      customEnd = picked.end;
    });
  }

  // ------------------------------------------------------------
  // EXPORT PDF
  // ------------------------------------------------------------

  Future<void> _exportPdf(
      ReportData report,
      ) async {
    try {
      final settings =
      await SettingsRepository()
          .getSettings();

      if (settings == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Temple settings not found',
            ),
          ),
        );

        return;
      }

      String? eventName;

      // --------------------------------------------------------
      // Get selected event name
      // --------------------------------------------------------

      if (selectedEventId != null &&
          selectedEventId!.isNotEmpty) {
        final eventDoc =
        await FirebaseFirestore
            .instance
            .collection('temples')
            .doc('temple001')
            .collection('events')
            .doc(selectedEventId)
            .get();

        if (eventDoc.exists) {
          final data =
          eventDoc.data();

          eventName =
              data?['name']?.toString();
        }
      }

      // --------------------------------------------------------
      // Generate PDF
      // --------------------------------------------------------

      final pdfBytes =
      await ReportPdfService
          .generateReport(
        report: report,
        filter: currentFilter,
        settings: settings,
        eventName: eventName,
      );

      if (!mounted) return;

      context.push(
        AppRoutes.reportPreview,
        extra: pdfBytes,
      );
    } catch (e) {
      if (!mounted) return;

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

  // ------------------------------------------------------------
  // PERIOD LABEL
  // ------------------------------------------------------------

  String _periodLabel(
      ReportPeriod period,
      ) {
    switch (period) {
      case ReportPeriod.today:
        return 'Today';

      case ReportPeriod.thisWeek:
        return 'This Week';

      case ReportPeriod.thisMonth:
        return 'This Month';

      case ReportPeriod.thisYear:
        return 'This Year';

      case ReportPeriod.custom:
        return 'Custom';
    }
  }

  // ------------------------------------------------------------
  // CURRENCY
  // ------------------------------------------------------------

  String _currency(double value) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 2,
    ).format(value);
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final reportAsync =
    ref.watch(
      reportProvider(
        currentFilter,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reports',
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            reportProvider(
              currentFilter,
            ),
          );

          await ref.read(
            reportProvider(
              currentFilter,
            ).future,
          );
        },

        child: ListView(
          padding:
          const EdgeInsets.all(16),

          children: [
            // ==================================================
            // PERIOD
            // ==================================================

            DropdownButtonFormField<
                ReportPeriod>(
              initialValue:
              selectedPeriod,

              decoration:
              const InputDecoration(
                labelText: 'Period',
                prefixIcon: Icon(
                  Icons.calendar_month_outlined,
                ),
              ),

              items: ReportPeriod.values
                  .map(
                    (period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(
                      _periodLabel(
                        period,
                      ),
                    ),
                  );
                },
              ).toList(),

              onChanged: (value) {
                if (value == null) {
                  return;
                }

                setState(() {
                  selectedPeriod = value;
                });

                if (value ==
                    ReportPeriod.custom) {
                  _selectCustomDateRange();
                }
              },
            ),

            // ==================================================
            // CUSTOM DATE RANGE
            // ==================================================

            if (selectedPeriod ==
                ReportPeriod.custom) ...[
              const SizedBox(height: 12),

              InkWell(
                onTap:
                _selectCustomDateRange,

                borderRadius:
                BorderRadius.circular(12),

                child: InputDecorator(
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Date Range',
                    prefixIcon: Icon(
                      Icons.date_range,
                    ),
                  ),

                  child: Text(
                    customStart != null &&
                        customEnd != null
                        ? '${DateFormat('dd MMM yyyy').format(customStart!)}'
                        ' - '
                        '${DateFormat('dd MMM yyyy').format(customEnd!)}'
                        : 'Select date range',
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // ==================================================
            // EVENT
            // ==================================================

            _EventDropdown(
              selectedEventId:
              selectedEventId,

              onChanged: (value) {
                setState(() {
                  selectedEventId =
                      value;
                });
              },
            ),

            const SizedBox(height: 20),

            // ==================================================
            // REPORT
            // ==================================================

            reportAsync.when(
              loading: () {
                return const Padding(
                  padding:
                  EdgeInsets.only(
                    top: 80,
                  ),

                  child: Center(
                    child:
                    CircularProgressIndicator(),
                  ),
                );
              },

              error: (error, stack) {
                return _ErrorCard(
                  message:
                  error.toString(),
                  onRetry: () {
                    ref.invalidate(
                      reportProvider(
                        currentFilter,
                      ),
                    );
                  },
                );
              },

              data: (report) {
                return Column(
                  children: [
                    // ------------------------------------------
                    // DONATIONS
                    // ------------------------------------------

                    _SummaryCard(
                      title:
                      'Total Donations',
                      value:
                      _currency(
                        report
                            .totalDonations,
                      ),
                      icon:
                      Icons
                          .volunteer_activism,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ------------------------------------------
                    // EXPENSES
                    // ------------------------------------------

                    _SummaryCard(
                      title:
                      'Total Expenses',
                      value:
                      _currency(
                        report
                            .totalExpenses,
                      ),
                      icon:
                      Icons
                          .money_off,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    // ------------------------------------------
                    // BALANCE
                    // ------------------------------------------

                    _SummaryCard(
                      title:
                      'Balance',
                      value:
                      _currency(
                        report.balance,
                      ),
                      icon:
                      Icons.account_balance,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ------------------------------------------
                    // TRANSACTIONS
                    // ------------------------------------------

                    Card(
                      child: Padding(
                        padding:
                        const EdgeInsets.all(
                          16,
                        ),

                        child: Column(
                          children: [
                            const Align(
                              alignment:
                              Alignment
                                  .centerLeft,
                              child: Text(
                                'Transactions',
                                style:
                                TextStyle(
                                  fontSize:
                                  17,
                                  fontWeight:
                                  FontWeight
                                      .bold,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 12,
                            ),

                            _TransactionRow(
                              icon: Icons
                                  .volunteer_activism,
                              label:
                              'Donations',
                              value:
                              report
                                  .donationCount
                                  .toString(),
                            ),

                            const Divider(),

                            _TransactionRow(
                              icon: Icons
                                  .receipt_long,
                              label:
                              'Expenses',
                              value:
                              report
                                  .expenseCount
                                  .toString(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ------------------------------------------
                    // EXPORT PDF
                    // ------------------------------------------

                    SizedBox(
                      width:
                      double.infinity,
                      height: 50,

                      child:
                      ElevatedButton.icon(
                        onPressed: () {
                          _exportPdf(
                            report,
                          );
                        },

                        icon: const Icon(
                          Icons
                              .picture_as_pdf,
                        ),

                        label: const Text(
                          'EXPORT PDF',
                          style:
                          TextStyle(
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// EVENT DROPDOWN
// ===============================================================

class _EventDropdown
    extends StatelessWidget {
  const _EventDropdown({
    required this.selectedEventId,
    required this.onChanged,
  });

  final String? selectedEventId;

  final ValueChanged<String?>
  onChanged;

  @override
  Widget build(
      BuildContext context,
      ) {
    return StreamBuilder<
        QuerySnapshot<
            Map<String, dynamic>>>(
      stream: FirebaseFirestore
          .instance
          .collection('temples')
          .doc('temple001')
          .collection('events')
          .orderBy('name')
          .snapshots(),

      builder:
          (context, snapshot) {
        if (snapshot.hasError) {
          return InputDecorator(
            decoration:
            const InputDecoration(
              labelText: 'Event',
              prefixIcon: Icon(
                Icons.event_outlined,
              ),
            ),

            child: Text(
              'Unable to load events',
              style: TextStyle(
                color:
                Theme.of(context)
                    .colorScheme
                    .error,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const InputDecorator(
            decoration:
            InputDecoration(
              labelText: 'Event',
              prefixIcon: Icon(
                Icons.event_outlined,
              ),
            ),

            child: SizedBox(
              height: 20,

              child: Align(
                alignment:
                Alignment.centerLeft,

                child:
                SizedBox(
                  width: 18,
                  height: 18,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          );
        }

        final events =
            snapshot.data!.docs;

        final validSelectedId =
        events.any(
              (doc) =>
          doc.id ==
              selectedEventId,
        )
            ? selectedEventId
            : null;

        return DropdownButtonFormField<
            String?>(
          initialValue:
          validSelectedId,

          decoration:
          const InputDecoration(
            labelText: 'Event',
            prefixIcon: Icon(
              Icons.event_outlined,
            ),
          ),

          items: [
            const DropdownMenuItem<
                String?>(
              value: null,
              child: Text(
                'All Events',
              ),
            ),

            ...events.map(
                  (doc) {
                final data =
                doc.data();

                return DropdownMenuItem<
                    String?>(
                  value: doc.id,

                  child: Text(
                    data['name']
                        ?.toString() ??
                        'Unnamed Event',
                    overflow:
                    TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ],

          onChanged:
          onChanged,
        );
      },
    );
  }
}

// ===============================================================
// SUMMARY CARD
// ===============================================================

class _SummaryCard
    extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(16),

        child: Row(
          children: [
            CircleAvatar(
              radius: 24,

              child: Icon(
                icon,
              ),
            ),

            const SizedBox(
              width: 14,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [
                  Text(
                    title,
                    style:
                    const TextStyle(
                      color:
                      Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    value,
                    style:
                    const TextStyle(
                      fontSize: 21,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// TRANSACTION ROW
// ===============================================================

class _TransactionRow
    extends StatelessWidget {
  const _TransactionRow({
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
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
        ),

        const SizedBox(
          width: 12,
        ),

        Expanded(
          child: Text(
            label,
          ),
        ),

        Text(
          value,
          style:
          const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// ERROR CARD
// ===============================================================

class _ErrorCard
    extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(20),

        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
            ),

            const SizedBox(
              height: 12,
            ),

            const Text(
              'Unable to load report',
              style:
              TextStyle(
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              message,
              textAlign:
              TextAlign.center,
              style:
              const TextStyle(
                fontSize: 12,
                color:
                Colors.grey,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            OutlinedButton(
              onPressed: onRetry,
              child:
              const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
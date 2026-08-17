import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../models/donation_model.dart';
import '../../../models/event_model.dart';
import '../../../models/settings_model.dart';
import '../../../repositories/event_repository.dart';
import '../../../repositories/settings_repository.dart';
import '../../services/receipt_service.dart';

class DonationDetailsPage extends ConsumerStatefulWidget {
  const DonationDetailsPage({
    super.key,
    required this.donation,
  });

  final DonationModel donation;

  @override
  ConsumerState<DonationDetailsPage> createState() =>
      _DonationDetailsPageState();
}

class _DonationDetailsPageState
    extends ConsumerState<DonationDetailsPage> {
  final EventRepository _eventRepository =
  EventRepository();

  final SettingsRepository _settingsRepository =
  SettingsRepository();

  EventModel? event;
  SettingsModel? settings;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // --------------------------------------------------
  // LOAD EVENT + SETTINGS
  // --------------------------------------------------

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _loadEvent(),
        _settingsRepository.getSettings(),
      ]);

      if (!mounted) return;

      setState(() {
        settings = results[1] as SettingsModel?;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load receipt details: '
                '${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  Future<EventModel?> _loadEvent() async {
    final eventId = widget.donation.eventId;

    if (eventId == null || eventId.isEmpty) {
      return null;
    }

    final result =
    await _eventRepository.getEvent(eventId);

    if (mounted) {
      event = result;
    }

    return result;
  }

  // --------------------------------------------------
  // FORMAT
  // --------------------------------------------------

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  String _formatAmount(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      decimalDigits: 2,
      symbol: '₹ ',
    ).format(amount);
  }

  // --------------------------------------------------
  // GENERATE RECEIPT
  // --------------------------------------------------

  Future<void> _generateReceipt() async {
    if (settings == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Temple settings not available',
          ),
        ),
      );

      return;
    }

    final pdfBytes =
    await ReceiptService.generateDonationReceipt(
      donation: widget.donation,

      // Dynamic temple settings
      templeName: settings!.templeName,
      address: settings!.address,
      phone: settings!.phone,

      // Dynamic event
      eventName: event?.name,
    );

    if (!mounted) return;

    context.push(
      AppRoutes.receiptPreview,
      extra: {
        'pdfBytes': pdfBytes,
        'receiptNumber':
        widget.donation.receiptNumber,
      },
    );
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final donation = widget.donation;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Donation Details',
        ),
      ),

      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            // ====================================
            // DONATION CARD
            // ====================================

            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(20),

                child: Column(
                  children: [
                    const Icon(
                      Icons.temple_hindu,
                      size: 60,
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    const Text(
                      'Donation Receipt',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    _detailRow(
                      'Receipt Number',
                      donation.receiptNumber,
                    ),

                    _detailRow(
                      'Donor Name',
                      donation.donorName,
                    ),

                    _detailRow(
                      'Phone',
                      donation.phone ?? '-',
                    ),

                    _detailRow(
                      'Amount',
                      _formatAmount(
                        donation.amount,
                      ),
                    ),

                    _detailRow(
                      'Purpose',
                      donation.purpose ??
                          'General Donation',
                    ),

                    // Event
                    _eventRow(),

                    _detailRow(
                      'Date',
                      _formatDate(
                        donation.donatedAt,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            // ====================================
            // GENERATE RECEIPT
            // ====================================

            SizedBox(
              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(
                onPressed:
                settings == null
                    ? null
                    : _generateReceipt,

                icon: const Icon(
                  Icons.picture_as_pdf,
                ),

                label: const Text(
                  'Generate Receipt',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // EVENT ROW
  // --------------------------------------------------

  Widget _eventRow() {
    if (widget.donation.eventId == null ||
        widget.donation.eventId!.isEmpty) {
      return _detailRow(
        'Event',
        'General / No Event',
      );
    }

    return _detailRow(
      'Event',
      event?.name ?? 'Event not found',
    );
  }

  // --------------------------------------------------
  // DETAIL ROW
  // --------------------------------------------------

  Widget _detailRow(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Expanded(
            flex: 2,

            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            flex: 3,

            child: Text(
              value,
              textAlign: TextAlign.right,

              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
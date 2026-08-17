import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../models/event_model.dart';
import '../../../repositories/donation_repository.dart';
import '../../../repositories/event_repository.dart';
import '../../providers/donation_provider.dart';

class DonationFormPage extends ConsumerStatefulWidget {
  const DonationFormPage({super.key});

  @override
  ConsumerState<DonationFormPage> createState() =>
      _DonationFormPageState();
}

class _DonationFormPageState
    extends ConsumerState<DonationFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();

  final DonationRepository _repository =
  DonationRepository();

  final EventRepository _eventRepository =
  EventRepository();

  bool saving = false;
  bool loadingEvents = true;

  List<EventModel> events = [];

  String? selectedEventId;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _purposeController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // LOAD EVENTS
  // --------------------------------------------------

  Future<void> _loadEvents() async {
    try {
      final result =
      await _eventRepository.getEvents();

      if (!mounted) return;

      setState(() {
        events = result;
        loadingEvents = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingEvents = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to load events: '
                '${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  // --------------------------------------------------
  // SAVE DONATION
  // --------------------------------------------------

  Future<void> saveDonation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = double.tryParse(
      _amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid donation amount',
          ),
        ),
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final donation =
      await _repository.addDonation(
        donorName:
        _nameController.text.trim(),
        amount: amount,
        phone: _phoneController.text
            .trim()
            .isEmpty
            ? null
            : _phoneController.text.trim(),
        purpose: _purposeController.text
            .trim()
            .isEmpty
            ? null
            : _purposeController.text.trim(),

        // Event association
        eventId: selectedEventId,
      );

      // Refresh donation list.
      ref.invalidate(donationsProvider);

      if (!mounted) return;

      // Go directly to details.
      context.pushReplacement(
        AppRoutes.donationDetails,
        extra: donation,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Donation',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              // ========================================
              // DONOR NAME
              // ========================================

              TextFormField(
                controller: _nameController,

                textCapitalization:
                TextCapitalization.words,

                decoration:
                const InputDecoration(
                  labelText: 'Donor Name',
                  prefixIcon: Icon(
                    Icons.person_outline,
                  ),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter donor name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ========================================
              // PHONE
              // ========================================

              TextFormField(
                controller: _phoneController,

                keyboardType:
                TextInputType.phone,

                decoration:
                const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ========================================
              // AMOUNT
              // ========================================

              TextFormField(
                controller: _amountController,

                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),

                decoration:
                const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹ ',
                  prefixIcon: Icon(
                    Icons.currency_rupee,
                  ),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter amount';
                  }

                  final amount =
                  double.tryParse(
                    value.trim(),
                  );

                  if (amount == null) {
                    return 'Enter a valid amount';
                  }

                  if (amount <= 0) {
                    return 'Amount must be greater than 0';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ========================================
              // PURPOSE
              // ========================================

              TextFormField(
                controller:
                _purposeController,

                textCapitalization:
                TextCapitalization
                    .sentences,

                decoration:
                const InputDecoration(
                  labelText: 'Purpose',
                  prefixIcon: Icon(
                    Icons.notes_outlined,
                  ),
                  hintText:
                  'Eg. Annadhanam, Pooja, General',
                ),
              ),

              const SizedBox(height: 16),

              // ========================================
              // EVENT
              // ========================================

              _buildEventDropdown(),

              const SizedBox(height: 30),

              // ========================================
              // SAVE
              // ========================================

              SizedBox(
                height: 50,

                child: ElevatedButton(
                  onPressed:
                  saving || loadingEvents
                      ? null
                      : saveDonation,

                  child: saving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'SAVE DONATION',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.bold,
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
  // EVENT DROPDOWN
  // --------------------------------------------------

  Widget _buildEventDropdown() {
    if (loadingEvents) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'Event',
          prefixIcon: Icon(
            Icons.event_outlined,
          ),
        ),
        child: SizedBox(
          height: 20,
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      );
    }

    return DropdownButtonFormField<String?>(
      value: selectedEventId,

      decoration: const InputDecoration(
        labelText: 'Event',
        prefixIcon: Icon(
          Icons.event_outlined,
        ),
      ),

      items: [
        const DropdownMenuItem<String?>(
          value: null,
          child: Text(
            'General / No Event',
          ),
        ),

        ...events.map(
              (event) {
            return DropdownMenuItem<String?>(
              value: event.id,
              child: Text(
                event.name,
                overflow:
                TextOverflow.ellipsis,
              ),
            );
          },
        ),
      ],

      onChanged: saving
          ? null
          : (value) {
        setState(() {
          selectedEventId = value;
        });
      },
    );
  }
}
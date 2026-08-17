import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../models/event_model.dart';
import '../../../providers/event_provider.dart';
import '../../../providers/expense_provider.dart';
import '../../../repositories/expense_repository.dart';

class ExpenseFormPage extends ConsumerStatefulWidget {
  const ExpenseFormPage({super.key});

  @override
  ConsumerState<ExpenseFormPage> createState() =>
      _ExpenseFormPageState();
}

class _ExpenseFormPageState
    extends ConsumerState<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController =
  TextEditingController();

  final _amountController =
  TextEditingController();

  final _notesController =
  TextEditingController();

  final ExpenseRepository _repository =
  ExpenseRepository();

  bool saving = false;

  DateTime selectedDate = DateTime.now();

  String selectedCategory = 'Pooja';

  String? selectedEventId;

  final List<String> categories = [
    'Pooja',
    'Flowers',
    'Electricity',
    'Maintenance',
    'Food / Annadhanam',
    'Salary',
    'Cleaning',
    'Event',
    'Other',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // ==================================================
  // DATE
  // ==================================================

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ==================================================
  // SAVE
  // ==================================================

  Future<void> saveExpense() async {
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
            'Enter a valid expense amount',
          ),
        ),
      );

      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final expense =
      await _repository.addExpense(
        description:
        _descriptionController.text.trim(),

        amount: amount,

        category: selectedCategory,

        date: selectedDate,

        notes:
        _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),

        // IMPORTANT
        eventId: selectedEventId,
      );

      // Refresh expense list.
      ref.invalidate(expensesProvider);

      if (!mounted) return;

      context.pushReplacement(
        AppRoutes.expenseDetails,
        extra: expense,
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

  // ==================================================
  // BUILD
  // ==================================================

  @override
  Widget build(BuildContext context) {
    final eventsAsync =
    ref.watch(eventsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Expense',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: ListView(
            children: [
              // ======================================
              // DESCRIPTION
              // ======================================

              TextFormField(
                controller:
                _descriptionController,

                textCapitalization:
                TextCapitalization.sentences,

                decoration:
                const InputDecoration(
                  labelText: 'Description',

                  hintText:
                  'Eg. Flowers for pooja',

                  prefixIcon: Icon(
                    Icons.description_outlined,
                  ),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter expense description';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ======================================
              // AMOUNT
              // ======================================

              TextFormField(
                controller:
                _amountController,

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

              // ======================================
              // CATEGORY
              // ======================================

              DropdownButtonFormField<String>(
                initialValue:
                selectedCategory,

                decoration:
                const InputDecoration(
                  labelText: 'Category',

                  prefixIcon: Icon(
                    Icons.category_outlined,
                  ),
                ),

                items:
                categories.map(
                      (category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  },
                ).toList(),

                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // ======================================
              // EVENT
              // ======================================

              eventsAsync.when(
                loading: () {
                  return const InputDecorator(
                    decoration:
                    InputDecoration(
                      labelText: 'Event',
                      prefixIcon: Icon(
                        Icons.event_outlined,
                      ),
                    ),
                    child: SizedBox(
                      height: 24,
                      child: Align(
                        alignment:
                        Alignment.centerLeft,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                },

                error: (error, stack) {
                  return InputDecorator(
                    decoration:
                    const InputDecoration(
                      labelText: 'Event',
                      prefixIcon: Icon(
                        Icons.event_outlined,
                      ),
                    ),
                    child: const Text(
                      'Unable to load events',
                    ),
                  );
                },

                data: (events) {
                  return DropdownButtonFormField<
                      String?>(
                    initialValue:
                    selectedEventId,

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
                          'General / No Event',
                        ),
                      ),

                      ...events.map(
                            (EventModel event) {
                          return DropdownMenuItem<
                              String?>(
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

                    onChanged: (value) {
                      setState(() {
                        selectedEventId = value;
                      });
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // ======================================
              // DATE
              // ======================================

              InkWell(
                onTap: selectDate,

                borderRadius:
                BorderRadius.circular(12),

                child: InputDecorator(
                  decoration:
                  const InputDecoration(
                    labelText: 'Expense Date',

                    prefixIcon: Icon(
                      Icons
                          .calendar_today_outlined,
                    ),
                  ),

                  child: Text(
                    '${selectedDate.day.toString().padLeft(2, '0')}/'
                        '${selectedDate.month.toString().padLeft(2, '0')}/'
                        '${selectedDate.year}',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ======================================
              // NOTES
              // ======================================

              TextFormField(
                controller:
                _notesController,

                textCapitalization:
                TextCapitalization.sentences,

                maxLines: 3,

                decoration:
                const InputDecoration(
                  labelText: 'Notes',

                  hintText:
                  'Optional notes',

                  prefixIcon: Icon(
                    Icons.notes_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ======================================
              // SAVE
              // ======================================

              SizedBox(
                height: 50,

                child: ElevatedButton(
                  onPressed:
                  saving ? null : saveExpense,

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
                    'SAVE EXPENSE',

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
}
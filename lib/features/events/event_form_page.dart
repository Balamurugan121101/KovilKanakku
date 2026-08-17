import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../models/event_model.dart';
import '../../../repositories/event_repository.dart';

class EventFormPage extends StatefulWidget {
  const EventFormPage({
    super.key,
    this.event,
  });

  final EventModel? event;

  @override
  State<EventFormPage> createState() =>
      _EventFormPageState();
}

class _EventFormPageState
    extends State<EventFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
  TextEditingController();

  final _descriptionController =
  TextEditingController();

  final _locationController =
  TextEditingController();

  final EventRepository _repository =
  EventRepository();

  DateTime? _selectedDate;

  String _selectedStatus = 'Upcoming';

  bool _saving = false;

  bool get _isEditing =>
      widget.event != null;

  @override
  void initState() {
    super.initState();

    final event = widget.event;

    if (event != null) {
      _nameController.text = event.name;

      _descriptionController.text =
          event.description;

      _locationController.text =
          event.location;

      _selectedDate = event.date;

      _selectedStatus = event.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  // --------------------------------------------------
  // DATE PICKER
  // --------------------------------------------------

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selectedDate =
    await showDatePicker(
      context: context,

      initialDate:
      _selectedDate ?? now,

      firstDate:
      DateTime(now.year - 1),

      lastDate:
      DateTime(now.year + 10),
    );

    if (selectedDate == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _selectedDate = selectedDate;
    });
  }

  // --------------------------------------------------
  // SAVE
  // --------------------------------------------------

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please select event date',
          ),
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      late EventModel event;

      // ---------------------------------------------
      // ADD
      // ---------------------------------------------

      if (!_isEditing) {
        event =
        await _repository.addEvent(
          name:
          _nameController.text.trim(),

          description:
          _descriptionController
              .text
              .trim(),

          date: _selectedDate!,

          location:
          _locationController.text
              .trim(),

          status: _selectedStatus,
        );
      }

      // ---------------------------------------------
      // EDIT
      // ---------------------------------------------

      else {
        event =
            widget.event!.copyWith(
              name:
              _nameController.text.trim(),

              description:
              _descriptionController
                  .text
                  .trim(),

              date: _selectedDate!,

              location:
              _locationController.text
                  .trim(),

              status: _selectedStatus,
            );

        await _repository.updateEvent(
          event,
        );
      }

      if (!mounted) {
        return;
      }

      // ---------------------------------------------
      // AFTER ADD
      // ---------------------------------------------

      if (!_isEditing) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Event added successfully',
            ),
          ),
        );

        context.pushReplacement(
          AppRoutes.eventDetails,
          extra: event,
        );
      }

      // ---------------------------------------------
      // AFTER EDIT
      // ---------------------------------------------

      else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'Event updated successfully',
            ),
          ),
        );

        context.pop(event);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

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
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // --------------------------------------------------
  // DATE FORMAT
  // --------------------------------------------------

  String _formatDate(
      DateTime date,
      ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Edit Event'
              : 'Add Event',
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: ListView(
            padding:
            const EdgeInsets.all(16),

            children: [
              // ---------------------------------------
              // EVENT NAME
              // ---------------------------------------

              TextFormField(
                controller:
                _nameController,

                textInputAction:
                TextInputAction.next,

                decoration:
                const InputDecoration(
                  labelText: 'Event Name',
                  prefixIcon:
                  Icon(Icons.event),
                  border:
                  OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Enter event name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              // ---------------------------------------
              // DESCRIPTION
              // ---------------------------------------

              TextFormField(
                controller:
                _descriptionController,

                maxLines: 3,

                decoration:
                const InputDecoration(
                  labelText:
                  'Description',

                  prefixIcon:
                  Icon(
                    Icons.description,
                  ),

                  border:
                  OutlineInputBorder(),

                  alignLabelWithHint:
                  true,
                ),
              ),

              const SizedBox(height: 12),

              // ---------------------------------------
              // LOCATION
              // ---------------------------------------

              TextFormField(
                controller:
                _locationController,

                textInputAction:
                TextInputAction.done,

                decoration:
                const InputDecoration(
                  labelText: 'Location',

                  prefixIcon:
                  Icon(
                    Icons.location_on,
                  ),

                  border:
                  OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Enter event location';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              // ---------------------------------------
              // DATE
              // ---------------------------------------

              InkWell(
                onTap: _saving
                    ? null
                    : _selectDate,

                borderRadius:
                BorderRadius.circular(
                  4,
                ),

                child: InputDecorator(
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Event Date',

                    prefixIcon:
                    Icon(
                      Icons.calendar_today,
                    ),

                    border:
                    OutlineInputBorder(),
                  ),

                  child: Text(
                    _selectedDate == null
                        ? 'Select date'
                        : _formatDate(
                      _selectedDate!,
                    ),

                    style: TextStyle(
                      color:
                      _selectedDate ==
                          null
                          ? Colors.grey
                          : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ---------------------------------------
              // STATUS
              // ---------------------------------------

              DropdownButtonFormField<
                  String>(
                initialValue:
                _selectedStatus,

                decoration:
                const InputDecoration(
                  labelText: 'Status',

                  prefixIcon:
                  Icon(Icons.flag),

                  border:
                  OutlineInputBorder(),
                ),

                items: const [
                  DropdownMenuItem(
                    value: 'Upcoming',
                    child:
                    Text('Upcoming'),
                  ),

                  DropdownMenuItem(
                    value: 'Ongoing',
                    child:
                    Text('Ongoing'),
                  ),

                  DropdownMenuItem(
                    value: 'Completed',
                    child:
                    Text('Completed'),
                  ),

                  DropdownMenuItem(
                    value: 'Cancelled',
                    child:
                    Text('Cancelled'),
                  ),
                ],

                onChanged: _saving
                    ? null
                    : (value) {
                  if (value ==
                      null) {
                    return;
                  }

                  setState(() {
                    _selectedStatus =
                        value;
                  });
                },
              ),

              const SizedBox(height: 28),

              // ---------------------------------------
              // SAVE BUTTON
              // ---------------------------------------

              SizedBox(
                height: 50,
                width: double.infinity,

                child: ElevatedButton(
                  onPressed:
                  _saving
                      ? null
                      : _saveEvent,

                  child: _saving
                      ? const SizedBox(
                    width: 22,
                    height: 22,

                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                      Colors.white,
                    ),
                  )
                      : Text(
                    _isEditing
                        ? 'UPDATE EVENT'
                        : 'SAVE EVENT',

                    style:
                    const TextStyle(
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
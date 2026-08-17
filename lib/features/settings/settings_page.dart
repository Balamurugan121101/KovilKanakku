import 'package:flutter/material.dart';

import '../../../models/settings_model.dart';
import '../../../repositories/settings_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
  });

  @override
  State<SettingsPage> createState() =>
      _SettingsPageState();
}

class _SettingsPageState
    extends State<SettingsPage> {
  final SettingsRepository _repository =
  SettingsRepository();

  final _formKey =
  GlobalKey<FormState>();

  final _templeNameController =
  TextEditingController();

  final _addressController =
  TextEditingController();

  final _phoneController =
  TextEditingController();

  final _receiptPrefixController =
  TextEditingController();

  final _nextReceiptNumberController =
  TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  @override
  void dispose() {
    _templeNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _receiptPrefixController.dispose();
    _nextReceiptNumberController.dispose();

    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final settings =
      await _repository.getSettings();

      if (!mounted) return;

      if (settings != null) {
        _templeNameController.text =
            settings.templeName;

        _addressController.text =
            settings.address;

        _phoneController.text =
            settings.phone;

        _receiptPrefixController.text =
            settings.receiptPrefix;

        _nextReceiptNumberController.text =
            settings.nextReceiptNumber
                .toString();
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString()
                .replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final settings =
      SettingsModel(
        templeName:
        _templeNameController.text.trim(),

        address:
        _addressController.text.trim(),

        phone:
        _phoneController.text.trim(),

        receiptPrefix:
        _receiptPrefixController.text
            .trim()
            .toUpperCase(),

        nextReceiptNumber:
        int.parse(
          _nextReceiptNumberController
              .text
              .trim(),
        ),
      );

      await _repository.saveSettings(
        settings,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Settings saved successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString()
                .replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Temple Settings',
        ),
      ),

      body: isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : SafeArea(
        child: Form(
          key: _formKey,

          child: ListView(
            padding:
            const EdgeInsets.all(16),

            children: [
              _sectionTitle(
                'Temple Information',
              ),

              const SizedBox(height: 8),

              _buildTextField(
                controller:
                _templeNameController,
                label: 'Temple Name',
                icon:
                Icons.temple_hindu,
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Enter temple name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller:
                _addressController,
                label: 'Address',
                icon: Icons.location_on,
                maxLines: 2,
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Enter temple address';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller:
                _phoneController,
                label: 'Phone',
                icon: Icons.phone,
                keyboardType:
                TextInputType.phone,
              ),

              const SizedBox(height: 24),

              _sectionTitle(
                'Receipt Settings',
              ),

              const SizedBox(height: 8),

              _buildTextField(
                controller:
                _receiptPrefixController,
                label: 'Receipt Prefix',
                icon: Icons.receipt_long,
                textCapitalization:
                TextCapitalization
                    .characters,
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Enter receipt prefix';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller:
                _nextReceiptNumberController,
                label:
                'Next Receipt Number',
                icon:
                Icons.format_list_numbered,
                keyboardType:
                TextInputType.number,
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Enter receipt number';
                  }

                  final number =
                  int.tryParse(
                    value.trim(),
                  );

                  if (number == null ||
                      number <= 0) {
                    return 'Enter a valid number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 50,
                width: double.infinity,
                child:
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : _saveSettings,

                  child: isSaving
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                      Colors.white,
                    ),
                  )
                      : const Text(
                    'SAVE SETTINGS',
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
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
      String title,
      ) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController
    controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    TextCapitalization
    textCapitalization =
        TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: keyboardType,

      maxLines: maxLines,

      textCapitalization:
      textCapitalization,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        border:
        const OutlineInputBorder(),
      ),

      validator: validator,
    );
  }
}
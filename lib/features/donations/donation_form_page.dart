import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../repositories/donation_repository.dart';


class DonationFormPage extends StatefulWidget {
  const DonationFormPage({super.key});

  @override
  State<DonationFormPage> createState() =>
      _DonationFormPageState();
}


class _DonationFormPageState
    extends State<DonationFormPage> {
  final _formKey =
  GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final DonationRepository _repository = DonationRepository();

  bool saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> saveDonation() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      saving = true;
    });
    try {
      await _repository.addDonation(
        donorName: _nameController.text.trim(),
        amount: double.parse(
          _amountController.text,
        ),
        phone: _phoneController.text.trim(),
        purpose: _purposeController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
          Text(
            "Donation added successfully",
          ),
        ),
      );

      context.pop();
    } catch(e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if(mounted){
        setState(() {
          saving=false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(
        title:
        const Text(
          "Add Donation",
        ),
      ),
      body:
      Padding(
        padding:
        const EdgeInsets.all(16),
        child:
        Form(
          key:
          _formKey,
          child:
          ListView(
            children: [
              TextFormField(
                controller:
                _nameController,
                decoration:
                const InputDecoration(
                  labelText:
                  "Donor Name",
                ),
                validator:
                    (value){
                  if(value==null ||
                      value.isEmpty){
                    return
                      "Enter donor name";
                  }
                  return null;
                },
              ),

              const SizedBox(
                height:16,
              ),
              TextFormField(
                controller:
                _phoneController,
                keyboardType:
                TextInputType.phone,
                decoration:
                const InputDecoration(
                  labelText:
                  "Phone",
                ),
              ),

              const SizedBox(
                height:16,
              ),
              TextFormField(
                controller:
                _amountController,
                keyboardType:
                TextInputType.number,
                decoration:
                const InputDecoration(
                  labelText:
                  "Amount",
                  prefixText:
                  "₹ ",
                ),
                validator:
                    (value){
                  if(value==null ||
                      value.isEmpty){
                    return
                      "Enter amount";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height:16,
              ),
              TextFormField(
                controller:
                _purposeController,
                decoration:
                const InputDecoration(
                  labelText:
                  "Purpose",
                ),
              ),
              const SizedBox(
                height:30,
              ),
              SizedBox(
                height:50,
                child:
                ElevatedButton(
                  onPressed:
                  saving
                      ? null
                      : saveDonation,
                  child:
                  saving
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      :
                  const Text(
                    "SAVE",
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
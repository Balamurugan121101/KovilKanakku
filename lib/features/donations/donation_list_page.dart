import 'package:flutter/material.dart';

import '../../../models/donation_model.dart';
import '../../../repositories/donation_repository.dart';
import 'package:go_router/go_router.dart';
import '../../../app/routes.dart';


class DonationListPage extends StatefulWidget {
  const DonationListPage({super.key});

  @override
  State<DonationListPage> createState() =>
      _DonationListPageState();
}


class _DonationListPageState
    extends State<DonationListPage> {


  final DonationRepository _repository = DonationRepository();
  List<DonationModel> donations = [];
  bool loading = true;


  @override
  void initState() {
    super.initState();
    loadDonations();
  }

  Future<void> loadDonations() async {
    final result = await _repository.getDonations();

    if (mounted) {
      setState(() {
        donations = result;
        loading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Donations",
        ),
      ),
      floatingActionButton:
      FloatingActionButton(
        onPressed: () async {
          await context.push(
            AppRoutes.addDonation,
          );

          loadDonations();
        },
        child:
        const Icon(Icons.add),
      ),
      body: loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : donations.isEmpty
          ? const Center(
        child:
        Text(
          "No donations found",
        ),
      )
          : RefreshIndicator(
        onRefresh:
        loadDonations,
        child:
        ListView.builder(
          itemCount:
          donations.length,
          itemBuilder:
              (context, index) {
            final donation =
            donations[index];
            return Card(
              child:
              ListTile(
                leading:
                CircleAvatar(
                  child:
                  Text(
                    donation.receiptNumber
                        .split('-')
                        .last
                        .replaceFirst(RegExp(r'^0+'), ''),
                  ),
                ),
                title:
                Text(
                  donation.donorName,
                ),
                subtitle:
                Text(
                  donation.purpose ??
                      "General Donation",
                ),
                trailing:
                Text(
                  "₹ ${donation.amount}",
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 15
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../providers/donation_provider.dart';
import '../../../models/donation_model.dart';

class DonationListPage extends ConsumerStatefulWidget {
  const DonationListPage({super.key});

  @override
  ConsumerState<DonationListPage> createState() =>
      _DonationListPageState();
}

class _DonationListPageState
    extends ConsumerState<DonationListPage> {
  final TextEditingController _searchController =
  TextEditingController();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText =
            _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<dynamic> _filterDonations(
      List<DonationModel> donations,
      ) {
    if (_searchText.isEmpty) {
      return donations;
    }

    return donations.where((donation) {
      final donorName =
      donation.donorName.toString().toLowerCase();

      final receiptNumber =
      donation.receiptNumber.toString().toLowerCase();

      final purpose =
      (donation.purpose ?? '').toString().toLowerCase();

      return donorName.contains(_searchText) ||
          receiptNumber.contains(_searchText) ||
          purpose.contains(_searchText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final donationsAsync =
    ref.watch(donationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Donations'),
      ),

      body: donationsAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },

        error: (error, stackTrace) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Unable to load donations',
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(
                      donationsProvider,
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },

        data: (donations) {
          final filteredDonations =
          _filterDonations(donations);

          final totalAmount = donations.fold<double>(
            0,
                (total, donation) =>
            total + donation.amount,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Card(
                  child: Padding(
                    padding:
                    const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          child: Icon(
                            Icons.currency_rupee,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Donations',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              NumberFormat.currency(
                                locale: 'en_IN',
                                symbol: '₹ ',
                                decimalDigits: 2,
                              ).format(totalAmount),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  8,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                    'Search donor or receipt...',
                    prefixIcon:
                    const Icon(Icons.search),
                    suffixIcon:
                    _searchText.isNotEmpty
                        ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                      ),
                      onPressed: () {
                        _searchController
                            .clear();
                      },
                    )
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // List
              Expanded(
                child: filteredDonations.isEmpty
                    ? Center(
                  child: Text(
                    _searchText.isEmpty
                        ? 'No donations found'
                        : 'No matching donations',
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(
                      donationsProvider,
                    );

                    await ref.read(
                      donationsProvider.future,
                    );
                  },

                  child: ListView.builder(
                    padding:
                    const EdgeInsets.only(
                      bottom: 90,
                    ),

                    itemCount:
                    filteredDonations.length,

                    itemBuilder:
                        (context, index) {
                      final donation =
                      filteredDonations[
                      index];

                      return _DonationCard(
                        donation: donation,
                        onTap: () {
                          context.push(
                            AppRoutes
                                .donationDetails,
                            extra: donation,
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () async {
          await context.push(
            AppRoutes.addDonation,
          );

          // Refresh when coming back.
          ref.invalidate(
            donationsProvider,
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Donation'),
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  const _DonationCard({
    required this.donation,
    required this.onTap,
  });

  final DonationModel donation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(
      'dd MMM yyyy',
    ).format(donation.donatedAt);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),

      child: ListTile(
        onTap: onTap,

        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        leading: const CircleAvatar(
          child: Icon(
            Icons.volunteer_activism,
          ),
        ),

        title: Text(
          donation.donorName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 5,
          ),
          child: Text(
            '${donation.receiptNumber}'
                ' • '
                '${donation.purpose?.isNotEmpty == true ? donation.purpose : 'General Donation'}'
                '\n$date',
          ),
        ),

        trailing: Text(
          NumberFormat.currency(
            locale: 'en_IN',
            symbol: '₹ ',
            decimalDigits: 2
          ).format(donation.amount),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
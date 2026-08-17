import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../models/donation_model.dart';
import '../../../models/expense_model.dart';
import '../../../models/user_model.dart';
import '../../../repositories/donation_repository.dart';
import '../../../repositories/expense_repository.dart';
import '../../../repositories/user_repository.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final UserRepository _userRepository = UserRepository();
  final DonationRepository _donationRepository =
  DonationRepository();
  final ExpenseRepository _expenseRepository =
  ExpenseRepository();

  UserModel? userModel;

  List<DonationModel> donations = [];
  List<ExpenseModel> expenses = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final firebaseUser =
          FirebaseAuth.instance.currentUser;

      if (firebaseUser == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      final results = await Future.wait([
        _userRepository.getUser(firebaseUser.uid),
        _donationRepository.getDonations(),
        _expenseRepository.getExpenses(),
      ]);

      if (!mounted) return;

      setState(() {
        userModel = results[0] as UserModel?;
        donations =
        results[1] as List<DonationModel>;
        expenses =
        results[2] as List<ExpenseModel>;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

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
    }
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      isLoading = true;
    });

    await _loadDashboard();
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    context.go(AppRoutes.login);
  }

  // --------------------------------------------------
  // FINANCIAL CALCULATIONS
  // --------------------------------------------------

  double get totalDonation {
    return donations.fold<double>(
      0,
          (total, donation) =>
      total + donation.amount,
    );
  }

  double get totalExpense {
    return expenses.fold<double>(
      0,
          (total, expense) =>
      total + expense.amount,
    );
  }

  double get balance {
    return totalDonation - totalExpense;
  }

  double get todayDonation {
    final now = DateTime.now();

    return donations
        .where((donation) {
      final date = donation.donatedAt;

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    })
        .fold<double>(
      0,
          (total, donation) =>
      total + donation.amount,
    );
  }

  double get todayExpense {
    final now = DateTime.now();

    return expenses
        .where((expense) {
      final date = expense.date;

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    })
        .fold<double>(
      0,
          (total, expense) =>
      total + expense.amount,
    );
  }

  double get todayBalance {
    return todayDonation - todayExpense;
  }

  String _currency(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 2,
    ).format(amount);
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kovil Kanakku',
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
            ),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _refreshDashboard,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            12,
          ),
          children: [
            // --------------------------------
            // WELCOME
            // --------------------------------

            const SizedBox(height: 10),

            _welcomeCard(),

            const SizedBox(height: 10),

            // --------------------------------
            // TODAY
            // --------------------------------

            _sectionTitle('Today'),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: _compactSummaryCard(
                    title: 'Donation',
                    value:
                    _currency(
                      todayDonation,
                    ),
                    icon:
                    Icons.volunteer_activism,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _compactSummaryCard(
                    title: 'Expense',
                    value:
                    _currency(
                      todayExpense,
                    ),
                    icon: Icons.money_off,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _compactSummaryCard(
                    title: 'Balance',
                    value:
                    _currency(
                      todayBalance,
                    ),
                    icon:
                    Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --------------------------------
            // OVERALL
            // --------------------------------

            _sectionTitle('Overall'),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: _compactSummaryCard(
                    title: 'Donations',
                    value:
                    _currency(
                      totalDonation,
                    ),
                    icon:
                    Icons.volunteer_activism,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _compactSummaryCard(
                    title: 'Expenses',
                    value:
                    _currency(
                      totalExpense,
                    ),
                    icon:
                    Icons.receipt_long,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _compactSummaryCard(
                    title: 'Balance',
                    value:
                    _currency(
                      balance,
                    ),
                    icon:
                    Icons.account_balance_wallet,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // --------------------------------
            // MANAGEMENT
            // --------------------------------

            _sectionTitle('Management'),

            const SizedBox(height: 4),

            _compactMenuCard(
              title: 'Donations',
              subtitle: 'Manage donations',
              icon:
              Icons.volunteer_activism,
              onTap: () async {
                await context.push(
                  AppRoutes.donations,
                );

                if (mounted) {
                  _loadDashboard();
                }
              },
            ),

            _compactMenuCard(
              title: 'Expenses',
              subtitle: 'Track expenses',
              icon: Icons.money_off,
              onTap: () async {
                await context.push(
                  AppRoutes.expenses,
                );

                if (mounted) {
                  _loadDashboard();
                }
              },
            ),

            _compactMenuCard(
              title: 'Events',
              subtitle: 'Manage events',
              icon: Icons.event,
              onTap: () {
                context.push(
                  AppRoutes.events,
                );
              },
            ),

            _compactMenuCard(
              title: 'Reports',
              subtitle: 'Financial reports',
              icon: Icons.bar_chart,
              onTap: () {
                context.push(
                  AppRoutes.reports,
                );
              },
            ),

            _compactMenuCard(
              title: 'Settings',
              subtitle: 'Temple configuration',
              icon: Icons.settings,
              onTap: () async {
                await context.push(
                  AppRoutes.settings,
                );

                if (mounted) {
                  _loadDashboard();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // WELCOME CARD
  // --------------------------------------------------

  Widget _welcomeCard() {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 23,
              child: Icon(
                Icons.temple_hindu,
                size: 25,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  Text(
                    userModel?.name ?? 'Admin',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  if (userModel?.role != null)
                    Text(
                      userModel!.role,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
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

  // --------------------------------------------------
  // SECTION TITLE
  // --------------------------------------------------

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // --------------------------------------------------
  // SUMMARY CARD
  // --------------------------------------------------

  Widget _compactSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
            ),

            const SizedBox(height: 5),

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 2),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------
  // MANAGEMENT CARD
  // --------------------------------------------------

  Widget _compactMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 4,
      ),
      child: ListTile(
        dense: true,

        visualDensity: const VisualDensity(
          vertical: -2,
        ),

        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 12,
        ),

        onTap: onTap,

        leading: CircleAvatar(
          radius: 18,
          child: Icon(
            icon,
            size: 19,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
          ),
        ),

        trailing: const Icon(
          Icons.chevron_right,
          size: 20,
        ),
      ),
    );
  }
}
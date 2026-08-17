import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/donation_provider.dart';
import '../providers/expense_provider.dart';

class DashboardSummary {
  const DashboardSummary({
    required this.totalDonations,
    required this.totalExpenses,
    required this.todayDonations,
    required this.todayExpenses,
  });

  final double totalDonations;
  final double totalExpenses;
  final double todayDonations;
  final double todayExpenses;

  double get balance =>
      totalDonations - totalExpenses;

  double get todayBalance =>
      todayDonations - todayExpenses;
}

final dashboardSummaryProvider =
FutureProvider<DashboardSummary>((ref) async {
  final donations =
  await ref.watch(donationsProvider.future);

  final expenses =
  await ref.watch(expensesProvider.future);

  final now = DateTime.now();

  final todayDonations = donations
      .where((donation) {
    return donation.donatedAt.year == now.year &&
        donation.donatedAt.month == now.month &&
        donation.donatedAt.day == now.day;
  })
      .fold<double>(
    0,
        (total, donation) =>
    total + donation.amount,
  );

  final todayExpenses = expenses
      .where((expense) {
    return expense.date.year == now.year &&
        expense.date.month == now.month &&
        expense.date.day == now.day;
  })
      .fold<double>(
    0,
        (total, expense) =>
    total + expense.amount,
  );

  final totalDonations = donations.fold<double>(
    0,
        (total, donation) =>
    total + donation.amount,
  );

  final totalExpenses = expenses.fold<double>(
    0,
        (total, expense) =>
    total + expense.amount,
  );

  return DashboardSummary(
    totalDonations: totalDonations,
    totalExpenses: totalExpenses,
    todayDonations: todayDonations,
    todayExpenses: todayExpenses,
  );
});
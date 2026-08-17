import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/donation_model.dart';
import '../models/expense_model.dart';
import '../repositories/donation_repository.dart';
import '../repositories/expense_repository.dart';

enum ReportPeriod {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

class ReportFilter {
  const ReportFilter({
    this.period = ReportPeriod.thisMonth,
    this.customStart,
    this.customEnd,
    this.eventId,
  });

  final ReportPeriod period;

  final DateTime? customStart;

  final DateTime? customEnd;

  final String? eventId;

  DateTime get startDate {
    final now = DateTime.now();

    switch (period) {
      case ReportPeriod.today:
        return DateTime(
          now.year,
          now.month,
          now.day,
        );

      case ReportPeriod.thisWeek:
        final today = DateTime(
          now.year,
          now.month,
          now.day,
        );

        final daysFromMonday =
            today.weekday - DateTime.monday;

        return today.subtract(
          Duration(
            days: daysFromMonday,
          ),
        );

      case ReportPeriod.thisMonth:
        return DateTime(
          now.year,
          now.month,
          1,
        );

      case ReportPeriod.thisYear:
        return DateTime(
          now.year,
          1,
          1,
        );

      case ReportPeriod.custom:
        return customStart ??
            DateTime(
              now.year,
              now.month,
              1,
            );
    }
  }

  DateTime get endDate {
    final now = DateTime.now();

    switch (period) {
      case ReportPeriod.today:
        return DateTime(
          now.year,
          now.month,
          now.day,
          23,
          59,
          59,
          999,
        );

      case ReportPeriod.thisWeek:
        final today = DateTime(
          now.year,
          now.month,
          now.day,
        );

        final daysUntilSunday =
            DateTime.sunday - today.weekday;

        final sunday = today.add(
          Duration(
            days: daysUntilSunday,
          ),
        );

        return DateTime(
          sunday.year,
          sunday.month,
          sunday.day,
          23,
          59,
          59,
          999,
        );

      case ReportPeriod.thisMonth:
        return DateTime(
          now.year,
          now.month + 1,
          0,
          23,
          59,
          59,
          999,
        );

      case ReportPeriod.thisYear:
        return DateTime(
          now.year,
          12,
          31,
          23,
          59,
          59,
          999,
        );

      case ReportPeriod.custom:
        final end = customEnd ?? now;

        return DateTime(
          end.year,
          end.month,
          end.day,
          23,
          59,
          59,
          999,
        );
    }
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ReportFilter &&
            other.period == period &&
            other.customStart == customStart &&
            other.customEnd == customEnd &&
            other.eventId == eventId;
  }

  @override
  int get hashCode {
    return Object.hash(
      period,
      customStart,
      customEnd,
      eventId,
    );
  }
}


// ============================================================
// REPORT DATA
// ============================================================

class ReportData {
  const ReportData({
    required this.donations,
    required this.expenses,
  });

  final List<DonationModel> donations;

  final List<ExpenseModel> expenses;

  double get totalDonations {
    return donations.fold(
      0,
          (sum, donation) {
        return sum + donation.amount;
      },
    );
  }

  double get totalExpenses {
    return expenses.fold(
      0,
          (sum, expense) {
        return sum + expense.amount;
      },
    );
  }

  double get balance {
    return totalDonations -
        totalExpenses;
  }

  int get donationCount {
    return donations.length;
  }

  int get expenseCount {
    return expenses.length;
  }

  int get transactionCount {
    return donationCount +
        expenseCount;
  }
}


// ============================================================
// REPORT PROVIDER
// ============================================================

final reportProvider = FutureProvider.family<
    ReportData,
    ReportFilter>(
      (ref, filter) async {
    final donationRepository =
    DonationRepository();

    final expenseRepository =
    ExpenseRepository();

    // ----------------------------------------------------------
    // Fetch both collections in parallel
    // ----------------------------------------------------------

    final results = await Future.wait([
      donationRepository.getDonations(),
      expenseRepository.getExpenses(),
    ]);

    final allDonations =
    results[0] as List<DonationModel>;

    final allExpenses =
    results[1] as List<ExpenseModel>;

    // ----------------------------------------------------------
    // Filter donations
    // ----------------------------------------------------------

    final donations =
    allDonations.where(
          (donation) {
        final donationDate =
            donation.donatedAt;

        final dateMatches =
            !donationDate.isBefore(
              filter.startDate,
            ) &&
                !donationDate.isAfter(
                  filter.endDate,
                );

        final eventMatches =
            filter.eventId == null ||
                filter.eventId!.isEmpty ||
                donation.eventId ==
                    filter.eventId;

        return dateMatches &&
            eventMatches;
      },
    ).toList();

    // ----------------------------------------------------------
    // Filter expenses
    // ----------------------------------------------------------

    final expenses =
    allExpenses.where(
          (expense) {
        final expenseDate =
            expense.date;

        final dateMatches =
            !expenseDate.isBefore(
              filter.startDate,
            ) &&
                !expenseDate.isAfter(
                  filter.endDate,
                );

        final eventMatches =
            filter.eventId == null ||
                filter.eventId!.isEmpty ||
                expense.eventId ==
                    filter.eventId;

        return dateMatches &&
            eventMatches;
      },
    ).toList();

    // ----------------------------------------------------------
    // Sort donations - newest first
    // ----------------------------------------------------------

    donations.sort(
          (a, b) {
        return b.donatedAt.compareTo(
          a.donatedAt,
        );
      },
    );

    // ----------------------------------------------------------
    // Sort expenses - newest first
    // ----------------------------------------------------------

    expenses.sort(
          (a, b) {
        return b.date.compareTo(
          a.date,
        );
      },
    );

    // ----------------------------------------------------------
    // Return report
    // ----------------------------------------------------------

    return ReportData(
      donations: donations,
      expenses: expenses,
    );
  },
);
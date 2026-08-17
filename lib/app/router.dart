import 'package:go_router/go_router.dart';
import 'dart:typed_data';

import '../features/donations/receipt_preview_page.dart';
import '../features/authentication/login_page.dart';
import '../features/authentication/splash_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/donations/donation_list_page.dart';
import '../features/donations/donation_form_page.dart';
import '../features/donations/donation_details_page.dart';
import '../features/events/event_details_page.dart';
import '../features/events/event_form_page.dart';
import '../features/events/event_list_page.dart';
import '../features/expenses/expense_details_page.dart';
import '../features/expenses/expense_form_page.dart';
import '../features/expenses/expense_list_page.dart';
import '../features/reports/report_preview_page.dart';
import '../features/reports/reports_page.dart';
import '../features/settings/settings_page.dart';
import '../models/donation_model.dart';
import '../models/event_model.dart';
import '../models/expense_model.dart';
import 'routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: AppRoutes.donations,
      builder: (context, state) => const DonationListPage(),
    ),
    GoRoute(
      path: AppRoutes.addDonation,
      builder: (context, state) => const DonationFormPage(),
    ),
    GoRoute(
      path: AppRoutes.donationDetails,
      builder: (context, state) {
        final donation = state.extra as DonationModel;

        return DonationDetailsPage(
          donation: donation,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.receiptPreview,
      builder: (context, state) {
        final data =
        state.extra as Map<String, dynamic>;

        return ReceiptPreviewPage(
          pdfBytes: data['pdfBytes'] as Uint8List,
          receiptNumber:
          data['receiptNumber'] as String,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.expenses,
      builder: (context, state) {
        return const ExpenseListPage();
      },
    ),
    GoRoute(
      path: AppRoutes.addExpense,
      builder: (context, state) {
        return const ExpenseFormPage();
      },
    ),
    GoRoute(
      path: AppRoutes.expenseDetails,
      builder: (context, state) {
        final expense =
        state.extra as ExpenseModel;

        return ExpenseDetailsPage(
          expense: expense,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) =>
      const SettingsPage(),
    ),
    GoRoute(
      path: AppRoutes.events,
      builder: (context, state) =>
      const EventListPage(),
    ),
    GoRoute(
      path: AppRoutes.eventAdd,
      builder: (context, state) =>
      const EventFormPage(),
    ),
    GoRoute(
      path: AppRoutes.eventEdit,
      builder: (context, state) {
        final event =
        state.extra as EventModel;

        return EventFormPage(
          event: event,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.eventDetails,
      builder: (context, state) {
        final event =
        state.extra as EventModel;

        return EventDetailsPage(
          event: event,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.reports,
      builder: (context, state) {
        return const ReportPage();
      },
    ),
    GoRoute(
      path: AppRoutes.reportPreview,
      builder: (context, state) {
        final pdfBytes =
        state.extra as Uint8List;

        return ReportPreviewPage(
          pdfBytes: pdfBytes,
        );
      },
    ),
  ],
);
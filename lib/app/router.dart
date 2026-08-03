import 'package:go_router/go_router.dart';

import '../features/authentication/login_page.dart';
import '../features/authentication/splash_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/donations/donation_list_page.dart';
import '../features/donations/donation_form_page.dart';
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
  ],
);
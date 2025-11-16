import 'package:flutter/material.dart';
import 'screens/onboarding/onboarding_page.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/bluetooth/ble_page.dart';
import 'screens/recommendations/recommendations_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/onboarding':
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
      case '/dashboard':
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case '/bluetooth':
        return MaterialPageRoute(builder: (_) => const BlePage());
      case '/recommendations':
        return MaterialPageRoute(builder: (_) => const RecommendationsPage());
      default:
        return MaterialPageRoute(builder: (_) => const OnboardingPage());
    }
  }
}

import 'package:flashcard_app/features/auth/screens/initial_setup_screen.dart';
import 'package:flashcard_app/features/home/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.initialSetup:
        return MaterialPageRoute(builder: (_) => const SetupScreen());

      case AppRoutes.homeScreen:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      default:
        return MaterialPageRoute(
          builder:
              (_) =>
                  const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}

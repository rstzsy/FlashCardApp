import 'package:flashcard_app/features/auth/screens/initial_setup_screen.dart';
import 'package:flashcard_app/features/home/screens/home_screen.dart';
import 'package:flashcard_app/features/game/screens/intro_game_screen.dart';
import 'package:flashcard_app/features/game/screens/home_game_screen.dart';
import 'package:flashcard_app/features/game/screens/shop_game_screen.dart';
import 'package:flutter/material.dart';
import '../features/auth/screens/login_screen.dart';
import 'package:flashcard_app/features/auth/screens/intro_home_screen.dart';
import '../features/group/screens/group_dashboard_screen.dart';
import '../features/group/screens/group_list_screen.dart';
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

      case AppRoutes.introHomeScreen:
        return MaterialPageRoute(builder: (_) => const IntroHomeScreen());

      case AppRoutes.homeGame:
        return MaterialPageRoute(builder: (_) => const HomeGameScreen());

      case AppRoutes.shopGame:
        return MaterialPageRoute(builder: (_) => const ShopGameScreen());
      
      case AppRoutes.introGameScreen:
        return MaterialPageRoute(builder: (context) => IntroGameScreen(onBack: () => Navigator.pop(context)));

      case AppRoutes.groupDashboard:
        return MaterialPageRoute(builder: (_) => const GroupDashboard());

      case AppRoutes.groupList:
        return MaterialPageRoute(builder: (_) => GroupListPage());

      default:
        return MaterialPageRoute(
          builder:
              (_) =>
                  const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}

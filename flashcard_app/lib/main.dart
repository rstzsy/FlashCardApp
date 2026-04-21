import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flashcard_app/features/auth/screens/auth_wrapper.dart';
import '../routes/app_router.dart';
import 'core/firebase/firebase_config.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await FirebaseConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Study English',

      theme: ThemeData(
        textTheme: GoogleFonts.baloo2TextTheme(
          Theme.of(context).textTheme,
        ),
      ),

      //initialRoute: AppRoutes.homeScreen, 
      //initialRoute: AppRoutes.initialSetup,
      //initialRoute: AppRoutes.fertilizerChallenge,
      // home: MainNavigation(),
      // initialRoute: AppRoutes.introHomeScreen,
      home: const AuthWrapper(), 
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
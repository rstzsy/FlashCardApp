import 'package:flashcard_app/routes/main_navigation.dart';
import 'package:flutter/material.dart';
import '../routes/app_router.dart';
import '../routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Study English',
      // initialRoute: AppRoutes.homeScreen,
      home: MainNavigation(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
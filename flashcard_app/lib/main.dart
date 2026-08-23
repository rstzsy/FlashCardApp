import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flashcard_app/features/auth/screens/auth_wrapper.dart';
import '../routes/app_router.dart';
import 'core/firebase/firebase_config.dart';
import 'core/themes/theme_provider.dart';
import 'features/chatbot/widgets/messageNotification.dart';
import 'features/group/controllers/group_controller.dart';
import 'routes/main_navigation.dart';

void main() async {
  await FirebaseConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GroupController()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Study English',

            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,

            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFE0F7FA),
              textTheme: GoogleFonts.baloo2TextTheme(
                ThemeData.light().textTheme,
              ),
            ),

            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF121212),
              textTheme: GoogleFonts.baloo2TextTheme(
                ThemeData.dark().textTheme,
              ),
            ),

            navigatorKey: AppNotification.navigatorKey,
            scaffoldMessengerKey: AppNotification.messengerKey,
            home: const AuthWrapper(),
            onGenerateRoute: AppRouter.generateRoute,
          );
        },
      ),
    );
  }
}
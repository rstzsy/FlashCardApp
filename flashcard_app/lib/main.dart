import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flashcard_app/features/auth/screens/auth_wrapper.dart';
import '../routes/app_router.dart';
import 'core/firebase/firebase_config.dart';
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
      ],
      child: MaterialApp(
        // navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Study English',

        theme: ThemeData(
          textTheme: GoogleFonts.baloo2TextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        navigatorKey: AppNotification.navigatorKey,
        scaffoldMessengerKey: AppNotification.messengerKey,
        home: MainNavigation(key: mainNavKey),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
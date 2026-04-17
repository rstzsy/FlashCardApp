import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../routes/app_routes.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _navigate(context, AppRoutes.introHomeScreen);
    }

    return FutureBuilder(
      future: _checkSetup(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasSetup = snapshot.data as bool;

        return _navigate(
          context,
          hasSetup
              ? AppRoutes.mainNavigation
              : AppRoutes.initialSetup,
        );
      },
    );
  }

  Future<bool> _checkSetup(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    return doc.data()?['hasCompletedSetup'] == true;
  }

  Widget _navigate(BuildContext context, String route) {
    Future.microtask(() {
      Navigator.pushReplacementNamed(context, route);
    });

    return const SizedBox();
  }
}
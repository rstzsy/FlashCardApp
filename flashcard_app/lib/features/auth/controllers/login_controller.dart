import '../../../routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../service/google_auth.dart';

class LoginController extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> signInWithGoogle(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await GoogleSignInService.signInWithGoogle();

      if (userCredential == null || userCredential.user == null) {
        _errorMessage = "Đăng nhập thất bại. Vui lòng thử lại.";
        notifyListeners();
        return;
      }

      final user = userCredential.user!;
      final uid = user.uid;

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      final doc = await userRef.get();
      final data = doc.data();

      await userRef.set({
        'name': user.displayName ?? 'User',
        'email': user.email,
        'photoUrl': user.photoURL,
        'xp': data?['xp'] ?? 0,
        'streak': data?['streak'] ?? 0,
        'level': data?['level'] ?? 1,
        'plants': data?['plants'] ?? 0,
        'hasCompletedSetup': data?['hasCompletedSetup'] ?? false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final hasSetup = data?['hasCompletedSetup'] == true;

      Navigator.pushReplacementNamed(
        context,
        hasSetup
            ? AppRoutes.mainNavigation
            : AppRoutes.initialSetup,
      );
    } catch (e) {
      _errorMessage = "Có lỗi xảy ra. Vui lòng thử lại.";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
import '../../../routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../service/google_auth.dart';
import '../service/biometric_service.dart';

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
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await userRef.get();
      final data = doc.data();

      final existingPhoto = data?['photoUrl'] as String?;
      final photoUrl =
          (existingPhoto != null && existingPhoto.isNotEmpty)
              ? existingPhoto
              : (user.photoURL ?? '');

      await userRef.set({
        'name': user.displayName ?? 'User',
        'email': user.email ?? '',
        'photoUrl': photoUrl,
        'xp': data?['xp'] ?? 0,
        'streak': data?['streak'] ?? 0,
        'level': data?['level'] ?? 1,
        // 'plants' ← XÓA DÒNG NÀY, không được ghi khi login
        'hasCompletedSetup': data?['hasCompletedSetup'] ?? false,
        'hasSeenIntroHome': data?['hasSeenIntroHome'] ?? false,
        'status': data?['status'] ?? 'active',
        'isVerified': data?['isVerified'] ?? false,
        'lastActivityAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // ── Kiểm tra Two-Factor Auth ──────────────────────────────
      final twoFactorEnabled = data?['twoFactorEnabled'] == true;

      if (twoFactorEnabled) {
        _isLoading = false;
        notifyListeners();

        final (authenticated, authError) = await BiometricService.authenticate();

        if (!authenticated) {
          await GoogleSignInService.signOut();
          _errorMessage = authError ?? "Xác thực thất bại. Vui lòng thử lại.";
          notifyListeners();
          return;
        }
      }
      // ──────────────────────────────────────────────────────────

      final hasSetup = data?['hasCompletedSetup'] == true;

      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          hasSetup ? AppRoutes.mainNavigation : AppRoutes.initialSetup,
        );
      }
    } catch (e) {
      _errorMessage = "Có lỗi xảy ra. Vui lòng thử lại.";
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
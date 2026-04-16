import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signInWithGoogle() async {
    try {
      print("👉 [STEP 1] Start Google Sign-In");

      final GoogleSignInAccount? googleUser =
          await _googleSignIn.signIn();

      print("👉 [STEP 2] googleUser: $googleUser");

      if (googleUser == null) {
        print("❌ User cancelled login");
        return null;
      }

      print("👉 Email: ${googleUser.email}");
      print("👉 DisplayName: ${googleUser.displayName}");
      print("👉 ID: ${googleUser.id}");

      final googleAuth = await googleUser.authentication;

      print("👉 [STEP 3] Get Google Auth");
      print("👉 accessToken: ${googleAuth.accessToken}");
      print("👉 idToken: ${googleAuth.idToken}");

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("👉 [STEP 4] Sign in Firebase");

      final userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        print("✅ [STEP 5] Login SUCCESS");

        print("====== USER INFO ======");
        print("UID: ${user.uid}");
        print("Name: ${user.displayName}");
        print("Email: ${user.email}");
        print("PhotoURL: ${user.photoURL}");
        print("Phone: ${user.phoneNumber}");
        print("IsAnonymous: ${user.isAnonymous}");
        print("ProviderData: ${user.providerData}");
        print("=======================");

        await _saveUserToFirestore(user);
      } else {
        print("❌ user is NULL after login");
      }

      return user;
    } catch (e, stackTrace) {
      print("🔥 Login ERROR: $e");
      print("📍 StackTrace: $stackTrace");
      rethrow;
    }
  }

  /// Lưu user vào Firestore
  Future<void> _saveUserToFirestore(User user) async {
    try {
      print("👉 [STEP 6] Save user to Firestore");

      final userRef = _firestore.collection('users').doc(user.uid);

      final doc = await userRef.get();

      if (!doc.exists) {
        print("👉 New user → create");

        await userRef.set({
          "uid": user.uid,
          "name": user.displayName,
          "email": user.email,
          "avatar": user.photoURL,
          "createdAt": FieldValue.serverTimestamp(),
          "role": "user",
        });

        print("✅ User created in Firestore");
      } else {
        print("👉 Existing user → update");

        await userRef.update({
          "name": user.displayName,
          "avatar": user.photoURL,
          "lastLogin": FieldValue.serverTimestamp(),
        });

        print("✅ User updated in Firestore");
      }
    } catch (e) {
      print("🔥 Firestore ERROR: $e");
    }
  }
}
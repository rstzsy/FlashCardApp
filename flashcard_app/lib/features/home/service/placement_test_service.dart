import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlacementTestService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // save placement test result into Firestore for the current user
  static Future<void> saveTestResult({
    required int score,
    required int totalQuestions,
    required String level,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final uid = user.uid;

    await _firestore
        .collection('users')
        .doc(uid)
        .set(
      {
        'placementTestScore': score,
        'placementTestTotal': totalQuestions,
        'placementTestLevel': level,
        'placementTestCompleted': true,
        'placementTestCompletedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // get current user's placement test result from Firestore
  static Future<Map<String, dynamic>?> getTestResult() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      return null;
    }

    final data = doc.data();

    if (data == null ||
        data['placementTestCompleted'] != true) {
      return null;
    }

    return {
      'score': data['placementTestScore'] ?? 0,
      'totalQuestions': data['placementTestTotal'] ?? 0,
      'level': data['placementTestLevel'] ?? 'Unknown',
      'completedAt': data['placementTestCompletedAt'],
    };
  }

  // check if the current user has completed the placement test
  static Future<bool> hasCompletedTest() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    if (!doc.exists) {
      return false;
    }

    final data = doc.data();

    return data?['placementTestCompleted'] == true;
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardManagerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get all flashcard sets của user
  Future<List<Map<String, dynamic>>> getFlashcardSets(String userId) async {
    try {
      final snapshot = await _firestore
          .collection("FlashcardSets")
          .where("UserId", isEqualTo: userId)
          .orderBy("CreatedAt", descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Get FlashcardSets Error: $e");
      return [];
    }
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';

class FlashcardStudyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchFlashcardsBySetId(
    String setId,
  ) async {
    try {
      if (setId.isEmpty) {
        throw Exception("setId is empty");
      }

      print("Fetching Flashcards (service) for setId: $setId");

      final snapshot =
          await _firestore
              .collection("Flashcards")
              .where("SetId", isEqualTo: setId)
              .orderBy("CreatedAt", descending: false)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          "word": data["Word"] ?? data["word"] ?? "",
          "meaning": data["Meaning"] ?? data["meaning"] ?? "",
          "phonetic": data["Phonetic"] ?? data["phonetic"] ?? "",
          "example": data["Example"] ?? data["example"] ?? "",
          "imageUrl": data["imageUrl"] ?? data["ImageUrl"] ?? data["image"] ?? "",
        };
      }).toList();
    } catch (e) {
      print("Service Error: $e");
      return [];
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class WordGardenService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTree({
    required String userId,
    required String setId,
  }) async {
    try {
      // avoid duplicate
      final existing = await _firestore
          .collection("WordGardenTrees")
          .where("UserId", isEqualTo: userId)
          .where("SetId", isEqualTo: setId)
          .get();

      if (existing.docs.isNotEmpty) {
        print("Tree already exists");
        return;
      }

      final doc = _firestore.collection("WordGardenTrees").doc();

      await doc.set({
        "TreeId": doc.id,
        "UserId": userId,
        "SetId": setId,
        "GrowthStage": 0,
        "LastWatered": null,
        "LastFertilized": null,
        "IsMastered": false,
        "CreatedAt": FieldValue.serverTimestamp(),
      });

      print("Seed created successfully");
    } catch (e) {
      print("Error creating tree: $e");
    }
  }
}
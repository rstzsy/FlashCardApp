import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class FlashcardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  // upload image
  Future<String?> uploadCardImage(
      File file, String setId, String cardId) async {
    try {
      final ref = _storage.ref('flashcards/$setId/$cardId.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Upload image error: $e");
      return null;
    }
  }

  // create flashcard set and card
  Future<void> createFlashcardSet({
    required String userId,
    required String title,
    required String subtitle,
    required String icon,
    required String colorHex,
    required List<Map<String, dynamic>> cards,
  }) async {
    if (userId.isEmpty) {
      throw Exception("UserId is empty");
    }

    if (title.trim().isEmpty) {
      throw Exception("Title is empty");
    }

    final String setId = _uuid.v4();

    print("Creating FlashcardSet: $setId");
    print("UserId: $userId");

    // create set
    await _firestore.collection("FlashcardSets").doc(setId).set({
      "SetId": setId,
      "UserId": userId,
      "Title": title,
      "Subtitle": subtitle,
      "Icon": icon,
      "ColorHex": colorHex,
      "TotalCards": cards.length,
      "Difficulty": "Easy",
      "Language": "English",
      "IsPublic": false,
      "IsGeneratedByAI": false,
      "CreatedAt": FieldValue.serverTimestamp(),
      "UpdatedAt": FieldValue.serverTimestamp(),
    });

    // create cards
    for (var card in cards) {
      final String cardId = _uuid.v4();

      if ((card["word"] ?? "").toString().trim().isEmpty ||
          (card["meaning"] ?? "").toString().trim().isEmpty) {
        print("Skip card thieu data");
        continue;
      }

      String? imageUrl;

      if (card["image"] != null && card["image"] is File) {
        imageUrl = await uploadCardImage(
          card["image"],
          setId,
          cardId,
        );
      }

      await _firestore.collection("Flashcards").doc(cardId).set({
        "CardId": cardId,
        "SetId": setId,
        "Word": card["word"],
        "Meaning": card["meaning"],
        "Phonetic": card["phonetic"],
        "Example": card["example"],
        "ImageUrl": imageUrl,
        "Tags": [],
        "IsFavorite": false,
        "CreatedAt": FieldValue.serverTimestamp(),
        "UpdatedAt": FieldValue.serverTimestamp(),
      });

      print("Created card: $cardId");
    }
  }
}
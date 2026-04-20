import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../models/flashcard_form_model.dart';

class FlashcardUpdateService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  //get set
  Future<Map<String, dynamic>> getFlashcardSet(String setId) async {
    final doc =
        await _firestore.collection('FlashcardSets').doc(setId).get();

    return doc.data()!;
  }

  // get card
  Future<List<Map<String, dynamic>>> getFlashcards(String setId) async {
    final snapshot = await _firestore
        .collection('Flashcards')
        .where('SetId', isEqualTo: setId)
        .get();

    return snapshot.docs.map((e) => e.data()).toList();
  }

  // upload image
  Future<String> uploadImage(File file, String setId, String cardId) async {
    final ref = _storage.ref().child('flashcards/$setId/$cardId.jpg');

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  // upload set
  Future<void> updateFlashcardSet({
    required String setId,
    required String title,
    required String subtitle,
    required String icon,
    required String colorHex,
  }) async {
    await _firestore.collection('FlashcardSets').doc(setId).update({
      "Title": title,
      "Subtitle": subtitle,
      "Icon": icon,
      "ColorHex": colorHex,
      "UpdatedAt": FieldValue.serverTimestamp(),
    });
  }

  // update cards
  Future<void> updateFlashcards({
    required String setId,
    required List<FlashcardFormModel> cards,
  }) async {
    final batch = _firestore.batch();

    // get all card
    final snapshot = await _firestore
        .collection('Flashcards')
        .where('SetId', isEqualTo: setId)
        .get();

    final existingDocs = snapshot.docs;

    // get id
    final newIds = cards
        .where((c) => c.id != null)
        .map((c) => c.id!)
        .toSet();

    // delete card not in new list
    for (var doc in existingDocs) {
      if (!newIds.contains(doc.id)) {
        batch.delete(doc.reference);

        /// (optional) remove image in storage
        try {
          final imageUrl = doc.data()['ImageUrl'];
          if (imageUrl != null && imageUrl.toString().isNotEmpty) {
            await _storage.refFromURL(imageUrl).delete();
          }
        } catch (_) {}
      }
    }

    // update
    for (var card in cards) {
      final cardId =
          card.id ?? _firestore.collection('Flashcards').doc().id;

      String? imageUrl = card.imageUrl;

      /// upload ảnh mới nếu có
      if (card.image != null) {
        imageUrl = await uploadImage(card.image!, setId, cardId);
      }

      final ref = _firestore.collection('Flashcards').doc(cardId);

      batch.set(ref, {
        "CardId": cardId,
        "SetId": setId,
        "Word": card.word.text,
        "Meaning": card.meaning.text,
        "Phonetic": card.phonetic.text,
        "Example": card.example.text,
        "ImageUrl": imageUrl ?? "",
        "UpdatedAt": FieldValue.serverTimestamp(),
        "CreatedAt": card.createdAt ?? FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }
}
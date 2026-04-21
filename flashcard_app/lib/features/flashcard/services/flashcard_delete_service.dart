import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FlashcardDeleteService {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<void> deleteFlashcardSet(String setId) async {
    final batch = _firestore.batch();

    // get all flashcard in set
    final cardsSnapshot = await _firestore
        .collection('Flashcards')
        .where('SetId', isEqualTo: setId)
        .get();

    // delete all flashcard and images
    for (var doc in cardsSnapshot.docs) {
      final data = doc.data();
      final imageUrl = data['ImageUrl'];

      // delete image 
      if (imageUrl != null && imageUrl.toString().isNotEmpty) {
        try {
          await _storage.refFromURL(imageUrl).delete();
        } catch (e) {
          // ignore if image deleted
        }
      }

      batch.delete(doc.reference);
    }

    // delete FlashcardSet
    final setRef = _firestore.collection('FlashcardSets').doc(setId);
    batch.delete(setRef);

    await batch.commit();
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../models/flashcard_form_model.dart';
import '../services/flashcard_create_service.dart';

class FlashcardController {
  final FlashcardService _service = FlashcardService();

  Future<void> createFlashcard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<FlashcardFormModel> cards,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      /// check login
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bạn chưa đăng nhập")),
        );
        return;
      }

      print("UID: ${user.uid}");

      // convert UI -> data
      final cardData = cards.map((c) {
        return {
          "word": c.word.text.trim(),
          "meaning": c.meaning.text.trim(),
          "phonetic": c.phonetic.text.trim(),
          "example": c.example.text.trim(),
          "image": c.image,
        };
      }).toList();

      await _service.createFlashcardSet(
        userId: user.uid,
        title: title,
        subtitle: subtitle,
        icon: icon.codePoint.toString(),
        colorHex:
            '#${color.value.toRadixString(16).substring(2)}', // remove alpha
        cards: cardData,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Create success")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("ERROR: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Create failed")),
      );
    }
  }
}
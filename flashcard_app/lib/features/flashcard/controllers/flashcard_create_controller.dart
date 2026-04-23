import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_popup.dart';
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

      // check login
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bạn chưa đăng nhập")),
        );
        return;
      }

      // convert data
      final cardData = cards.map((c) {
        return {
          "word": c.word.text.trim(),
          "meaning": c.meaning.text.trim(),
          "phonetic": c.phonetic.text.trim(),
          "example": c.example.text.trim(),
          "image": c.image,
        };
      }).toList();

      // create
      await _service.createFlashcardSet(
        userId: user.uid,
        title: title,
        subtitle: subtitle,
        icon: icon.codePoint.toString(),
        colorHex: '#${color.value.toRadixString(16).substring(2)}',
        cards: cardData,
      );

      if (!context.mounted) return;

      AppPopup.show(
        context: context,
        title: "Success 🎉",
        message: "Flashcard created successfully!",
        icon: Icons.check_circle,
        iconColor: Colors.green,
        showConfetti: true,
        buttonText: "OK",

        onPressed: () {
          Navigator.pop(context, true); // return result
        },
      );
    } catch (e) {
      debugPrint("ERROR: $e");

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Create failed")),
      );
    }
  }
}
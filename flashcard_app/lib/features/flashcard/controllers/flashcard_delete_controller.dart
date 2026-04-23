import 'package:flutter/material.dart';
import '../services/flashcard_delete_service.dart';

class FlashcardDeleteController {
  final service = FlashcardDeleteService();

  Future<bool> deleteSet(String setId) async {
    try {
      await service.deleteFlashcardSet(setId);
      debugPrint("Delete success");
      return true;
    } catch (e) {
      debugPrint("Delete error: $e");
      return false;
    }
  }
}
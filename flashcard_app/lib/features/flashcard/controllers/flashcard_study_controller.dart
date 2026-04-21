import '../../../models/flashcardModel.dart';
import '../services/flashcard_study_service.dart';

class FlashcardStudyController {
  final FlashcardStudyService _service = FlashcardStudyService();

  Future<List<FlashcardModel>> getFlashcardsBySetId(
      String setId) async {
    try {
      final rawList =
          await _service.fetchFlashcardsBySetId(setId);

      final flashcards = rawList.map((data) {
        return FlashcardModel(
          day: 1,
          level: "Custom",
          imageUrl: data["imageUrl"] ?? "",
          word: data["word"] ?? "",
          meaning: data["meaning"] ?? "",
          phonetic: data["phonetic"] ?? "",
          example: data["example"] ?? "",
        );
      }).toList();

      print("Controller mapped ${flashcards.length} cards");

      return flashcards;
    } catch (e) {
      print("Controller Error: $e");
      return [];
    }
  }
}
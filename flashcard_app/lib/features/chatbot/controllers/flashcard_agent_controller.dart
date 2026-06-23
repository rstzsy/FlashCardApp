import '../../../models/chatModel.dart';

enum FlashcardStep { none, topic, totalCards, difficulty }

class FlashcardAgent {
  FlashcardStep step = FlashcardStep.none;

  String? topic;
  int? totalCards;
  String language = "English";
  String? difficulty;

  void start(List<ChatMessage> messages) {
    step = FlashcardStep.topic;

    messages.add(
      ChatMessage(
        isBot: true,
        message: "What topic would you like to create flashcards for?",
      ),
    );
  }

  bool get isCollecting => step != FlashcardStep.none;

  bool get isCompleted =>
      topic != null && totalCards != null && difficulty != null;

  void reset() {
    step = FlashcardStep.none;
    topic = null;
    totalCards = null;
    difficulty = null;
  }

  void processMessage(String text, List<ChatMessage> messages) {
    switch (step) {
      case FlashcardStep.topic:
        topic = text;

        step = FlashcardStep.totalCards;

        messages.add(
          ChatMessage(
            isBot: true,
            message:
                "Ok! How many flashcards do you want? (Just send a number)",
          ),
        );
        break;

      case FlashcardStep.totalCards:
        totalCards = int.tryParse(text) ?? 10;

        step = FlashcardStep.difficulty;

        messages.add(
          ChatMessage(
            isBot: true,
            message: "Difficulty? (Easy / Medium / Hard)",
          ),
        );
        break;

      case FlashcardStep.difficulty:
        difficulty = text;
        step = FlashcardStep.none;
        break;

      case FlashcardStep.none:
        break;
    }
  }
}

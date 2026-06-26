import '../../../models/chatModel.dart';

enum FlashcardStep { none, topic, totalCards, difficulty }

class FlashcardAgent {
  FlashcardStep step = FlashcardStep.none;

  String? topic;
  int? totalCards;
  String language = "English";
  String? difficulty;

  Future<void> start(
    List<ChatMessage> messages,
    Future<void> Function(ChatMessage) saveMessage,
  ) async {
    step = FlashcardStep.topic;

    final msg = ChatMessage(
      isBot: true,
      message: "What topic would you like to create flashcards for?",
    );

    messages.add(msg);

    await saveMessage(msg);
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

  Future<void> processMessage(
    String text,
    List<ChatMessage> messages,
    Future<void> Function(ChatMessage) saveMessage,
  ) async {
    switch (step) {
      case FlashcardStep.topic:
        topic = text;

        step = FlashcardStep.totalCards;

        final msg = ChatMessage(
          isBot: true,
          message: "Ok! How many flashcards do you want? (Just send a number)",
        );

        messages.add(msg);

        await saveMessage(msg);
        break;

      case FlashcardStep.totalCards:
        totalCards = int.tryParse(text) ?? 10;

        step = FlashcardStep.difficulty;

        final msg = ChatMessage(
          isBot: true,
          message: "Difficulty? (Easy / Medium / Hard)",
        );

        messages.add(msg);

        await saveMessage(msg);
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

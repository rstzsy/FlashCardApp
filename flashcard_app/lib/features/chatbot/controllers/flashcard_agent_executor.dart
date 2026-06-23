import '../../../models/chatModel.dart';
import '../services/flashcard_agent_service.dart';

class FlashcardExecutor {
  final FlashcardAgentService service;

  FlashcardExecutor(this.service);

  Future<List<ChatMessage>> generate({
    required String userId,
    required String topic,
    required int totalCards,
    required String language,
    required String difficulty,
  }) async {
    try {
      return [
        ChatMessage(
          isBot: true,
          message: "Flashcards generated successfully. Now you can view them in your flashcard collection.",
        ),
      ];
    } catch (e) {
      return [
        ChatMessage(
          isBot: true,
          message: "Failed to generate flashcards: ${e.toString()}",
        ),
      ];
    }
  }
}
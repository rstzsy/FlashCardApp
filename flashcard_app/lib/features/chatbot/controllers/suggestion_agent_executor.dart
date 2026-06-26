import '../../../models/chatModel.dart';
import '../services/suggestion_agent_service.dart';

class SuggestionAgentExecutor {
  final SuggestionAgentService service;

  SuggestionAgentExecutor(this.service);

  Future<ChatMessage> generate({
    required String userId,
    required int sessionDuration,
    required int topN,
  }) async {
    try {
      final result = await service.generateSuggestion(
        userId: userId,
        sessionDuration: sessionDuration,
        topN: topN,
      );

      final words = result["suggested_words"] as List?;

      if (words == null || words.isEmpty) {
        return ChatMessage(
          isBot: true,
          message: "No vocabulary suggestions found.",
        );
      }

      return ChatMessage(
        isBot: true,
        message:
            "I found ${words.length} vocabulary cards that you should review today",
        suggestions: words,
      );
    } catch (e) {
      return ChatMessage(
        isBot: true,
        message: "Suggestion failed: $e",
      );
    }
  }
}
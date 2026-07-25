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
      final sessionMeta = result["session_meta"] as Map<String, dynamic>?;
      final note = sessionMeta?["note"] as String?;

      if (words == null || words.isEmpty) {
        return ChatMessage(
          isBot: true,
          message: "No vocabulary suggestions found.",
        );
      }

      final baseMessage =
          "I found ${words.length} vocabulary cards that you should review today";
      final fullMessage = note != null ? "$baseMessage\n\n$note" : baseMessage;

      return ChatMessage(
        isBot: true,
        message: fullMessage,
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
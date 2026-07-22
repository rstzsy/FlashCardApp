import '../../../models/chatModel.dart';

enum SuggestionStep {
  none,
  sessionDuration,
  topN,
}

class SuggestionAgent {
  SuggestionStep step = SuggestionStep.none;

  int? sessionDuration;
  int? topN;

  void start(List<ChatMessage> messages) {
    step = SuggestionStep.sessionDuration;

    messages.add(
      ChatMessage(
        isBot: true,
        message: "How many minutes do you usually study in one session?",
      ),
    );
  }

  bool get isCollecting => step != SuggestionStep.none;

  bool get isCompleted => sessionDuration != null && topN != null;

  void reset() {
    step = SuggestionStep.none;
    sessionDuration = null;
    topN = null;
  }

  /// Returns null if valid, otherwise a (title, message) error.
  ({String title, String message})? processMessage(
    String text,
    List<ChatMessage> messages,
  ) {
    final input = text.trim();

    switch (step) {
      case SuggestionStep.sessionDuration:
        final n = int.tryParse(input);
        if (n == null || n <= 0 || n > 300) {
          return (
            title: "Invalid duration",
            message: "Please enter a valid number of minutes, between 1 and 300.\nExample: 30",
          );
        }

        sessionDuration = n;
        step = SuggestionStep.topN;

        messages.add(
          ChatMessage(
            isBot: true,
            message: "How many vocabulary suggestions do you want?",
          ),
        );
        return null;

      case SuggestionStep.topN:
        final n = int.tryParse(input);
        if (n == null || n <= 0 || n > 50) {
          return (
            title: "Invalid number",
            message: "Please enter a whole number between 1 and 50.\nExample: 10",
          );
        }

        topN = n;
        step = SuggestionStep.none;
        return null;

      case SuggestionStep.none:
        return null;
    }
  }
}
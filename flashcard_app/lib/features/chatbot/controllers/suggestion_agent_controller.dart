import '../../../models/chatModel.dart';

enum SuggestionStep {
  none,
  sessionDuration,
}

class SuggestionAgent {
  // Số lượng gợi ý mặc định khi không còn hỏi người dùng nữa
  static const int defaultTopN = 50;

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
        topN = defaultTopN; // dùng mặc định thay vì hỏi lại
        step = SuggestionStep.none;
        return null;

      case SuggestionStep.none:
        return null;
    }
  }
}
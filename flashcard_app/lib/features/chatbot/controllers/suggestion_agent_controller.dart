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
        message:
            "How many minutes do you usually study in one session?",
      ),
    );
  }

  bool get isCollecting => step != SuggestionStep.none;

  bool get isCompleted =>
      sessionDuration != null &&
      topN != null;

  void reset() {
    step = SuggestionStep.none;
    sessionDuration = null;
    topN = null;
  }

  void processMessage(
    String text,
    List<ChatMessage> messages,
  ) {
    switch (step) {
      case SuggestionStep.sessionDuration:
        sessionDuration = int.tryParse(text) ?? 10;

        step = SuggestionStep.topN;

        messages.add(
          ChatMessage(
            isBot: true,
            message:
                "How many vocabulary suggestions do you want?",
          ),
        );
        break;

      case SuggestionStep.topN:
        topN = int.tryParse(text) ?? 10;

        step = SuggestionStep.none;
        break;

      case SuggestionStep.none:
        break;
    }
  }
}
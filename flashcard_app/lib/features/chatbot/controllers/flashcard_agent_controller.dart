import '../../../models/chatModel.dart';

enum FlashcardStep { none, topic, totalCards, difficulty }

const _validDifficulties = ["easy", "medium", "hard"];

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

  /// Heuristic check for random/gibberish text (e.g. "ahhsdashdkl").
  /// Not perfect, but catches the most common cases of mashing the keyboard.
  bool _looksLikeGibberish(String text) {
    // Only check the letters (ignore numbers, spaces, punctuation).
    final letters = text.replaceAll(RegExp(r'[^a-zA-ZÀ-ỹ]'), '');

    if (letters.isEmpty) return false; // e.g. numbers-only topic, let it pass

    // Rule 1: a long run of letters with no vowel at all is very likely
    // random keyboard mashing (covers Vietnamese vowels too).
    const vowels = 'aeiouyAEIOUYÀ-ỹàáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồ'
        'ốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵ';
    final hasVowel = letters.split('').any((c) => vowels.contains(c));
    if (!hasVowel && letters.length >= 4) return true;

    // Rule 2: 5+ consonants in a row (no vowel in between) — e.g. "hsdashdkl".
    final consonantRun = RegExp(
      r'[^aeiouyAEIOUYÀ-ỹàáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵ\s]{5,}',
    );
    if (consonantRun.hasMatch(letters)) return true;

    return false;
  }

  /// Returns null if the input is valid, otherwise returns a (title, message) error.
  Future<({String title, String message})?> processMessage(
    String text,
    List<ChatMessage> messages,
    Future<void> Function(ChatMessage) saveMessage,
  ) async {
    final input = text.trim();

    switch (step) {
      case FlashcardStep.topic:
        if (input.isEmpty || input.length > 100) {
          return (
            title: "Invalid topic",
            message:
                "Please enter a short topic (max 100 characters).\nExample: \"Animals\", \"Business English\", \"IELTS Vocabulary\"",
          );
        }

        if (_looksLikeGibberish(input)) {
          return (
            title: "This doesn't look like a topic",
            message:
                "Please enter a real topic, e.g. \"Animals\", \"Food\", \"Travel\".",
          );
        }

        topic = input;
        step = FlashcardStep.totalCards;

        final msg = ChatMessage(
          isBot: true,
          message: "Ok! How many flashcards do you want? (Just send a number)",
        );
        messages.add(msg);
        await saveMessage(msg);
        return null;

      case FlashcardStep.totalCards:
        final n = int.tryParse(input);
        if (n == null || n <= 0 || n > 50) {
          return (
            title: "Invalid number",
            message: "Please enter a whole number between 1 and 50.\nExample: 10",
          );
        }

        totalCards = n;
        step = FlashcardStep.difficulty;

        final msg = ChatMessage(
          isBot: true,
          message: "Difficulty? (Easy / Medium / Hard)",
        );
        messages.add(msg);
        await saveMessage(msg);
        return null;

      case FlashcardStep.difficulty:
        if (!_validDifficulties.contains(input.toLowerCase())) {
          return (
            title: "Invalid difficulty",
            message: "Please choose one of: Easy, Medium, Hard.\nExample: \"Medium\"",
          );
        }

        difficulty = input;
        step = FlashcardStep.none;
        return null;

      case FlashcardStep.none:
        return null;
    }
  }
}
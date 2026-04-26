import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/questionModel.dart';
import '../services/compound_word_service.dart';

class CompoundWordController {
  final CompoundWordService _service = CompoundWordService();

  List<QuestionModel> questions = [];
  int currentIndex = 0;
  int score = 0;

  String? sessionId;
  DateTime? startTime;

  final String gameType = "sentence_game";

  // create session
  Future<void> loadQuestions(String setId) async {
    questions = await _service.getQuestionsFromSet(setId);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in");
      return;
    }

    sessionId = await _service.createGameSession(
      userId: user.uid,
      gameType: gameType,
      setId: setId,
      totalQuestions: questions.length,
    );

    startTime = DateTime.now();
  }

  QuestionModel get currentQuestion => questions[currentIndex];

  // check answer
  bool checkAnswer(List<String> selectedWords) {
    String userAnswer = selectedWords.join(" ");
    String correct = currentQuestion.correctSentence;

    bool isCorrect = userAnswer.trim() == correct.trim();

    if (isCorrect) score++;

    return isCorrect;
  }

  // next question and update session
  Future<void> nextQuestion() async {
    if (!isLastQuestion) {
      currentIndex++;

      if (sessionId != null) {
        await _service.updateGameSession(
          sessionId: sessionId!,
          currentIndex: currentIndex,
          score: score,
        );
      }
    }
  }

  bool get isLastQuestion => currentIndex >= questions.length - 1;

  // finish game and save result
  Future<void> finishGame({
    required String setId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || startTime == null) {
      print("Cannot save result (user/startTime null)");
      return;
    }

    int timeSpent =
        DateTime.now().difference(startTime!).inSeconds;

    // save result
    await _service.saveGameResult(
      userId: user.uid,
      gameType: gameType,
      setId: setId,
      score: score,
      total: questions.length,
      timeSpentSeconds: timeSpent,
    );

    // end session
    if (sessionId != null) {
      await _service.endGameSession(sessionId!);
    }
  }

  // reset
  void reset() {
    currentIndex = 0;
    score = 0;
    sessionId = null;
    startTime = null;
  }
}
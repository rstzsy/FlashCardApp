import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/fillQuestionModel.dart';
import '../services/fertilizer_challenge_service.dart';

class FertilizerController {
  final FertilizerService _service = FertilizerService();

  List<FillQuestionModel> questions = [];
  int currentIndex = 0;
  int score = 0;
  String setTitle = '';

  String? sessionId;
  DateTime? startTime;

  final String gameType = "fertilizer_game";

  // load question
  Future<void> loadQuestions(String setId) async {
    // Fetch questions và title song song
    final results = await Future.wait([
      _service.getFillQuestions(setId),
      _service.getSetTitle(setId),
    ]);

    questions = results[0] as List<FillQuestionModel>;
    setTitle  = results[1] as String;

    if (questions.isEmpty) return;

    // create session
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User not logged in — session will not be created");
      startTime = DateTime.now();
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

  // show current question
  FillQuestionModel get currentQuestion => questions[currentIndex];

  bool get isLast => currentIndex >= questions.length - 1;

  // check answer
  bool checkAnswer(String selected) {
    final isCorrect = selected == currentQuestion.correctAnswer;
    if (isCorrect) score++;
    return isCorrect;
  }

  // next question
  Future<void> nextQuestion() async {
    if (!isLast) {
      currentIndex++;

      if (sessionId != null) {
        // do not block UI
        _service.updateGameSession(
          sessionId: sessionId!,
          currentIndex: currentIndex,
          score: score,
        );
      }
    }
  }

  // save result  
  Future<void> finishGame(String setId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || startTime == null) {
      print("Cannot save result: user=$user, startTime=$startTime");
      return;
    }

    final int timeSpent = DateTime.now().difference(startTime!).inSeconds;

    // save result and end session
    await Future.wait([
      _service.saveGameResult(
        userId: user.uid,
        gameType: gameType,
        setId: setId,
        setTitle: setTitle,
        score: score,
        total: questions.length,
        timeSpentSeconds: timeSpent,
      ),
      if (sessionId != null) _service.endGameSession(sessionId!),
    ]);
  }

  
  void reset() {
    currentIndex = 0;
    score = 0;
    sessionId = null;
    startTime = null;
    setTitle = '';
  }
}
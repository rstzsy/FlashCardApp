import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/questionModel.dart';

class CompoundWordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get question from example of flashcard set
  Future<List<QuestionModel>> getQuestionsFromSet(String setId) async {
    try {
      final snapshot = await _firestore
          .collection('Flashcards')
          .where('SetId', isEqualTo: setId)
          .get();

      List<QuestionModel> questions = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        String? example = data['Example'];

        if (example != null && example.trim().isNotEmpty) {
          List<String> words = example.split(" ");
          words.shuffle(Random());

          questions.add(
            QuestionModel(
              correctSentence: example,
              shuffledWords: words,
            ),
          );
        }
      }

      return questions;
    } catch (e) {
      print("Error fetching questions: $e");
      return [];
    }
  }

  // create game session
  Future<String> createGameSession({
    required String userId,
    required String gameType,
    required String setId,
    required int totalQuestions,
  }) async {
    final doc = _firestore.collection('GameSessions').doc();

    await doc.set({
      'SessionId': doc.id,
      'UserId': userId,
      'GameType': gameType,
      'SetId': setId,
      'CurrentQuestionIndex': 0,
      'TotalQuestions': totalQuestions,
      'Score': 0,
      'StartTime': FieldValue.serverTimestamp(),
      'EndTime': null,
    });

    return doc.id;
  }

  // update session after each question
  Future<void> updateGameSession({
    required String sessionId,
    required int currentIndex,
    required int score,
  }) async {
    try {
      await _firestore.collection('GameSessions').doc(sessionId).update({
        'CurrentQuestionIndex': currentIndex,
        'Score': score,
      });
    } catch (e) {
      print("Error updating session: $e");
    }
  }

  // end session
  Future<void> endGameSession(String sessionId) async {
    try {
      await _firestore.collection('GameSessions').doc(sessionId).update({
        'EndTime': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error ending session: $e");
    }
  }

  // save result
  Future<void> saveGameResult({
    required String userId,
    required String gameType,
    required String setId,
    required int score,
    required int total,
    required int timeSpentSeconds,
  }) async {
    try {
      final doc = _firestore.collection('GameResults').doc();

      double accuracy = total == 0 ? 0 : (score / total) * 100;

      int starCount = 0;
      if (score == total) {
        starCount = 3;
      } else if (score >= total * 0.6) {
        starCount = 2;
      } else if (score > 0) {
        starCount = 1;
      }

      await doc.set({
        'ResultId': doc.id,
        'UserId': userId,
        'GameType': gameType,
        'SetId': setId,
        'Score': score,
        'Total': total,
        'StarCount': starCount,
        'Accuracy': accuracy,
        'TimeSpentSeconds': timeSpentSeconds,
        'CompletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error saving result: $e");
    }
  }
}
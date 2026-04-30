import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/fillQuestionModel.dart';

class FertilizerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get title
  Future<String> getSetTitle(String setId) async {
    try {
      final doc = await _firestore
          .collection('FlashcardSets')
          .doc(setId)
          .get();

      if (!doc.exists) return '';
      final data = doc.data();
      return data?['Title'] ?? data?['title'] ?? data?['Name'] ?? '';
    } catch (e) {
      print("Error fetching set title: $e");
      return '';
    }
  }

  // get question
  Future<List<FillQuestionModel>> getFillQuestions(String setId) async {
    try {
      final snapshot = await _firestore
          .collection('Flashcards')
          .where('SetId', isEqualTo: setId)
          .get();

      List<FillQuestionModel> list = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        String? example = data['Example'];
        String? word = data['Word'];

        if (example == null || word == null) continue;

        // replace correct word with blank
        final sentence = _replaceWordWithBlank(example.trim(), word.trim());

        // skip if sentence not found work to blank
        if (!sentence.contains('_____')) continue;

        //create choice 
        final distractors = [
          'make', 'do', 'take', 'get', 'have',
          'bring', 'keep', 'put', 'set', 'turn',
          'show', 'find', 'give', 'call', 'ask',
        ]..shuffle(Random());

        final choices = [word, ...distractors.take(3)]..shuffle(Random());

        list.add(
          FillQuestionModel(
            sentence: sentence,
            correctAnswer: word,
            choices: choices,
            explanation: 'Correct answer is "$word"',
          ),
        );
      }

      return list;
    } catch (e) {
      print("Error fetching questions: $e");
      return [];
    }
  }

  // change word to blank
  String _replaceWordWithBlank(String sentence, String word) {
    final pattern = RegExp(
      r'(?<![a-zA-Z])' + RegExp.escape(word) + r'(?![a-zA-Z])',
      caseSensitive: false,
    );

    if (pattern.hasMatch(sentence)) {
      return sentence.replaceFirst(pattern, '_____');
    }

    // hard replace
    if (sentence.contains(word)) {
      return sentence.replaceFirst(word, '_____');
    }

    return sentence; // not found -> return original
  }

  // create session
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

  // update session
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
    required String setTitle,
    required int score,
    required int total,
    required int timeSpentSeconds,
  }) async {
    try {
      final doc = _firestore.collection('GameResults').doc();

      final double accuracy = total == 0 ? 0 : (score / total) * 100;

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
        'SetTitle': setTitle,
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
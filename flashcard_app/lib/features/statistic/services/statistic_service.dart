import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/statisticModel.dart';
import 'statistic_pdf_service.dart';

class StatisticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<StatisticsModel> getStatistics(String userId) async {
    // study session

    final sessionSnapshot =
        await _firestore
            .collection('StudySessions')
            .where('UserId', isEqualTo: userId)
            .get();

    // save new session for setid
    final Map<String, Map<String, dynamic>> latestSessions = {};

    for (final doc in sessionSnapshot.docs) {
      final data = doc.data();

      final setId = data['SetId'];

      if (setId == null) continue;

      if (!latestSessions.containsKey(setId)) {
        latestSessions[setId] = data;
        continue;
      }

      final currentUpdatedAt =
          (latestSessions[setId]!['UpdatedAt'] as Timestamp?)?.toDate() ??
          DateTime(2000);

      final newUpdatedAt =
          (data['UpdatedAt'] as Timestamp?)?.toDate() ?? DateTime(2000);

      if (newUpdatedAt.isAfter(currentUpdatedAt)) {
        latestSessions[setId] = data;
      }
    }

    // learned word

    int learnedWords = 0;

    for (final item in latestSessions.values) {
      learnedWords += (item['WordsStudied'] ?? 0) as int;
    }

    // total flashcard

    final flashcardsSnapshot = await _firestore.collection('Flashcards').get();

    final totalFlashcards = flashcardsSnapshot.size;

    // memory rate

    double memoryRate = 0;

    if (totalFlashcards > 0) {
      memoryRate = learnedWords / totalFlashcards * 100;
    }

    // weekly progress

    final weeklyProgress = await _buildWeeklyProgress(userId);

    return StatisticsModel(
      learnedWords: learnedWords,
      memoryRate: memoryRate,
      weeklyProgress: weeklyProgress,
    );
  }

  Future<List<int>> _buildWeeklyProgress(String userId) async {
    final now = DateTime.now();

    final startDate = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));

    final snapshot =
        await _firestore
            .collection('StudySessions')
            .where('UserId', isEqualTo: userId)
            .where(
              'StudiedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
            )
            .get();

    final Map<String, int> result = {};

    for (int i = 0; i < 7; i++) {
      final day = startDate.add(Duration(days: i));

      final key = "${day.year}-${day.month}-${day.day}";

      result[key] = 0;
    }

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final studiedAt = (data['StudiedAt'] as Timestamp).toDate();

      final key = "${studiedAt.year}-${studiedAt.month}-${studiedAt.day}";

      result[key] = (result[key] ?? 0) + ((data['WordsStudied'] ?? 0) as int);
    }

    return result.values.toList();
  }

  Future<Map<String, List<DailyStudyData>>> getExportData(String userId) async {
    final sessions =
        await _firestore
            .collection("StudySessions")
            .where("UserId", isEqualTo: userId)
            .get();

    final sets =
        await _firestore
            .collection("FlashcardSets")
            .where("UserId", isEqualTo: userId)
            .get();

    final Map<String, String> setTitles = {};

    for (final doc in sets.docs) {
      final data = doc.data();

      setTitles[data["SetId"]] = data["Title"] ?? "Unknown Set";
    }

    final Map<String, List<DailyStudyData>> result = {};

    for (final doc in sessions.docs) {
      final data = doc.data();

      final setId = data["SetId"];

      final setTitle = setTitles[setId] ?? "Unknown Set";

      final studiedAt = (data["StudiedAt"] as Timestamp).toDate();

      final words = (data["WordsStudied"] ?? 0) as int;

      result.putIfAbsent(setTitle, () => []);

      result[setTitle]!.add(
        DailyStudyData(
          date: "${studiedAt.day}/${studiedAt.month}/${studiedAt.year}",
          wordsLearned: words,
        ),
      );
    }

    return result;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String uid;
  final String name;
  final String? photoUrl;
  final int wordsStudied;
  final double avgAccuracy;
  final double score;
  final int rank;

  LeaderboardEntry({
    required this.uid,
    required this.name,
    this.photoUrl,
    required this.wordsStudied,
    required this.avgAccuracy,
    required this.score,
    required this.rank,
  });
}

class LeaderboardService {
  static final _db = FirebaseFirestore.instance;

  static Future<List<LeaderboardEntry>> getGroupLeaderboard(String groupId) async {

    // ── Round 1: collections + members song song ──────────────────
    final [colSnap, memberSnap] = await Future.wait([
      _db.collection('groups').doc(groupId).collection('collections').get(),
      _db.collection('groups').doc(groupId).collection('members').get(),
    ]);

    final setIds = (colSnap as QuerySnapshot)
        .docs
        .map((d) => ((d.data() as Map)['setId'] ?? '').toString())
        .where((id) => id.isNotEmpty)
        .toSet();

    final uids = (memberSnap as QuerySnapshot).docs.map((d) => d.id).toList();

    if (uids.isEmpty) return [];

    final results = await Future.wait([
      if (setIds.isNotEmpty)
        Future.wait(setIds.map((id) =>
            _db.collection('Flashcards')
               .where('SetId', isEqualTo: id)
               .count().get()))
        .then((snaps) => snaps.fold(0, (sum, s) => sum + (s.count ?? 0)))
      else
        Future.value(0),

      Future.wait(uids.map((uid) => _db.collection('users').doc(uid).get())),

      Future.wait(uids.map((uid) =>
          _db.collection('StudySessions')
             .where('UserId', isEqualTo: uid)
             .get())),

      Future.wait(uids.map((uid) =>
          _db.collection('GameResults')
             .where('UserId', isEqualTo: uid)
             .get())),
    ]);

    final totalWordsInGroup = results[0] as int;
    final userDocs    = results[1] as List<DocumentSnapshot>;
    final studySnaps  = results[2] as List<QuerySnapshot>;
    final gameSnaps   = results[3] as List<QuerySnapshot>;

    final entries = <LeaderboardEntry>[];

    for (int i = 0; i < uids.length; i++) {
      final uid     = uids[i];
      final userDoc = userDocs[i];
      if (!userDoc.exists) continue;

      final userData = userDoc.data() as Map<String, dynamic>;

      final wordsStudied = studySnaps[i].docs
          .where((d) => setIds.contains((d.data() as Map)['SetId']))
          .fold<int>(0, (sum, d) =>
              sum + (((d.data() as Map)['WordsStudied'] as num?) ?? 0).toInt());

      final relevantGames = gameSnaps[i].docs
          .where((d) => setIds.contains((d.data() as Map)['SetId']))
          .toList();

      final avgAccuracy = relevantGames.isEmpty
          ? 0.0
          : relevantGames.fold<double>(0, (sum, d) =>
                sum + (((d.data() as Map)['Accuracy'] as num?) ?? 0).toDouble())
            / relevantGames.length;

      final wordPercent = totalWordsInGroup == 0
          ? 0.0
          : (wordsStudied / totalWordsInGroup).clamp(0.0, 1.0) * 100;

      entries.add(LeaderboardEntry(
        uid: uid,
        name: userData['name'] ?? 'Unknown',
        photoUrl: userData['photoUrl'],
        wordsStudied: wordsStudied,
        avgAccuracy: avgAccuracy,
        score: wordPercent * 0.5 + avgAccuracy * 0.5,
        rank: 0,
      ));
    }

    entries.sort((a, b) => b.score.compareTo(a.score));
    return List.generate(entries.length, (i) => LeaderboardEntry(
      uid:          entries[i].uid,
      name:         entries[i].name,
      photoUrl:     entries[i].photoUrl,
      wordsStudied: entries[i].wordsStudied,
      avgAccuracy:  entries[i].avgAccuracy,
      score:        entries[i].score,
      rank:         i + 1,
    ));
  }
}
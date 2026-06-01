import 'package:cloud_firestore/cloud_firestore.dart';

  class StudyStreakService {
    static final _db = FirebaseFirestore.instance;


    static Future<void> recordStudySession({
    required String userId,
    required int wordsStudied,
    required String setId,
  }) async {
    final now   = DateTime.now();
    final today = _dayKey(now);
    final ref   = _db.collection('StudySessions').doc('${userId}_${setId}_$today');

    await ref.set({
      'SessionId':    ref.id,
      'UserId':       userId,
      'SetId':        setId,
      'StudiedAt':    Timestamp.fromDate(DateTime(now.year, now.month, now.day)),
      'WordsStudied': FieldValue.increment(wordsStudied),
      'UpdatedAt':    FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _updateStreak(userId, now);
  }

  // ─── lấy streak ──────────────────────────────────────────────────────────

  static Future<int> getStreak(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return (doc.data()?['streak'] as int?) ?? 0;
  }



  static Future<List<String>> getCompletedDaysThisWeek(String userId) async {
    final now = DateTime.now();

    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = DateTime(monday.year, monday.month, monday.day);
    final weekEnd   = weekStart.add(const Duration(days: 7));

    final snap = await _db
        .collection('StudySessions')
        .where('UserId', isEqualTo: userId)
        .get();

    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final Set<String> completed = {};

    for (final doc in snap.docs) {
      final ts = doc.data()['StudiedAt'] as Timestamp?;
      if (ts == null) continue;
      final d = ts.toDate().toLocal();
      if (!d.isBefore(weekStart) && d.isBefore(weekEnd)) {
        completed.add(weekdayNames[d.weekday - 1]);
      }
    }

    return completed.toList();
  }

  // ─── internal ─────────────────────────────────────────────────────────────

  static Future<void> _updateStreak(String userId, DateTime now) async {
    final userRef   = _db.collection('users').doc(userId);
    final today     = _dayKey(now);
    final yesterday = _dayKey(now.subtract(const Duration(days: 1)));

    final userSnap = await userRef.get();
    if (!userSnap.exists) return;

    final data          = userSnap.data()!;
    final lastDay       = (data['lastStudyDay'] as String?) ?? '';
    final currentStreak = (data['streak']       as int?)    ?? 0;

    if (lastDay == today) return;

    final newStreak = lastDay == yesterday ? currentStreak + 1 : 1;

    await userRef.update({
      'streak':       newStreak,
      'lastStudyDay': today,
      'updatedAt':    FieldValue.serverTimestamp(),
    });
  }

  static String _dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
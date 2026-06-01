import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecentStudyService {
  static final _db = FirebaseFirestore.instance;

  static Future<List<Map<String, dynamic>>> getRecentSets({int limit = 3}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    // 1. Lấy sessions, sort trong Dart để tránh lỗi index
    final sessionSnap = await _db
        .collection('StudySessions')
        .where('UserId', isEqualTo: uid)
        .get();

    final docs = sessionSnap.docs
        .where((d) => d.data()['SetId'] != null)
        .toList()
      ..sort((a, b) {
        final ta = (a.data()['StudiedAt'] as Timestamp).toDate();
        final tb = (b.data()['StudiedAt'] as Timestamp).toDate();
        return tb.compareTo(ta);
      });

    // 2. Lọc setId không trùng
    final seenIds = <String>{};
    final recentSetIds = <String>[];
    for (final doc in docs) {
      final setId = doc.data()['SetId'] as String;
      if (seenIds.add(setId)) {
        recentSetIds.add(setId);
        if (recentSetIds.length >= limit) break;
      }
    }

    if (recentSetIds.isEmpty) return [];

    // 3. Query FlashcardSets theo field SetId
    final results = <Map<String, dynamic>>[];
    for (final setId in recentSetIds) {
      try {
        final snap = await _db
            .collection('FlashcardSets')
            .where('SetId', isEqualTo: setId)
            .where('UserId', isEqualTo: uid)
            .limit(1)
            .get();

        if (snap.docs.isEmpty) continue;
        final data = snap.docs.first.data();

        results.add({
          'setId':       setId,
          'title':       data['Title']    ?? 'Untitled',
          'description': data['Subtitle'] ?? '',
          'totalCards':  (data['TotalCards'] as num?)?.toInt() ?? 0,
          'colorHex':    data['ColorHex'] ?? '#DCEDC8',
        });
      } catch (_) {}
    }

    return results;
  }
}
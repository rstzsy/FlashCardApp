import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/harvest_achievement_models.dart';

class HarvestAchievementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  
  Future<int> incrementTotalHarvests(String userId) async {
    final userRef = _db.collection('users').doc(userId);

    await userRef.set({
      'totalHarvests': FieldValue.increment(1),
    }, SetOptions(merge: true));

    final snap = await userRef.get();
    return (snap.data()?['totalHarvests'] as int?) ?? 0;
  }

  Future<Set<int>> loadUnlockedThresholds(String userId) async {
    try {
      final snapshot = await _db
          .collection('UserAchievements')
          .where('UserId', isEqualTo: userId)
          .where('Type',   isEqualTo: 'harvest')
          .get();

      return snapshot.docs
          .map((doc) => (doc.data()['Threshold'] as int?) ?? 0)
          .where((t) => t > 0)
          .toSet();
    } catch (e) {
      print('loadUnlockedThresholds error: $e');
      return {};
    }
  }

  Future<void> unlockAchievement({
    required String userId,
    required HarvestAchievement achievement,
  }) async {
    final docId = '${userId}_harvest_${achievement.threshold}';
    try {
      await _db.collection('UserAchievements').doc(docId).set({
        'UserId':     userId,
        'Type':       'harvest',
        'Threshold':  achievement.threshold,
        'Title':      achievement.title,
        'ImagePath':  achievement.imagePath,
        'UnlockedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('unlockAchievement error: $e');
    }
  }

  Future<HarvestAchievement?> checkAndUnlockNewAchievement(
    String userId,
  ) async {
    final userRef = _db.collection('users').doc(userId);
    final beforeSnap = await userRef.get();
    final before = (beforeSnap.data()?['totalHarvests'] as int?) ?? 0;

    final after = await incrementTotalHarvests(userId);

    HarvestAchievement? newlyUnlocked;
    for (final achievement in kHarvestAchievements) {
      if (before < achievement.threshold && after >= achievement.threshold) {
        await unlockAchievement(userId: userId, achievement: achievement);
        newlyUnlocked = achievement; 
      }
    }
    return newlyUnlocked;
  }
}
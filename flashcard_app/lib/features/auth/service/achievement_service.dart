import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/achievementModel.dart';

class AchievementService {
  static const List<int> milestones = [
    10,
    20,
    30,
    50,
    75,
    100,
    150,
    200,
    365,
    500,
  ];

  static List<AchievementBadge> generateBadges(int streak) {
    return milestones.map((milestone) {
      return AchievementBadge(
        image: 'assets/achievement/achievement$milestone.png',
        requiredStreak: milestone,
        unlocked: streak >= milestone,
      );
    }).toList();
  }

  static Future<int?> checkNewAchievement(String uid, int streak) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    final data = doc.data() ?? {};

    final lastAchievement = (data['lastAchievement'] ?? 0) as int;

    int? unlockedBadge;

    for (final milestone in milestones) {
      if (streak >= milestone && milestone > lastAchievement) {
        unlockedBadge = milestone;
      }
    }

    if (unlockedBadge != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'lastAchievement': unlockedBadge,
      });
    }

    return unlockedBadge;
  }
}

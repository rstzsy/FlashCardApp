class AchievementBadge {
  final String image;
  final int requiredStreak;
  final bool unlocked;

  const AchievementBadge({
    required this.image,
    required this.requiredStreak,
    required this.unlocked,
  });
}
class HarvestAchievement {
  final int    threshold;   
  final String imagePath;   
  final String title;      

  const HarvestAchievement({
    required this.threshold,
    required this.imagePath,
    required this.title,
  });
}

const List<HarvestAchievement> kHarvestAchievements = [
  HarvestAchievement(
    threshold: 10,
    imagePath: 'assets/harvest_achievement/achievement_harvest_10.png',
    title: 'First Steps',
  ),
  HarvestAchievement(
    threshold: 25,
    imagePath: 'assets/harvest_achievement/achievement_harvest_25.png',
    title: 'Budding Gardener',
  ),
  HarvestAchievement(
    threshold: 50,
    imagePath: 'assets/harvest_achievement/achievement_harvest_50.png',
    title: 'Green Thumb',
  ),
  HarvestAchievement(
    threshold: 100,
    imagePath: 'assets/harvest_achievement/achievement_harvest_100.png',
    title: 'Dedicated Grower',
  ),
  HarvestAchievement(
    threshold: 250,
    imagePath: 'assets/harvest_achievement/achievement_harvest_250.png',
    title: 'Seed Starter',
  ),
  HarvestAchievement(
    threshold: 500,
    imagePath: 'assets/harvest_achievement/achievement_harvest_500.png',
    title: 'Garden Keeper',
  ),
  HarvestAchievement(
    threshold: 750,
    imagePath: 'assets/harvest_achievement/achievement_harvest_750.png',
    title: 'Diligent Farmer',
  ),
  HarvestAchievement(
    threshold: 1000,
    imagePath: 'assets/harvest_achievement/achievement_harvest_1000.png',
    title: 'Harvest Master',
  ),
  HarvestAchievement(
    threshold: 2500,
    imagePath: 'assets/harvest_achievement/achievement_harvest_2500.png',
    title: 'Garden Expert',
  ),
  HarvestAchievement(
    threshold: 5000,
    imagePath: 'assets/harvest_achievement/achievement_harvest_5000.png',
    title: 'Garden Legend',
  ),
  HarvestAchievement(
    threshold: 10000,
    imagePath: 'assets/harvest_achievement/achievement_harvest_10000.png',
    title: 'Garden King',
  ),
  HarvestAchievement(
    threshold: 25000,
    imagePath: 'assets/harvest_achievement/achievement_harvest_25000.png',
    title: 'Grand Sage of the Garden',
  ),
];

HarvestAchievement? harvestAchievementForThreshold(int threshold) {
  for (final a in kHarvestAchievements) {
    if (a.threshold == threshold) return a;
  }
  return null;
}
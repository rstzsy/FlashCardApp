import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../models/harvest_achievement_models.dart';
import '../services/harvest_achievement_service.dart';

class HarvestAchievementSection extends StatefulWidget {
  final int? totalHarvests;

  const HarvestAchievementSection({super.key, this.totalHarvests});

  @override
  State<HarvestAchievementSection> createState() =>
      _HarvestAchievementSectionState();
}

class _HarvestAchievementSectionState
    extends State<HarvestAchievementSection> {
  final HarvestAchievementService _service = HarvestAchievementService();

  bool _isLoading = true;
  Set<int> _unlockedThresholds = {};

  @override
  void initState() {
    super.initState();
    _loadUnlockedThresholds();
  }

  Future<void> _loadUnlockedThresholds() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    final unlocked = await _service.loadUnlockedThresholds(uid);
    if (mounted) {
      setState(() {
        _unlockedThresholds = unlocked;
        _isLoading          = false;
      });
    }
  }


  bool _isUnlocked(int threshold) {
    if (_unlockedThresholds.contains(threshold)) return true;
    if (widget.totalHarvests != null && widget.totalHarvests! >= threshold) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Harvest Achievements",
            style: TextStyle(
              color: AppColors.highlightColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: kHarvestAchievements.length,
                    itemBuilder: (context, index) {
                      final achievement = kHarvestAchievements[index];
                      final isUnlocked  = _isUnlocked(achievement.threshold);

                      return GestureDetector(
                        onTap: () => _showDetail(achievement, isUnlocked),
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: const BoxDecoration(
                                  color: Colors.white10,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: ColorFiltered(
                                    colorFilter: isUnlocked
                                        ? const ColorFilter.mode(
                                            Colors.transparent,
                                            BlendMode.multiply,
                                          )
                                        : const ColorFilter.matrix([
                                            0.2126, 0.7152, 0.0722, 0, 0,
                                            0.2126, 0.7152, 0.0722, 0, 0,
                                            0.2126, 0.7152, 0.0722, 0, 0,
                                            0, 0, 0, 1, 0,
                                          ]),
                                    child: Image.asset(
                                      achievement.imagePath,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${achievement.threshold}',
                                style: TextStyle(
                                  color: isUnlocked
                                      ? AppColors.highlightColor
                                      : AppColors.highlightColor
                                          .withOpacity(0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDetail(HarvestAchievement achievement, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: isUnlocked ? 1 : 0.4,
              child: Image.asset(
                achievement.imagePath,
                width: 90,
                height: 90,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              achievement.title,
              style: const TextStyle(
                color: AppColors.highlightColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isUnlocked
                  ? 'Unlocked! You harvested ${achievement.threshold} plants.'
                  : 'Harvest ${achievement.threshold} plants to unlock.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.highlightColor),
            ),
          ],
        ),
      ),
    );
  }
}
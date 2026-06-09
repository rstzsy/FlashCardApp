import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../services/leaderboard_service.dart';

class UserItemWidget extends StatelessWidget {
  final LeaderboardEntry entry;
  const UserItemWidget({super.key, required this.entry});

  Color _getBackgroundColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color.fromARGB(255, 247, 234, 160);
      case 3: return const Color.fromARGB(255, 252, 234, 216);
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor(entry.rank);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: (entry.photoUrl != null && entry.photoUrl!.isNotEmpty)
                ? NetworkImage(entry.photoUrl!) as ImageProvider
                : const AssetImage('assets/character/bored.png'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  "${entry.score.toStringAsFixed(1)}%  •  ${entry.wordsStudied} words  •  ${entry.avgAccuracy.toStringAsFixed(0)}% acc",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          _RankBadge(rank: entry.rank),
        ],
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  static const Map<int, String> _medals = {
    2: 'assets/component/2nd-place.png',
    3: 'assets/component/3rd-place.png',
  };

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final medal = _medals[rank];
    if (medal != null) {
      return Image.asset(medal, width: 36, height: 36, fit: BoxFit.contain);
    }
    return Container(
      width: 36, height: 36,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        rank.toString(),
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}
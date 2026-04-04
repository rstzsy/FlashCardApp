import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../screens/group_leader_board_screen.dart';

class UserItemWidget extends StatelessWidget {
  final User user;

  const UserItemWidget({super.key, required this.user});

  // background for rank
  Color _getBackgroundColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); 
      case 2:
        return const Color.fromARGB(255, 247, 234, 160); 
      case 3:
        return const Color.fromARGB(255, 252, 234, 216);
      default:
        return Colors.white;
    }
  }

  Color _getTextColor(int rank) {
    return rank <= 3 ? Colors.black : Colors.black87;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor(user.rank);
    final textColor = _getTextColor(user.rank);

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
          UserAvatar(avatar: user.avatar),
          const SizedBox(width: 12),
          Expanded(
            child: UserInfo(user: user, textColor: textColor),
          ),
          RankBadge(rank: user.rank),
        ],
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  final String avatar;

  const UserAvatar({super.key, required this.avatar});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 22,
      backgroundImage: NetworkImage(avatar),
    );
  }
}

class UserInfo extends StatelessWidget {
  final User user;
  final Color textColor;

  const UserInfo({super.key, required this.user, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user.name,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          "${user.percent}% completed",
          style: TextStyle(
            color: textColor.withOpacity(0.6),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class RankBadge extends StatelessWidget {
  final int rank;
  static const Map<int, String> _medalAssets = {
    2: 'assets/component/2nd-place.png',
    3: 'assets/component/3rd-place.png',
  };

  const RankBadge({super.key, required this.rank});

  @override
  Widget build(BuildContext context) {
    final medalPath = _medalAssets[rank];

    if (medalPath != null) {
      return Image.asset(
        medalPath,
        width: 36,
        height: 36,
        fit: BoxFit.contain,
      );
    }

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        rank.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';
import '../screens/setting_screen.dart';

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProfileHeader({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.mainColor],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      child: Column(
        children: [
          // HEADER BAR
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),

              /// 🔥 NAME
              Text(
                data['name'] ?? 'User',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: AppColors.highlightColor,
                  letterSpacing: 0.3,
                ),
              ),

              _SettingsButton(),
            ],
          ),

          const SizedBox(height: 20),

          /// 🔥 AVATAR + LEVEL
          _AvatarWithBadge(data: data),

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64B4D2).withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.settings_rounded,
          color: AppColors.highlightColor,
          size: 25,
        ),
      ),
    );
  }
}

class _AvatarWithBadge extends StatelessWidget {
  final Map<String, dynamic> data;

  const _AvatarWithBadge({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = data['photoUrl'];
    final level = data['level'] ?? 1;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// GRADIENT BORDER
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.highlightColor, AppColors.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.highlightColor.withOpacity(0.35),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(3),

          /// AVATAR
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage:
                  (photoUrl != null && photoUrl != '')
                      ? NetworkImage(photoUrl)
                      : const AssetImage("assets/character/amaz.png")
                          as ImageProvider,
            ),
          ),
        ),

        /// LEVEL BADGE
        Positioned(
          bottom: 0,
          right: -4,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.highlightColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.mainColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.highlightColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              "Lv $level",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
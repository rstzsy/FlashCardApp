import 'dart:math';
import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class LeaderboardHeader extends StatelessWidget {
  const LeaderboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const BackButtonWidget(),

          const Expanded(child: TitleWidget()),

          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.highlightColor),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}

class TitleWidget extends StatelessWidget {
  const TitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      "Leaderboard",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.highlightColor,
      ),
    );
  }
}

class AvatarWithCrown extends StatelessWidget {
  const AvatarWithCrown({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.bottomCenter,
            child: CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage('assets/character/bored.png'),
            ),
          ),

          // Crown image
          Positioned(
            top: 0,
            left: 0,
            child: Transform.rotate(
              angle: -15 * pi / 180, // nghien ve ben trai 15 do
              child: Image.asset('assets/component/crown.png', width: 45),
            ),
          ),
        ],
      ),
    );
  }
}

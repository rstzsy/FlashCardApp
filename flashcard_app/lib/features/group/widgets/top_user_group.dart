import 'dart:math';
import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';
import '../../../core/themes/app_colors.dart';

class TopUserWidget extends StatelessWidget {
  final LeaderboardEntry entry;
  const TopUserWidget({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AvatarWithCrown(photoUrl: entry.photoUrl),
        const SizedBox(height: 10),
        Text(
          entry.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "${entry.wordsStudied} words  •  ${entry.avgAccuracy.toStringAsFixed(0)}% accuracy",
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 92, 233, 165),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "${entry.score.toStringAsFixed(1)}% score",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class AvatarWithCrown extends StatelessWidget {
  final String? photoUrl;
  const AvatarWithCrown({super.key, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 110,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: CircleAvatar(
              radius: 45,
              backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                  ? NetworkImage(photoUrl!) as ImageProvider
                  : const AssetImage('assets/character/bored.png'),
            ),
          ),
          Positioned(
            top: 0, left: 0,
            child: Transform.rotate(
              angle: -15 * pi / 180,
              child: Image.asset('assets/component/crown.png', width: 45),
            ),
          ),
        ],
      ),
    );
  }
}
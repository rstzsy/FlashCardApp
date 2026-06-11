import 'package:flutter/material.dart';
import '../screens/statistic_screen.dart';
import 'palette.dart';
import 'ring_ava.dart';

class HeroCard extends StatelessWidget {
  final bool isHappy;
  final double memoryRate;
  const HeroCard({required this.isHappy, required this.memoryRate});

  @override
  Widget build(BuildContext context) {
    final sprite =
        isHappy ? 'assets/character/happy.png' : 'assets/character/worry.png';
    final accent = isHappy ? P.green : P.pink;
    final accentDk = isHappy ? P.greenDark : P.pinkDark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: P.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -8,
            right: 16,
            child: Blob(size: 60, color: accent.withOpacity(0.25)),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Blob(size: 36, color: P.purple.withOpacity(0.30)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RingAvatar(
                  sprite: sprite,
                  percent: memoryRate / 100,
                  ringColor: accent,
                  size: 90,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHappy ? "You're amazing!" : "Keep going!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: accentDk,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isHappy
                            ? "Great memory rate today"
                            : "Study a bit more today",
                        style: const TextStyle(
                          fontSize: 13,
                          color: P.textSub,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isHappy ? 'GOOD' : 'NEEDS WORK',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: accentDk,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
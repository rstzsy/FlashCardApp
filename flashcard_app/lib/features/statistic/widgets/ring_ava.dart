import 'package:flutter/material.dart';
import 'palette.dart';

class RingAvatar extends StatelessWidget {
  final String sprite;
  final double percent;
  final Color ringColor;
  final double size;
  const RingAvatar({
    required this.sprite,
    required this.percent,
    required this.ringColor,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percent,
              strokeWidth: 5,
              backgroundColor: ringColor.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(ringColor),
              strokeCap: StrokeCap.round,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: ringColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${(percent * 100).round()}%',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              sprite,
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) =>
                      const Icon(Icons.person, size: 40, color: P.textSub),
            ),
          ),
        ],
      ),
    );
  }
}
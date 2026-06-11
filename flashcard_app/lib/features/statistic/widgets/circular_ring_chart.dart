import 'package:flutter/material.dart';
import 'palette.dart';

class CircularRingChart extends StatelessWidget {
  final double percent; 
  final double size;

  const CircularRingChart({required this.percent, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // background track
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 14,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(const Color(0xFFF1EFE8)),
              strokeCap: StrokeCap.round,
            ),
          ),
          // pink arc (left half - represents not yet)
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 0.5,
              strokeWidth: 14,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation(P.pink),
              strokeCap: StrokeCap.round,
            ),
          ),
          // purple arc (right half - represents memory rate)
          Transform.rotate(
            angle: 3.14159, // 180°
            child: SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: percent * 0.5, // a half of circle
                strokeWidth: 14,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation(P.purple),
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          // center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Today',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: P.text,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Memory\nRate',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: P.textSub, height: 1.3),
              ),
            ],
          ),
          // percent badge (right of circle)
          Positioned(
            right: 0,
            top: size / 2 - 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: P.purple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${(percent * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
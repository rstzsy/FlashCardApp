import 'package:flutter/material.dart';
import '../services/fsrs_service.dart';

class FsrsRatingButtons extends StatelessWidget {
  final void Function(FsrsRating rating) onRate;

  const FsrsRatingButtons({super.key, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'How well did you remember?',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFFB36B6A),
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _RatingButton(
              label: 'Again',
              sublabel: '< 1m',
              color: const Color(0xFFFF6B6B),
              textColor: Colors.white,
              onTap: () => onRate(FsrsRating.again),
            ),
            const SizedBox(width: 5),
            _RatingButton(
              label: 'Hard',
              sublabel: '< 5m',
              color: const Color(0xFFFF9F43),
              textColor: Colors.white,
              onTap: () => onRate(FsrsRating.hard),
            ),
            const SizedBox(width: 5),
            _RatingButton(
              label: 'Good',
              sublabel: '~10m',
              color: const Color(0xFF26DE81),
              textColor: Colors.white,
              onTap: () => onRate(FsrsRating.good),
            ),
            const SizedBox(width: 5),
            _RatingButton(
              label: 'Easy',
              sublabel: '4+ days',
              color: const Color(0xFF45AAF2),
              textColor: Colors.white,
              onTap: () => onRate(FsrsRating.easy),
            ),
          ],
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _RatingButton({
    required this.label,
    required this.sublabel,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 6), // 10 → 6
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12, // 14 → 12
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  fontSize: 9, // 10 → 9
                  color: textColor.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

class KidsProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const KidsProgressBar({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = current / total;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          // decoration: BoxDecoration(
          //   color: const Color.fromARGB(255, 251, 247, 214),
          //   shape: BoxShape.circle,
          // ),
          child: Image.asset(
            'assets/component/star.png',
            width: 30,
            height: 30,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 18,
              color: AppColors.primary,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color.fromARGB(255, 247, 239, 198),AppColors.gold],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(999)),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "$current/$total",
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: Color.fromARGB(255, 12, 43, 83),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'color_game.dart';


class AvailableWordChip extends StatelessWidget {
  final String word;
  final ChipColorData colorData;
  final VoidCallback onTap;

  const AvailableWordChip({
    super.key,
    required this.word,
    required this.colorData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: colorData.bg,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: colorData.shadow,
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          word,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: colorData.text,
          ),
        ),
      ),
    );
  }
}
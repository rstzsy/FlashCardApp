import 'package:flutter/material.dart';

class FlashcardStudyFooter extends StatelessWidget {
  final int current;
  final int total;

  const FlashcardStudyFooter({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      "$current / $total",
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFFB36B6A),
        letterSpacing: 0.5,
      ),
    );
  }
}
import 'package:flutter/material.dart';

class SegmentBar extends StatelessWidget {
  final double percent;
  final Color color;
  final double height;
  const SegmentBar({
    required this.percent,
    required this.color,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    const total = 7;
    final filled = (percent * total).round().clamp(0, total);
    return Row(
      children: List.generate(total, (i) {
        final active = i < filled;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: height,
            decoration: BoxDecoration(
              color: active ? color : color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
      }),
    );
  }
}
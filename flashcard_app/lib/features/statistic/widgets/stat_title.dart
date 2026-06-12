import 'package:flutter/material.dart';
import 'palette.dart';

class StatTile extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color accent;
  final Color accentDark;
  const StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.accentDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: P.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                icon,
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) =>
                        Icon(Icons.bar_chart, color: accentDark, size: 22),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: accentDark,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: P.textSub,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
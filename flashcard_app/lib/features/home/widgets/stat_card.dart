import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String imagePath;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.imagePath,
  });

  // color for each image
  Color _getAccentColor() {
    if (imagePath.contains('book')) return const Color(0xFF4F8EF7);
    if (imagePath.contains('fire')) return const Color(0xFFFF6B35);
    if (imagePath.contains('star')) return const Color(0xFFFFBF00);
    if (imagePath.contains('plant')) return const Color(0xFF3EC97C);
    return const Color(0xFF4F8EF7);
  }

  Color _getBgColor() {
    if (imagePath.contains('book')) return const Color(0xFFEEF4FF);
    if (imagePath.contains('fire')) return const Color(0xFFFFF2EC);
    if (imagePath.contains('star')) return const Color(0xFFFFFBEC);
    if (imagePath.contains('plant')) return const Color(0xFFEDFBF3);
    return const Color(0xFFEEF4FF);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _getAccentColor();
    final bgColor = _getBgColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // mini image
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(10),
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),

          // value
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1A2E),
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 10),

              // Accent bar
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: 0.6,
                  minHeight: 3,
                  backgroundColor: accent.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
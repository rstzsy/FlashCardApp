import 'package:flutter/material.dart';

class ChibiStatCard extends StatelessWidget {
  final String iconPath;
  final String value;
  final String label;
  final Color color;
  final List<Color> bgGradient;

  const ChibiStatCard({
    super.key,
    required this.iconPath,
    required this.value,
    required this.label,
    required this.color,
    required this.bgGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: bgGradient,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(iconPath, width: 32, height: 32),
          const SizedBox(height: 6),
          // value
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          // label
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
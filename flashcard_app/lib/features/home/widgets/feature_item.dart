import 'package:flutter/material.dart';

class FeatureItem extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;

  const FeatureItem({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          height: 65,
          width: 85,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class DashedSeparator extends StatelessWidget {
  const DashedSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 130,
      child: Image.asset(
        "assets/component/dashed_line.png",
        color: const Color.fromARGB(255, 1, 117, 179),
        fit: BoxFit.fitHeight,
      ),
    );
  }
}
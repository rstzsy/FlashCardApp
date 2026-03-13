import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';

class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key});

  Widget item(String image, String text) {
    return Row(
      children: [
        Image.asset(image, width: 25, height: 25),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Color.fromARGB(255, 84, 144, 172),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overview",
            style: TextStyle(
              color: AppColors.highlightColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 15),

          GridView.count(
            crossAxisCount: 2, // 2 column
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 30,
            childAspectRatio: 4,
            children: [
              item("assets/component/fire.png", "303 days"),
              item("assets/component/plant.png", "1 plant"),
              item("assets/component/trophy1.png", "Best Remember"),
              item("assets/component/star.png", "9429 XP"),
            ],
          ),
        ],
      ),
    );
  }
}

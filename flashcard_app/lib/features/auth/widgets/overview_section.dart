import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class OverviewSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const OverviewSection({
    super.key,
    required this.data,
  });

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
    final streak = data['streak'] ?? 0;
    final plants = data['plants'] ?? 0;
    final xp = data['xp'] ?? 0;

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
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 30,
            childAspectRatio: 4,
            children: [
              item("assets/component/fire.png", "$streak days"),
              item("assets/component/plant.png", "$plants plant"),
              item("assets/component/trophy1.png", "Best Remember"),
              item("assets/component/star.png", "$xp XP"),
            ],
          ),
        ],
      ),
    );
  }
}
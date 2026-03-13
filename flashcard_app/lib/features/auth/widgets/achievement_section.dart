import 'package:flutter/material.dart';

import '../../../core/themes/app_colors.dart';

class AchievementSection extends StatelessWidget {
  const AchievementSection({super.key});

  final List<String> images = const [
    "assets/achievement/victory.png",
    "assets/achievement/victory.png",
    "assets/achievement/victory.png",
    "assets/achievement/victory.png",
    "assets/achievement/victory.png",
    "assets/achievement/victory.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Achievement",
            style: TextStyle(color: AppColors.highlightColor, fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      images[index],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
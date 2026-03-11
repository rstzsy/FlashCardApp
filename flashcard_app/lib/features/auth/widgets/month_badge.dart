import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class MonthlyBadgeSection extends StatelessWidget {
  const MonthlyBadgeSection({super.key});

  final List<String> badges = const [
    "assets/badge/hope.png",
    "assets/badge/hope.png",
    "assets/badge/hope.png",
    "assets/badge/hope.png",
    "assets/badge/hope.png",
    "assets/badge/hope.png",
  ];

  final List<bool> achieved = const [
    true,
    true,
    false,
    false,
    false,
    true,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Monthly Badges",
            style: TextStyle(
              color: AppColors.highlightColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: badges.length,
              itemBuilder: (context, index) {

                final isUnlocked = achieved[index];

                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: ColorFiltered(
                      colorFilter: isUnlocked
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.multiply,
                            )
                          : const ColorFilter.matrix([
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0.2126, 0.7152, 0.0722, 0, 0,
                              0, 0, 0, 1, 0,
                            ]),
                      child: Image.asset(
                        badges[index],
                        fit: BoxFit.cover,
                      ),
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
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class OverviewSection extends StatelessWidget {
  final Map<String, dynamic> data;

  const OverviewSection({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final streak = data['streak'] ?? 0;
    final plants = data['plants'] ?? 0;
    final stars  = data['stars'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Overview",
            style: TextStyle(
              color: AppColors.highlightColor,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 14),

          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.3,
            ),
            children: [
              _overviewCard(
                image: "assets/component/fire.png",
                title: "Streak",
                value: "$streak Days",
                bgColor: const Color(0xFFFFE5CC),
                rotation: -0.38, 
                imageOffset: const Offset(-10, 4),
              ),
              _overviewCard(
                image: "assets/component/plant.png",
                title: "Plants",
                value: "$plants Trees",
                bgColor: const Color(0xFFD6F5DA),
                rotation: 0.31, 
                imageOffset: const Offset(-8, 2),
              ),
              _overviewCard(
                image: "assets/component/trophy1.png",
                title: "Memory",
                value: "Best",
                bgColor: const Color(0xFFFFF0C0),
                rotation: -0.26,  
                imageOffset: const Offset(-10, 6),
                smallValue: true,
              ),
              _overviewCard(
                image: "assets/component/star.png",
                title: "Stars",
                value: "$stars",
                bgColor: const Color(0xFFDEE7FF),
                rotation: 0.25,   
                imageOffset: const Offset(-6, 2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewCard({
    required String image,
    required String title,
    required String value,
    required Color bgColor,
    required double rotation,
    required Offset imageOffset,
    bool smallValue = false,
  }) {
    const double imageSize = 72;
    const double cardHeight = 62;
    const double wrapHeight = 80;

    return SizedBox(
      height: wrapHeight,
      child: Stack(
        clipBehavior: Clip.none, 
        children: [
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: cardHeight,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.only(
                left: 66, right: 12, top: 8, bottom: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: smallValue ? 13 : 16,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2F4C5B),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: imageOffset.dx,
            bottom: imageOffset.dy,
            child: Transform.rotate(
              angle: rotation,
              child: Image.asset(
                image,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
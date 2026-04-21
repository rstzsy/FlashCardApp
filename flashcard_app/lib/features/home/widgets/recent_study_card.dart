import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class RecentStudyCard extends StatelessWidget {
  final String title;
  final String description;
  final int totalCards;
  final int learnedCards;
  final String imagePath;
  final Color bgColor;
  final VoidCallback onTap;

  const RecentStudyCard({super.key, 
    required this.title,
    required this.description,
    required this.totalCards,
    required this.learnedCards,
    required this.imagePath,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Background watermark image
            Positioned(
              right: -2,
              child: Opacity(
                opacity: 0.25,  
                child: Image.asset(
                  imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  color: Colors.white,  
                  colorBlendMode: BlendMode.srcIn,  
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.55),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Cards count
                    Row(
                      children: [
                        Icon(Icons.style_rounded, size: 16, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(
                          "$totalCards",
                          style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // Views / learned
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.black45),
                        const SizedBox(width: 4),
                        Text(
                          "$learnedCards",
                          style: const TextStyle(fontSize: 13, color: Colors.black54, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Button
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.highlightColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
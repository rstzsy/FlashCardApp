import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class CollectionList extends StatelessWidget {
  const CollectionList({super.key});

  @override
  Widget build(BuildContext context) {
    final collections = [
      _CollectionData(
        name: "Japanese",
        username: "@amaz",
        totalCards: 24,
        learnedCards: 10,
        image: "assets/component/book_watermark.png",
        bgColor: const Color(0xFFDCEDC8),
      ),
      _CollectionData(
        name: "English Basic",
        username: "@gerasimova",
        totalCards: 40,
        learnedCards: 18,
        image: "assets/component/book_watermark.png",
        bgColor: const Color(0xFFB2EBF2),
      ),
      _CollectionData(
        name: "IELTS Master",
        username: "@anatoly",
        totalCards: 55,
        learnedCards: 30,
        image: "assets/component/book_watermark.png",
        bgColor: const Color(0xFFFFE0B2),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: collections
            .map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CollectionCard(data: c, onTap: () {}),
                ))
            .toList(),
      ),
    );
  }
}

class _CollectionData {
  final String name;
  final String username;
  final int totalCards;
  final int learnedCards;
  final String image;
  final Color bgColor;

  const _CollectionData({
    required this.name,
    required this.username,
    required this.totalCards,
    required this.learnedCards,
    required this.image,
    required this.bgColor,
  });
}

class _CollectionCard extends StatelessWidget {
  final _CollectionData data;
  final VoidCallback? onTap;

  const _CollectionCard({required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: data.bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -2,
              child: Opacity(
                opacity: 0.25,
                child: Image.asset(
                  data.image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  data.username,
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
                    const Icon(Icons.style_rounded,
                        size: 16, color: Colors.black45),
                    const SizedBox(width: 4),
                    Text(
                      '${data.totalCards}',
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.remove_red_eye_outlined,
                        size: 16, color: Colors.black45),
                    const SizedBox(width: 4),
                    Text(
                      '${data.learnedCards}',
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),

                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.highlightColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Start',
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
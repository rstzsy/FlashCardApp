import 'package:flutter/material.dart';

class CollectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int setsCount;
  final Color color;

  const CollectionCard({
    required this.title,
    required this.subtitle,
    required this.setsCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const double cardWidth  = 200;
    const double tabHeight  = 18;
    const double bodyRadius = 18.0;

    return SizedBox(
      width: cardWidth,
      height: 140,
      child: Stack(
        children: [
          // ── Tab nhỏ góc trên trái ──
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 72,
              height: tabHeight + 4, 
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),
          ),

          Positioned(
            top: tabHeight,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(bodyRadius),
                  bottomLeft: Radius.circular(bodyRadius),
                  bottomRight: Radius.circular(bodyRadius),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // ── thay Text('✏️') bằng Icon màu vàng ──
                                const Icon(
                                  Icons.edit_rounded,
                                  size: 14,
                                  color: Color(0xFFFFD600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.80),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.more_vert_rounded,
                          size: 18, color: Colors.white.withOpacity(0.90)),
                      const SizedBox(width: 4),
                      Icon(Icons.settings_rounded,
                          size: 16, color: Colors.white.withOpacity(0.90)),
                    ],
                  ),

                  const Spacer(),

                  // ── Số lượng dưới cùng ──
                  Text(
                    "$setsCount sets of flashcard",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.90),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
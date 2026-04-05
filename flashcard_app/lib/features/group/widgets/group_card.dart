import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../../../models/groupModel.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap;

  const GroupCard({super.key, required this.group, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: group.bgColor ?? const Color(0xFFDFF2EB),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // ── Watermark ảnh góc phải ──────────────────────────
            Positioned(
              right: -2,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(
                  group.image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  color: Colors.white,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),
            ),

            // ── Nội dung ────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên nhóm
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                // Mô tả (nếu có)
                Text(
                  group.description ?? 'Nhóm học tập cùng nhau',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black.withOpacity(0.55),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Row bottom: số thành viên + nút
                Row(
                  children: [
                    // Số thành viên
                    const Icon(Icons.group_rounded,
                        size: 16, color: Colors.black45),
                    const SizedBox(width: 4),
                    Text(
                      '${group.memberCount} members',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    // Nút Join / View
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
                          'Join',
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
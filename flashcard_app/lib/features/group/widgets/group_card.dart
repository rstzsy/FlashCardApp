import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';
import '../models/group_model.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GroupCard({
    super.key,
    required this.group,
    this.onTap,
    this.onLongPress,
  });

  Stream<int> _memberCountStream(String groupId) {
    if (groupId.isEmpty) return Stream.value(0);
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('members')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(group.bgColor ?? const Color(0xFFDFF2EB).value),
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
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

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

                Row(
                  children: [
                    const Icon(Icons.group_rounded,
                        size: 16, color: Colors.black45),
                    const SizedBox(width: 4),

                    // ── Stream member count thực tế ──
                    StreamBuilder<int>(
                      stream: _memberCountStream(group.id ?? ''),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? group.memberCount;
                        return Text(
                          '$count members',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
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
import 'package:flutter/material.dart';


class ChatHistoryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const ChatHistoryItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEF3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Color(0xFFB85C7A),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: hasSubtitle
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF444444),
                  ),
                ),

                if (hasSubtitle) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Time + indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (!hasSubtitle) ...[
                const SizedBox(height: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFB85C7A),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
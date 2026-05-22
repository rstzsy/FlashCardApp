import 'package:flutter/material.dart';

class ChatbotOptionMenu extends StatelessWidget {
  const ChatbotOptionMenu({
    super.key,
    required this.onHistoryTap,
  });

  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),

      onSelected: (value) {
        if (value == "history") {
          onHistoryTap();
        }
      },

      itemBuilder: (context) => [
        const PopupMenuItem(
          value: "history",
          child: Row(
            children: [
              Icon(Icons.history_rounded),

              SizedBox(width: 10),

              Text("History"),
            ],
          ),
        ),
      ],
    );
  }
}
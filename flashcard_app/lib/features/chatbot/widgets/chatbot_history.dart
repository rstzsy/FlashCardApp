import 'package:flashcard_app/features/chatbot/widgets/chatbot_item_history.dart';
import 'package:flashcard_app/features/chatbot/widgets/delete_conversation_dialog.dart';
import 'package:flutter/material.dart';
import '../controllers/chat_history_controller.dart';

class ChatHistory extends StatefulWidget {
  final ChatHistoryController controller;
  final Function(String conversationId)? onSelectConversation;

  const ChatHistory({
    super.key,
    required this.controller,
    this.onSelectConversation,
  });

  @override
  State<ChatHistory> createState() => _ChatHistoryState();
}

class _ChatHistoryState extends State<ChatHistory> {
  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  String formatTime(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) {
      return "Just now";
    }

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} mins ago";
    }

    if (diff.inHours < 24) {
      return "${diff.inHours} hours ago";
    }

    if (diff.inDays == 1) {
      return "Yesterday";
    }

    return "${diff.inDays} days ago";
  }

  @override
  Widget build(BuildContext context) {
    final histories = widget.controller.histories;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFFFFFAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),

          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Chat History",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7A4E5D),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child:
                histories.isEmpty
                    ? const Center(child: Text("No chat history yet"))
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: histories.length,
                      itemBuilder: (context, index) {
                        final item = histories[index];

                        return Dismissible(
                          key: Key(item.id),

                          direction: DismissDirection.endToStart,

                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),

                          confirmDismiss: (direction) async {
                            return await DeleteConversationDialog.show(
                              context,
                              title: item.title,
                              subtitle: item.lastMessage,
                            );
                          },

                          onDismissed: (_) async {
                            await widget.controller.deleteHistory(item.id);
                          },

                          child: GestureDetector(
                            onTap: () {
                              widget.onSelectConversation?.call(item.id);

                              Navigator.pop(context);
                            },
                            child: ChatHistoryItem(
                              title: item.title,
                              subtitle: item.lastMessage,
                              time: formatTime(item.updatedAt),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

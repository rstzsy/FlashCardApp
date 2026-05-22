import 'package:flutter/material.dart';

import '../widgets/chatbot_history.dart';
import '../widgets/chatbot_menu_option.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> messages = [
    {
      "isBot": true,
      "message":
          "Hi there! I'm your Mofu Assistant!\nWhat would you like to do today?",
      "options": [
        "Create flashcards",
        "Suggest vocabulary",
        "Study plan",
        "Grammar practice",
      ],
    },
  ];

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      messages.add({"isBot": false, "message": text});

      messages.add({
        "isBot": true,
        "message":
            "That sounds great \nI'm preparing something helpful for you!",
      });
    });

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 200), () {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  Widget buildMessage(Map<String, dynamic> msg) {
    final bool isBot = msg["isBot"];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isBot) ...[
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              backgroundImage: const AssetImage('assets/component/chatbot.png'),
            ),
            const SizedBox(width: 10),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment:
                  isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isBot
                            ? const Color(0xFFFFF1F3)
                            : const Color(0xFFD6ECFF),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isBot ? 6 : 20),
                      bottomRight: Radius.circular(isBot ? 20 : 6),
                    ),
                  ),
                  child: Text(
                    msg["message"],
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF444444),
                    ),
                  ),
                ),

                // options
                if (msg["options"] != null) ...[
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate((msg["options"] as List).length, (
                      index,
                    ) {
                      final option = msg["options"][index];

                      return GestureDetector(
                        onTap: () => sendMessage(option),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: const Color(0xFFFFC9D7)),
                          ),
                          child: Text(
                            option,
                            style: const TextStyle(
                              color: Color(0xFFB85C7A),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAFC),
      // header
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFDCE6),
        foregroundColor: const Color(0xFF7A4E5D),
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/component/chatbot.png'),
            ),
            SizedBox(width: 10),
            Text(
              "Mofu Assistants",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),

        actions: [
          ChatbotOptionMenu(
            onHistoryTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const ChatHistory(),
              );
            },
          ),
        ],
      ),

      // chatbot body
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return buildMessage(messages[index]);
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type your message...",
                        hintStyle: TextStyle(color: Color(0xFFB0B0B0)),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: () => sendMessage(_controller.text),
                  child: Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB6C9),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

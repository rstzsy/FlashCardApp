class ChatMessage {
  final String message;
  final bool isBot;
  final List<String>? options;
  final String? fileUrl;
  final List<dynamic>? suggestions;

  ChatMessage({
    required this.message,
    required this.isBot,
    this.options,
    this.suggestions,
    this.fileUrl,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'] ?? '',
      isBot: json['isBot'] ?? true,
      options:
          json['options'] != null
              ? List<String>.from(json['options'])
              : null,
    );
  }
}
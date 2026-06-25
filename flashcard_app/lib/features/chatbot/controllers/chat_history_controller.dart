import 'package:flutter/material.dart';

import '../../../models/chatHistoryModel.dart';
import '../../../models/chatModel.dart';
import '../services/chat_history_service.dart';

class ChatHistoryController extends ChangeNotifier {
  final ChatHistoryService _service = ChatHistoryService();

  String? currentConversationId;

  List<ChatHistoryModel> histories = [];

  Future<void> startConversation({
    required String userId,
    required String firstMessage,
  }) async {
    currentConversationId = await _service.createConversation(
      userId: userId,
      firstMessage: firstMessage,
    );

    await loadHistories(userId);
  }

  Future<void> updateConversation(String message) async {
    if (currentConversationId == null) return;

    await _service.updateConversation(
      conversationId: currentConversationId!,
      lastMessage: message,
    );
  }

  Future<void> loadHistories(String userId) async {
    histories = await _service.getHistories(userId);

    notifyListeners();
  }

  Future<void> deleteHistory(String conversationId) async {
    await _service.deleteConversation(conversationId);

    histories.removeWhere((e) => e.id == conversationId);

    notifyListeners();
  }

  Future<void> addUserMessage(String message) async {
    if (currentConversationId == null) return;

    await _service.addMessage(
      conversationId: currentConversationId!,
      message: message,
      isBot: false,
    );
  }

  Future<void> addBotMessage(String message) async {
    if (currentConversationId == null) return;

    await _service.addMessage(
      conversationId: currentConversationId!,
      message: message,
      isBot: true,
    );
  }

  Future<void> addMessage(ChatMessage message) async {
    if (currentConversationId == null) return;

    await _service.addChatMessage(
      conversationId: currentConversationId!,
      chatMessage: message,
    );
  }

  Future<List<ChatMessage>> loadConversation(String conversationId) async {
    return await _service.getConversationMessages(conversationId);
  }

  void resetConversation() {
    currentConversationId = null;
  }
}

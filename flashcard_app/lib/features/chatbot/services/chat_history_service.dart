import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/chatHistoryModel.dart';
import '../../../models/chatModel.dart';

class ChatHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _historyRef =>
      _firestore.collection("chat_histories");

  Future<String> createConversation({
    required String userId,
    required String firstMessage,
  }) async {
    final doc = _historyRef.doc();

    await doc.set({
      "id": doc.id,
      "userId": userId,
      "title": firstMessage,
      "messages": [
        {"message": firstMessage, "isBot": false, "createdAt": Timestamp.now()},
      ],
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> updateConversation({
    required String conversationId,
    required String lastMessage,
  }) async {
    await _historyRef.doc(conversationId).update({
      "lastMessage": lastMessage,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<List<ChatHistoryModel>> getHistories(String userId) async {
    final snapshot =
        await _historyRef
            .where("userId", isEqualTo: userId)
            .orderBy("updatedAt", descending: true)
            .get();

    return snapshot.docs.map((doc) {
      return ChatHistoryModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> deleteConversation(String conversationId) async {
    await _historyRef.doc(conversationId).delete();
  }

  Future<void> addMessage({
    required String conversationId,
    required String message,
    required bool isBot,
  }) async {
    await _historyRef.doc(conversationId).update({
      "messages": FieldValue.arrayUnion([
        {"message": message, "isBot": isBot, "createdAt": Timestamp.now()},
      ]),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> addChatMessage({
    required String conversationId,
    required ChatMessage chatMessage,
  }) async {
    await _historyRef.doc(conversationId).update({
      "messages": FieldValue.arrayUnion([
        {
          "message": chatMessage.message,
          "isBot": chatMessage.isBot,
          "fileUrl": chatMessage.fileUrl,
          "suggestions": chatMessage.suggestions,
          "options": chatMessage.options,
          "createdAt": Timestamp.now(),
        },
      ]),
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  Future<List<ChatMessage>> getConversationMessages(
    String conversationId,
  ) async {
    final doc = await _historyRef.doc(conversationId).get();

    if (!doc.exists) return [];

    final data = doc.data() as Map<String, dynamic>;

    final List<dynamic> messages = data["messages"] ?? [];

    return messages.map((e) {
      return ChatMessage(
        isBot: e["isBot"] ?? false,
        message: e["message"],
        options: e["options"] != null ? List<String>.from(e["options"]) : null,
        fileUrl: e["fileUrl"],
        suggestions: e["suggestions"],
      );
    }).toList();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatHistoryModel {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatHistoryModel({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatHistoryModel(
      id: json["id"] ?? "",
      title: json["title"] ?? "",
      lastMessage: json["lastMessage"] ?? "",
      createdAt: (json["createdAt"] as Timestamp).toDate(),
      updatedAt: (json["updatedAt"] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "lastMessage": lastMessage,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }

  ChatHistoryModel copyWith({
    String? id,
    String? title,
    String? lastMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatHistoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      lastMessage: lastMessage ?? this.lastMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../config/env.dart';

enum ChatAgentType {
  flashcard,
  vocabulary,
  studyPlan,
}

class ChatbotService {

  String get flashcardUrl => Env.flashcardBaseUrl;
  String get roadmapUrl => Env.roadmapBaseUrl;
  String get suggestUrl => Env.suggestBaseUrl;

  

  Future<String> sendMessage({
    required String message,
    required ChatAgentType agentType,
    String? userId,
  }) async {
    String url;
    Map<String, dynamic> body;

    switch (agentType) {
      case ChatAgentType.flashcard:
        url = "$flashcardUrl/ai/generate-flashcards";
        print("flashcard url: " + Env.flashcardBaseUrl);

        body = {
          "message": message,
        };
        break;

      case ChatAgentType.vocabulary:
        url = "$suggestUrl/api/v1/suggest-vocabulary";

        body = {
          "message": message,
        };
        break;

      case ChatAgentType.studyPlan:
        if (userId == null) {
          throw Exception("userId is required for studyPlan");
        }

        url = "$roadmapUrl/roadmap/generate/$userId";
        print("Roadmap url:  " + Env.roadmapBaseUrl);

        body = {
          "message": message,
        };
        break;
    }

    final response = await http.post(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data["answer"]?.toString() ??
          data["message"]?.toString() ??
          response.body;
    }

    throw Exception(
      "API Error ${response.statusCode}: ${response.body}",
    );
  }
}
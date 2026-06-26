import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../config/env.dart';

class FlashcardAgentService {
  String get baseUrl => Env.flashcardBaseUrl;

  Future<dynamic> generateFlashcards({
    required String userId,
    required String topic,
    required int totalCards,
    required String language,
    required String difficulty,
  }) async {
    final url = Uri.parse("$baseUrl/ai/generate-flashcards");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "topic": topic,
        "totalCards": totalCards,
        "language": language,
        "difficulty": difficulty,
      }),
    );

    print("URL: $url");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("API Error: ${response.body}");
  }
}
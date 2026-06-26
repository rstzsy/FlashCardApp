import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../config/env.dart';

class SuggestionAgentService {
  String get baseUrl => Env.suggestBaseUrl;

  Future<dynamic> suggestVocabulary({required String userId}) async {
    final uri = Uri.parse(
      "$baseUrl/api/v1/suggest-vocabulary",
    ).replace(queryParameters: {"user_id": userId});

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception(response.body);
  }

  Future<dynamic> generateSuggestion({
    required String userId,
    required int sessionDuration,
    required int topN,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/v1/suggest-vocabulary"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "userId": userId,
        "sessionDuration": sessionDuration,
        "topN": topN,
      }),
    );

    print(response.statusCode);
    print(response.body);

    return jsonDecode(response.body);
  }
}

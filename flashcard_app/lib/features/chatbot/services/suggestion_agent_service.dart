import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../../../config/env.dart';

class SuggestionAgentService {
  String get baseUrl => Env.suggestBaseUrl;

  Future<dynamic> suggestVocabulary({required String userId}) async {
    final uri = Uri.parse(
      "$baseUrl/api/v1/suggest-vocabulary",
    ).replace(queryParameters: {"user_id": userId});

    try {
      final response = await http
          .post(
            uri,
            headers: {"Content-Type": "application/json"},
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException(
                "Suggest vocabulary timed out after 60s",
              );
            },
          );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception(response.body);
    } on TimeoutException {
      throw Exception(
        "Suggestion is taking longer than expected. Please try again shortly.",
      );
    } on http.ClientException catch (e) {
      throw Exception("Connection error: ${e.message}");
    }
  }

  Future<dynamic> generateSuggestion({
    required String userId,
    required int sessionDuration,
    required int topN,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$baseUrl/api/v1/suggest-vocabulary"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "userId": userId,
              "sessionDuration": sessionDuration,
              "topN": topN,
            }),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw TimeoutException(
                "Generate suggestion timed out after 60s",
              );
            },
          );

      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      throw Exception("API Error: ${response.body}");
    } on TimeoutException {
      throw Exception(
        "Suggestion is taking longer than expected. Please try again shortly.",
      );
    } on http.ClientException catch (e) {
      throw Exception("Connection error: ${e.message}");
    }
  }
}
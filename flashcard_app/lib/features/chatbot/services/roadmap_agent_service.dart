import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../config/env.dart';

class RoadMapService {
  String get baseUrl => Env.roadmapBaseUrl;

  Future<dynamic> generateRoadmap({required String userId}) async {
    final uri = Uri.parse(
      "$baseUrl/roadmap/generate",
    ).replace(queryParameters: {"user_id": userId});

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({}), 
    );

    print("URL: $uri");
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Roadmap API Error: ${response.body}");
  }
}

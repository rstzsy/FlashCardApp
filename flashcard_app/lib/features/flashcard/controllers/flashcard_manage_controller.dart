import 'package:flutter/material.dart';

import '../services/flashcard_manage_service.dart';

class FlashcardManagerController {
  final FlashcardManagerService _service = FlashcardManagerService();

  // load data
  Future<List<Map<String, dynamic>>> loadFlashcardSets(String userId) async {
    final data = await _service.getFlashcardSets(userId);

    // convert Firestore -> UI model
    return data.map((e) {
      return {
        "setId": e["SetId"],
        "title": e["Title"] ?? "",
        "subtitle": e["Subtitle"] ?? "",
        "color": _hexToColor(e["ColorHex"]),
        "icon": _iconFromString(e["Icon"]),
        "totalCards": e["TotalCards"] ?? 0,
      };
    }).toList();
  }

  // convert hex -> Color
  Color _hexToColor(String? hex) {
    if (hex == null || hex.isEmpty) {
      return const Color(0xFFE9B4B3);
    }

    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));

    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // convert string -> IconData
  IconData _iconFromString(String? iconCode) {
    if (iconCode == null) return Icons.menu_book;

    return IconData(int.parse(iconCode), fontFamily: 'MaterialIcons');
  }
}

import 'dart:io';
import 'package:flutter/material.dart';

class FlashcardFormModel {
  TextEditingController word;
  TextEditingController meaning;
  TextEditingController phonetic;
  TextEditingController example;
  File? image;
  String? id;
  String? imageUrl;
  dynamic createdAt;

  FlashcardFormModel({
    required this.word,
    required this.meaning,
    required this.phonetic,
    required this.example,
    this.image,
    this.id,
    this.imageUrl,
    this.createdAt,
  });

  factory FlashcardFormModel.empty() {
    return FlashcardFormModel(
      word: TextEditingController(),
      meaning: TextEditingController(),
      phonetic: TextEditingController(),
      example: TextEditingController(),
    );
  }

  factory FlashcardFormModel.fromMap(Map<String, dynamic> data) {
    return FlashcardFormModel(
      id: data['CardId'],
      word: TextEditingController(text: data['Word'] ?? ''),
      meaning: TextEditingController(text: data['Meaning'] ?? ''),
      phonetic: TextEditingController(text: data['Phonetic'] ?? ''),
      example: TextEditingController(text: data['Example'] ?? ''),
      imageUrl: data['ImageUrl'] ?? data['imageUrl'],
      createdAt: data['CreatedAt'],
    );
  }

  void dispose() {
    word.dispose();
    meaning.dispose();
    phonetic.dispose();
    example.dispose();
  }
}

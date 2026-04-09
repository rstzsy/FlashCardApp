import 'dart:io';
import 'package:flutter/material.dart';

class FlashcardFormModel {
  TextEditingController word;
  TextEditingController meaning;
  TextEditingController phonetic;
  TextEditingController example;
  File? image;

  FlashcardFormModel({
    required this.word,
    required this.meaning,
    required this.phonetic,
    required this.example,
    this.image,
  });

  factory FlashcardFormModel.empty() {
    return FlashcardFormModel(
      word: TextEditingController(),
      meaning: TextEditingController(),
      phonetic: TextEditingController(),
      example: TextEditingController(),
    );
  }
}
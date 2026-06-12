import '../features/flashcard/models/flashcard_fsrs_data.dart';

class FlashcardModel {
  final String id; 
  final int day;
  final String level;
  final String imageUrl;
  final String word;
  final String phonetic;
  final String meaning;
  final String example;

  final FlashcardFsrsData? fsrsData;

  FlashcardModel({
    required this.id,
    required this.day,
    required this.level,
    required this.imageUrl,
    required this.word,
    required this.phonetic,
    required this.meaning,
    required this.example,
    this.fsrsData,
  });

  FlashcardModel copyWith({FlashcardFsrsData? fsrsData}) {
    return FlashcardModel(
      id: id,
      day: day,
      level: level,
      imageUrl: imageUrl,
      word: word,
      phonetic: phonetic,
      meaning: meaning,
      example: example,
      fsrsData: fsrsData ?? this.fsrsData,
    );
  }
}
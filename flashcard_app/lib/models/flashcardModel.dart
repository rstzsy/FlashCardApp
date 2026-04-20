class FlashcardModel {
  final int day;
  final String level;
  final String imageUrl;
  final String word;       
  final String phonetic;  
  final String meaning;
  final String example;

  FlashcardModel({
    required this.day,
    required this.level,
    required this.imageUrl,
    required this.word,
    required this.phonetic,
    required this.meaning,
    required this.example,
  });
}
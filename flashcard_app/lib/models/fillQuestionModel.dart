class FillQuestionModel {
  final String sentence;
  final String correctAnswer;
  final List<String> choices;
  final String explanation;

  FillQuestionModel({
    required this.sentence,
    required this.correctAnswer,
    required this.choices,
    required this.explanation,
  });
}
class StatisticsModel {
  final int learnedWords;
  final double memoryRate;
  final List<int> weeklyProgress;

  const StatisticsModel({
    required this.learnedWords,
    required this.memoryRate,
    required this.weeklyProgress,
  });
}
import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../../models/questionModel.dart';
import '../widgets/answer_zone.dart';
import '../widgets/available_word_ship.dart';
import '../widgets/check_button.dart';
import '../widgets/color_game.dart';
import '../widgets/feedback_game.dart';
import '../widgets/progress_bar.dart';
import 'score_game_screen.dart';

class SentenceGameScreen extends StatefulWidget {
  const SentenceGameScreen({super.key});

  @override
  State<SentenceGameScreen> createState() => _SentenceGameScreenState();
}

class _SentenceGameScreenState extends State<SentenceGameScreen> {
  int currentIndex = 0;
  int score = 0;
  List<String> selectedWords = [];
  List<String> availableWords = [];
  late List<QuestionModel> questions;

  @override
  void initState() {
    super.initState();
    questions = _mockData();
    availableWords = [...questions[0].shuffledWords];
  }

  // fake data
  List<QuestionModel> _mockData() {
    List<String> sentences = [
      "I love Flutter",
      "She is very happy",
      "We are learning English for the following test",
      "This is a beautiful day",
      "He likes playing football",
    ];
    return sentences.map((sentence) {
      List<String> words = sentence.split(" ");
      words.shuffle(Random());
      return QuestionModel(correctSentence: sentence, shuffledWords: words);
    }).toList();
  }

  void onWordTap(int index) {
    setState(() {
      selectedWords.add(availableWords[index]);
      availableWords.removeAt(index);
    });
  }

  void removeWord(int index) {
    setState(() {
      availableWords.add(selectedWords[index]);
      selectedWords.removeAt(index);
    });
  }

  void checkAnswer() {
    String userAnswer = selectedWords.join(" ");
    String correct = questions[currentIndex].correctSentence;
    bool isCorrect = userAnswer == correct;
    if (isCorrect) score++;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder:
          (_) => FeedbackOverlay(
            isCorrect: isCorrect,
            correctSentence: correct,
            isLast: currentIndex >= questions.length - 1,
            onNext: () {
              Navigator.pop(context);
              nextQuestion();
            },
          ),
    );
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedWords.clear();
        availableWords = [...questions[currentIndex].shuffledWords];
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScoreScreen(score: score, total: questions.length),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress
                    Row(
                      children: [
                        _circleButton(
                          icon: Icons.arrow_back,
                          onPressed: () => Navigator.pop(context),
                        ),

                        const SizedBox(width: 10),

                        // Progress bar
                        Expanded(
                          child: KidsProgressBar(
                            current: currentIndex + 1,
                            total: questions.length,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Question label
                    Row(
                      children: const [
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            "Arrange them into the correct sentence!",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.highlightColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 60),

                    // word answer
                    Expanded(
                      child: AnswerZone(
                        selectedWords: selectedWords,
                        onRemove: removeWord,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            final word = selectedWords.removeAt(oldIndex);
                            selectedWords.insert(newIndex, word);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // bottom
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Available words
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(availableWords.length, (i) {
                        final color = kChipColors[i % kChipColors.length];
                        return AvailableWordChip(
                          word: availableWords[i],
                          colorData: color,
                          onTap: () => onWordTap(i),
                        );
                      }),
                    ),

                    // Check button
                    CheckButton(
                      enabled: selectedWords.isNotEmpty,
                      onPressed: checkAnswer,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
        ],
      ),
      margin: EdgeInsets.all(6),
      child: IconButton(
        icon: Icon(icon, color: AppColors.highlightColor),
        onPressed: onPressed,
      ),
    );
  }
}

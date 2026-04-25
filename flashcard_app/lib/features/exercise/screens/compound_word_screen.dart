import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../models/questionModel.dart';
import '../controllers/compound_word_controller.dart';
import '../widgets/answer_zone.dart';
import '../widgets/available_word_ship.dart';
import '../widgets/check_button.dart';
import '../widgets/color_game.dart';
import '../widgets/feedback_game.dart';
import '../widgets/progress_bar.dart';
import 'score_game_screen.dart';

class SentenceGameScreen extends StatefulWidget {
  final String setId;

  const SentenceGameScreen({super.key, required this.setId});

  @override
  State<SentenceGameScreen> createState() => _SentenceGameScreenState();
}

class _SentenceGameScreenState extends State<SentenceGameScreen> {
  final CompoundWordController controller = CompoundWordController();

  int currentIndex = 0;
  int score = 0;
  List<String> selectedWords = [];
  List<String> availableWords = [];
  List<QuestionModel> questions = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // get data
  Future<void> loadData() async {
    await controller.loadQuestions(widget.setId);

    if (controller.questions.isEmpty) {
      // avoid crashes if no questions
      setState(() {
        isLoading = false;
      });
      return;
    }

    setState(() {
      questions = controller.questions;
      availableWords = [...questions[0].shuffledWords];
      isLoading = false;
    });
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
    bool isCorrect = controller.checkAnswer(selectedWords);
    score = controller.score;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (_) => FeedbackOverlay(
        isCorrect: isCorrect,
        correctSentence: controller.currentQuestion.correctSentence,
        isLast: controller.isLastQuestion,
        onNext: () {
          Navigator.pop(context);
          nextQuestion();
        },
      ),
    );
  }

  Future<void> nextQuestion() async {
    if (!controller.isLastQuestion) {
      await controller.nextQuestion();

      setState(() {
        currentIndex = controller.currentIndex;
        selectedWords.clear();
        availableWords = [...controller.currentQuestion.shuffledWords];
      });
    } else {
      // save result
      await controller.finishGame(
        setId: widget.setId,
      );

      // next level
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScoreScreen(
            score: controller.score,
            total: controller.questions.length,
            setId: widget.setId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("No questions available")),
      );
    }

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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Arrange them into the correct sentence!",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.highlightColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 60),

                    // answer zone
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
      margin: const EdgeInsets.all(6),
      child: IconButton(
        icon: Icon(icon, color: AppColors.highlightColor),
        onPressed: onPressed,
      ),
    );
  }
}
import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_popup.dart';
import '../../../models/flashcardModel.dart';
import '../../exercise/screens/compound_word_screen.dart';
import '../widgets/flashcard_study_card.dart';
import '../widgets/flashcard_study_control.dart';
import '../widgets/flashcard_study_footer.dart';
import '../widgets/flashcard_study_header.dart';

class FlashcardStudyScreen extends StatefulWidget {
  const FlashcardStudyScreen({super.key});

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  final List<FlashcardModel> flashcards = [
    FlashcardModel(
      day: 3,
      level: "IELTS Vocabulary",
      image: "assets/component/calendar.png",
      word: "Dog",
      meaning: "A domesticated animal often kept as a pet",
      phonetic: "/dɒg/",
      example: "The dog is running in the park.",
    ),
    FlashcardModel(
      day: 3,
      level: "IELTS Vocabulary",
      image: "assets/component/calendar.png",
      word: "Cat",
      meaning: "A small domesticated animal with soft fur",
      phonetic: "/kæt/",
      example: "The cat is sleeping on the sofa.",
    ),
    FlashcardModel(
      day: 3,
      level: "IELTS Vocabulary",
      image: "assets/component/calendar.png",
      word: "Bird",
      meaning: "An animal with feathers and wings",
      phonetic: "/bɜ:d/",
      example: "The bird is flying in the sky.",
    ),
  ];

  int currentIndex = 0;

  void nextCard() {
    if (currentIndex < flashcards.length - 1) {
      setState(() => currentIndex++);
    } else {
      AppPopup.show(
        context: context,
        title: "Congratulation!",
        message: "You studied all flashcards",
        icon: Icons.emoji_events,
        iconColor: Colors.amber,
        buttonText: "Again",
        onPressed: () {
          setState(() {
            currentIndex = 0;
          });
        },
      );
    }
  }

  void prevCard() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final flashcard = flashcards[currentIndex];

    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SafeArea(
        child: Column(
          children: [
            const FlashcardStudyHeader(),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: FlashcardStudyCard(
                        key: ValueKey(currentIndex),
                        flashcard: flashcard,
                      ),
                    ),

                    const SizedBox(height: 16),

                    FlashcardStudyFooter(
                      current: currentIndex + 1,
                      total: flashcards.length,
                    ),

                    const SizedBox(height: 16),

                    FlashcardStudyControls(onNext: nextCard, onBack: prevCard),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SentenceGameScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF7D6D5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Let Practices",
                          style: TextStyle(
                            color: Color(0xFF7A3333),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_popup.dart';
import '../../../models/flashcardModel.dart';
import '../../exercise/screens/compound_word_screen.dart';
import '../controllers/flashcard_study_controller.dart';
import '../widgets/flashcard_study_card.dart';
import '../widgets/flashcard_study_control.dart';
import '../widgets/flashcard_study_footer.dart';
import '../widgets/flashcard_study_header.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final String setId;

  const FlashcardStudyScreen({
    super.key,
    required this.setId,
  });

  @override
  State<FlashcardStudyScreen> createState() =>
      _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  final FlashcardStudyController controller =
      FlashcardStudyController();

  late Future<List<FlashcardModel>> futureCards;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    futureCards =
        controller.getFlashcardsBySetId(widget.setId);
  }

  void nextCard(int total) {
    if (currentIndex < total - 1) {
      setState(() => currentIndex++);
    } else {
      AppPopup.show(
        context: context,
        title: "Congratulation!",
        message: "You studied all flashcards",
        iconWidget: Image.asset(
          'assets/component/trophy1.png',
          width: 150,
          height: 150,
        ),
        buttonText: "Again",
        showConfetti: true,
        onPressed: () {
          setState(() => currentIndex = 0);
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
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SafeArea(
        child: Column(
          children: [
            const FlashcardStudyHeader(),

            // load data
            Expanded(
              child: FutureBuilder<List<FlashcardModel>>(
                future: futureCards,
                builder: (context, snapshot) {
                  // loading
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }

                  // error
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}"),
                    );
                  }

                  final flashcards = snapshot.data ?? [];

                  // empty
                  if (flashcards.isEmpty) {
                    return const Center(
                      child: Text("No flashcards found"),
                    );
                  }

                  final flashcard =
                      flashcards[currentIndex];

                  return Padding(
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

                        FlashcardStudyControls(
                          onNext: () =>
                              nextCard(flashcards.length),
                          onBack: prevCard,
                        ),

                        const SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SentenceGameScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFF7D6D5),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(30),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

import 'compound_word_screen.dart';

class ScoreScreen extends StatelessWidget {
  final int score;
  final int total;
  final String setId;

  const ScoreScreen({super.key, required this.score, required this.total, required this.setId});

  Widget _stars() {
    int starCount = 0;

    if (score >= total) {
      starCount = 3;
    } else if (score >= total * 0.6) {
      starCount = 2;
    } else if (score >= 1) {
      starCount = 1;
    } else {
      starCount = 0;
    }

    // empty star
    if (starCount == 0) {
      return Image.asset('assets/character/angry.png', width: 90, height: 90);
    }

    // render star list
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        starCount,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Image.asset('assets/component/star.png', width: 32, height: 32),
        ),
      ),
    );
  }

  String get _message {
    final msgs = [
      "Try Your Best",
      "Not Bad!",
      "Very Good!",
      "Excellent Guy!",
      "Perfect!",
    ];
    return msgs[score.clamp(0, msgs.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF0EF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/component/trophy1.png',
                width: 90,
                height: 90,
              ),
              const SizedBox(height: 8),
              const Text(
                "Your Result",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                  color: Color(0xFF7A3333),
                ),
              ),
              const SizedBox(height: 10),
              _stars(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "$score",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 52,
                      color: AppColors.highlightColor,
                    ),
                  ),
                  Text(
                    "/$total",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      color: AppColors.highlightColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _message,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // back button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); 
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        "Back",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // retry
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SentenceGameScreen(setId: setId),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.highlightColor, AppColors.highlightColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFFFFF0EF),
                            offset: Offset(0, 5),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: const Text(
                        "Retry!",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

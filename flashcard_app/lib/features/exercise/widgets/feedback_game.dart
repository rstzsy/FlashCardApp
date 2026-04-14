import 'package:flutter/material.dart';

import 'color_game.dart';

class FeedbackOverlay extends StatelessWidget {
  final bool isCorrect;
  final String correctSentence;
  final bool isLast;
  final VoidCallback onNext;

  const FeedbackOverlay({
    super.key,
    required this.isCorrect,
    required this.correctSentence,
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isCorrect
                  ? [KidsColors.correctBgStart, KidsColors.correctBgEnd]
                  : [KidsColors.wrongBgStart, KidsColors.wrongBgEnd],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            isCorrect ? 'assets/character/win.png' : 'assets/character/loose.png',
            width: 80,
            height: 80,
          ),
          const SizedBox(height: 10),
          Text(
            isCorrect ? "Correct Answer!" : "Incorrect Answer!",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: isCorrect ? KidsColors.correctText : KidsColors.wrongText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isCorrect ? "You are so good!" : "Correct Answer: $correctSentence",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isCorrect ? KidsColors.correctSub : KidsColors.wrongSub,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onNext,
            // check answer
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              decoration: BoxDecoration(
                color: isCorrect ? KidsColors.correctBtn : KidsColors.wrongBtn,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color:
                        isCorrect
                            ? KidsColors.correctBtnShadow
                            : KidsColors.wrongBtnShadow,
                    offset: const Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                isLast ? "View Results" : "Next",
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

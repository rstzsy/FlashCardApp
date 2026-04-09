import 'package:flutter/material.dart';
import '../../../core/themes/app_colors.dart';

class FertilizerChallengeScreen extends StatefulWidget {
  const FertilizerChallengeScreen({super.key});

  @override
  State<FertilizerChallengeScreen> createState() =>
      _FertilizerChallengeScreenState();
}

class _FertilizerChallengeScreenState
    extends State<FertilizerChallengeScreen> {
  final int totalQuestions = 5;
  int currentQuestion = 3;
  int progressPercent = 60;

  final String setTitle = "Travel Vocabulary · Set 2";
  final String stageText = "Stage: Seedling → Sapling";
  final int totalDots = 5;
  final int filledDots = 3;

  final String questionType = "FILL IN THE BLANK";
  final String answerWord = "postpone";
  final String hintText = "Hint: to delay something to a later time";
  final String correctExplanation =
      '"Postpone" = to arrange a later time for something';

  final List<String> wordChoices = ["postpone", "cancel", "arrange", "schedule"];


  String? selectedWord;

  bool get hasAnswered => selectedWord != null;
  bool get isCorrect => selectedWord == answerWord;

  void _selectWord(String word) {
    if (hasAnswered) return; 
    setState(() => selectedWord = word);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Fertilizer Challenge",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color.fromARGB(255, 3, 85, 161),
                              ),
                            ),
                            Text(
                              "$progressPercent%",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color.fromARGB(255, 4, 85, 139),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Fill in the blank · Medium-Hard",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.highlightColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progressPercent / 100,
                            backgroundColor: Colors.grey.shade200,
                                color: const Color.fromARGB(255, 4, 85, 139),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 44,
                            height: 38,
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Container(
                                    width: 18,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD5708B),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 7,
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE9B4B3),
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(7),
                                        bottomLeft: Radius.circular(7),
                                        bottomRight: Radius.circular(7),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.flight_takeoff_rounded,
                                        size: 16,
                                        color: const Color(0xFFD5708B).withOpacity(0.6),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  setTitle,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  stageText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: List.generate(totalDots, (i) {
                                    final filled = i < filledDots;
                                    return Container(
                                      width: filled ? 10 : 8,
                                      height: filled ? 10 : 8,
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: filled
                                            ? const Color.fromARGB(255, 31, 116, 227)
                                            : Colors.grey.shade300,
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questionType,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 16),

                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            runSpacing: 6,
                            children: [
                              _buildQuestionText("She decided to"),
                              _BlankSlot(
                                filledWord: selectedWord,
                                isCorrect: hasAnswered ? isCorrect : null,
                              ),
                              _buildQuestionText(
                                  "the trip because of the bad weather."),
                            ],
                          ),

                          const SizedBox(height: 16),
                          Text(
                            hintText,
                            style: TextStyle(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: hasAnswered
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _FeedbackCard(
                                isCorrect: isCorrect,
                                message: isCorrect
                                    ? correctExplanation
                                    : 'The correct answer is "$answerWord"',
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const Text(
                      "Choose a word:",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: wordChoices.map((word) {
                        final isSelected = word == selectedWord;

                        Color chipBg;
                        Color chipBorder;
                        Color chipText;

                        if (!hasAnswered) {
                          chipBg = Colors.white;
                          chipBorder = Colors.grey.shade300;
                          chipText = const Color(0xFF2D2D2D);
                        } else if (isSelected && isCorrect) {
                          chipBg = AppColors.primary;
                          chipBorder = AppColors.primary;
                          chipText = Colors.white;
                        } else if (isSelected && !isCorrect) {
                          chipBg = const Color(0xFFFFEBEE);
                          chipBorder = const Color(0xFFE53935);
                          chipText = const Color(0xFFB71C1C);
                        } else if (!isSelected &&
                            word == answerWord &&
                            !isCorrect) {
                          chipBg = const Color(0xFFF1F8E9);
                          chipBorder = const Color(0xFF558B2F);
                          chipText = const Color(0xFF33691E);
                        } else {
                          chipBg = Colors.white;
                          chipBorder = Colors.grey.shade200;
                          chipText = Colors.grey.shade400;
                        }

                        return GestureDetector(
                          onTap: () => _selectWord(word),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: chipBg,
                              borderRadius: BorderRadius.circular(30),
                              border:
                                  Border.all(color: chipBorder, width: 1.5),
                            ),
                            child: Text(
                              word,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: chipText,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: hasAnswered
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: next question
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C4D8D),
                            foregroundColor: Colors.white,
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Next question",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionText(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D2D2D),
          height: 1.5,
        ),
      );
}

// ── Blank slot ────────────────────────────────────────────────
class _BlankSlot extends StatelessWidget {
  final String? filledWord;
  // null = chưa trả lời, true = đúng, false = sai
  final bool? isCorrect;

  const _BlankSlot({this.filledWord, this.isCorrect});

  @override
  Widget build(BuildContext context) {
    final bool empty = filledWord == null;

    Color underlineColor;
    Color textColor;
    Color bgColor;

    if (empty) {
      underlineColor = Colors.grey.shade400;
      textColor = Colors.transparent;
      bgColor = Colors.transparent;
    } else if (isCorrect == true) {
      underlineColor = const Color(0xFF558B2F);
      textColor = const Color(0xFF558B2F);
      bgColor = const Color(0xFFDCEDC8).withOpacity(0.5);
    } else {
      underlineColor = const Color(0xFFE53935);
      textColor = const Color(0xFFE53935);
      bgColor = const Color(0xFFFFEBEE).withOpacity(0.6);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      constraints: const BoxConstraints(minWidth: 110),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: underlineColor, width: 2),
        ),
      ),
      child: empty
          ? const SizedBox(height: 30, width: 110)
          : Text(
              filledWord!,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textColor,
                height: 1.5,
              ),
            ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final bool isCorrect;
  final String message;

  const _FeedbackCard(
      {super.key, required this.isCorrect, required this.message});

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isCorrect ? const Color(0xFFF1F8E9) : const Color(0xFFFDECEC);
    final iconColor =
        isCorrect ? const Color(0xFF558B2F) : const Color(0xFFD32F2F);
    final textColor =
        isCorrect ? const Color(0xFF33691E) : const Color(0xFFB71C1C);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCorrect
                ? Icons.check_circle_outline_rounded
                : Icons.cancel_outlined,
            color: iconColor,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? "Correct!" : "Incorrect",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Circle back button ────────────────────────────────────────
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF2D2D2D)),
      ),
    );
  }
}
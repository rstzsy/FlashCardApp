import 'package:flutter/material.dart';

class TestCompletedDialog extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final String level;

  const TestCompletedDialog({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.level,
  });

  // Pastel palette
  static const pastelPurple = Color(0xFFB8A9E8);
  static const pastelPink = Color(0xFFFFD6E8);
  static const pastelBlue = Color(0xFFB8E0F5);
  static const pastelYellow = Color(0xFFFFF3B8);
  static const textDark = Color(0xFF6B5B7B);

  // show dialog 
  static Future<void> show(
    BuildContext context, {
    required int score,
    required int totalQuestions,
    required String level,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TestCompletedDialog(
        score: score,
        totalQuestions: totalQuestions,
        level: level,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, pastelPink],
            stops: [0.3, 1.0],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: pastelPurple.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Badge to indicate test completion
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [pastelYellow, pastelPink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: pastelYellow.withOpacity(0.5),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 46,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Test Completed!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: textDark,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Your score',
              style: TextStyle(
                color: textDark.withOpacity(0.6),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 4),

            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [pastelPurple, pastelBlue],
              ).createShader(bounds),
              child: Text(
                '$score / $totalQuestions',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // override by shader
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Pill to display level, instead of plain text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: pastelBlue.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Estimated level: $level',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: pastelPurple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class FlashcardStudyControls extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const FlashcardStudyControls({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1A6A99),),
                label: const Text(
                  "Back",
                  style: TextStyle(
                    color: Color(0xFF1A6A99),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 191, 223, 243),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onNext,
                icon: const Icon(Icons.arrow_forward, color: Color(0xFF2E7D56)),
                label: const Text("Next", style: TextStyle(color: Color(0xFF2E7D56)),),
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFD5F0E3)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

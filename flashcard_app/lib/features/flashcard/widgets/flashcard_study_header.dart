import 'package:flutter/material.dart';
import 'package:flashcard_app/core/themes/app_colors.dart';

class FlashcardStudyHeader extends StatelessWidget {
  const FlashcardStudyHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _circleButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.pop(context),
          ),

          const Spacer(),

          const Text(
            "Animals",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppColors.highlightColor,
            ),
          ),

          const Spacer(),

          _circleButton(
            icon: Icons.edit,
            onPressed: () {
              // func
            },
          ),
        ],
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
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColors.highlightColor),
        onPressed: onPressed,
      ),
    );
  }
}
import 'package:flashcard_app/core/themes/app_colors.dart';
import 'package:flutter/material.dart';

import 'color_game.dart';

class CheckButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const CheckButton({super.key, required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          gradient: enabled
              ? const LinearGradient(
                  colors: [Color(0xFFFFF0EF), AppColors.highlightColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: enabled ? null : KidsColors.checkBtnDisabledBg,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: enabled
                  ? Color(0xFFFFF0EF)
                  : KidsColors.checkBtnDisabledBg,
              offset: const Offset(0, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Check Answer!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: enabled ? const Color(0xFF7A3333) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
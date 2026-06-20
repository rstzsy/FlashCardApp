import 'package:flutter/material.dart';

class AchievementDialog extends StatelessWidget {
  final int milestone;

  const AchievementDialog({
    super.key,
    required this.milestone,
  });

  static const Color bgLight = Color(0xFFFFF0F5); 
  static const Color bgPink = Color(0xFFFFD9E6); 
  static const Color accentPink = Color(0xFFFF8FAB); 
  static const Color textPink = Color(0xFFD6336C); 
  static const Color buttonPink = Color(0xFFFF6B9D);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [bgLight, bgPink],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: accentPink.withOpacity(0.35),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // decorative sparkle top-left
            Positioned(
              top: -10,
              left: -6,
              child: Icon(Icons.auto_awesome,
                  color: Colors.white.withOpacity(0.9), size: 26),
            ),
            // decorative sparkle top-right
            Positioned(
              top: 6,
              right: 10,
              child: Icon(Icons.auto_awesome,
                  color: accentPink.withOpacity(0.6), size: 18),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // badge circle behind the achievement image
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: accentPink.withOpacity(0.3),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      "assets/achievement/achievement$milestone.png",
                      height: 100,
                      width: 100,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    "Achievement Unlocked!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textPink,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "You've achieved a $milestone-day streak!",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A4A5E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 4,
                        shadowColor: accentPink.withOpacity(0.5),
                      ),
                      child: const Text(
                        "Awesome!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
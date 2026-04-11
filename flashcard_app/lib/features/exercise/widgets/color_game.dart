import 'package:flutter/material.dart';


class KidsColors {
  static const background = Color(0xFFFFF6FD);
  static const scoreBackground = Color(0xFFFFF6FD);

  // Text — dark for readability
  static const textDark = Color(0xFF1E1B4B);       // navy
  static const textPurpleDark = Color(0xFF3B0764);  // dark purple
  static const textMedium = Color(0xFF6B21A8);      // medium purple

  // Progress bar
  static const progressBg = Color(0xFFE9D5FF);
  static const progressStart = Color(0xFFF472B6);   // pink
  static const progressEnd = Color(0xFFA855F7);     // purple

  // Answer zone
  static const answerZoneBg = Color(0xFFFDE8FF);
  static const answerZoneBorder = Color(0xFFD8B4FE);

  // Selected chip
  static const selectedChipBg = Color(0xFFF0ABFC);
  static const selectedChipText = Color(0xFF3B0764);
  static const selectedChipShadow = Color(0xFFC026D3);

  // Available chips (pastel + dark text pairs)
  static const chip0Bg = Color(0xFFBFDBFE);
  static const chip0Text = Color(0xFF1E3A8A);
  static const chip0Shadow = Color(0xFF1D4ED8);

  static const chip1Bg = Color(0xFFBBF7D0);
  static const chip1Text = Color(0xFF14532D);
  static const chip1Shadow = Color(0xFF15803D);

  static const chip2Bg = Color(0xFFFED7AA);
  static const chip2Text = Color(0xFF7C2D12);
  static const chip2Shadow = Color(0xFFEA580C);

  static const chip3Bg = Color(0xFFFCA5A5);
  static const chip3Text = Color(0xFF7F1D1D);
  static const chip3Shadow = Color(0xFFDC2626);

  static const chip4Bg = Color(0xFFFDE68A);
  static const chip4Text = Color(0xFF78350F);
  static const chip4Shadow = Color(0xFFD97706);

  // Check button
  static const checkBtnStart = Color(0xFFA855F7);
  static const checkBtnEnd = Color(0xFFEC4899);
  static const checkBtnShadow = Color(0xFF7E22CE);
  static const checkBtnDisabledBg = Color.fromARGB(255, 220, 219, 222);
  static const checkBtnDisabledText = Color(0xFF7C3AED);

  // Feedback correct
  static const correctBgStart = Color(0xFFD1FAE5);
  static const correctBgEnd = Color(0xFFA7F3D0);
  static const correctText = Color(0xFF064E3B);
  static const correctSub = Color(0xFF065F46);
  static const correctBtn = Color(0xFF10B981);
  static const correctBtnShadow = Color(0xFF059669);

  // Feedback wrong
  static const wrongBgStart = Color(0xFFFFE4E6);
  static const wrongBgEnd = Color(0xFFFECDD3);
  static const wrongText = Color(0xFF881337);
  static const wrongSub = Color(0xFF9F1239);
  static const wrongBtn = Color(0xFFF43F5E);
  static const wrongBtnShadow = Color(0xFFBE123C);

  // Score screen
  static const scoreTitle = Color(0xFF1E1B4B);
  static const scoreNum = Color(0xFF6D28D9);
  static const scoreDenom = Color(0xFF7C3AED);
  static const scoreMsg = Color(0xFF3B0764);
  static const retryBtnShadow = Color(0xFF7E22CE);
}

// Chip color data
class ChipColorData {
  final Color bg;
  final Color text;
  final Color shadow;
  const ChipColorData(this.bg, this.text, this.shadow);
}

const List<ChipColorData> kChipColors = [
  ChipColorData(KidsColors.chip0Bg, KidsColors.chip0Text, KidsColors.chip0Shadow),
  ChipColorData(KidsColors.chip1Bg, KidsColors.chip1Text, KidsColors.chip1Shadow),
  ChipColorData(KidsColors.chip2Bg, KidsColors.chip2Text, KidsColors.chip2Shadow),
  ChipColorData(KidsColors.chip3Bg, KidsColors.chip3Text, KidsColors.chip3Shadow),
  ChipColorData(KidsColors.chip4Bg, KidsColors.chip4Text, KidsColors.chip4Shadow),
];
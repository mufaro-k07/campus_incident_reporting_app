import 'package:flutter/material.dart';

abstract final class AppColors {
  static const royalBlue = Color(0xFF1A0088);
  static const primaryEnd = Color(0xFF2E12A8);
  // Same tint as the Submitted chip, reused for icon tiles and avatars.
  static const royalBlueLight = Color(0xFFE4DEF7);
  static const tangerine = Color(0xFFFF5E32);
  static const lime = Color(0xFFB6CF4F);
  static const cream = Color(0xFFEFE7D4);
  static const surface = Color(0xFFFFFFFF);
  static const black = Color(0xFF0D0D0D);
  static const textSecondary = Color(0xFF5B5775);
  static const border = Color(0xFFD9D0B8);
  // Kept outside the palette so errors never look like a tangerine highlight.
  static const error = Color(0xFFB3261E);

  static const submittedText = Color(0xFF1A0088);
  static const submittedBackground = Color(0xFFE4DEF7);
  static const inProgressText = Color(0xFF9A2F0E);
  static const inProgressBackground = Color(0xFFFFE1D6);
  static const resolvedText = Color(0xFF3D5200);
  static const resolvedBackground = Color(0xFFE6F0BF);
}

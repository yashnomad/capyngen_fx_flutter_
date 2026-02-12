import 'package:flutter/material.dart';

// 🏆 A1 ONE – Premium Trading Color Palette
class A1OneColors {
  A1OneColors._();

  // 🌑 Backgrounds
  static const Color bg = Color(0xFF0F0F0F); // Deep black (main bg)
  static const Color cardBg = Color(0xFF1A1A1A); // Dark card surface
  static const Color surface = Color(0xFF141414);
  static const Color transparent = Colors.transparent;

  // 🟡 Primary Brand (Gold from logo)
  static const Color primary = Color(0xFFFFC94A); // Rich gold
  static const Color primarySoft = Color(0xFFFFD776); // Soft gold
  static const Color primaryDark = Color(0xFFE6B73E); // Muted gold

  // ✨ Accent (Luxury highlight)
  static const Color accent = Color(0xFFFFE29A);

  // 🌈 Gradients (Used for cards / buttons)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFFFFC94A),
      Color(0xFFE6B73E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 🔘 Buttons
  static const Color button = primary;
  static const Color buttonText = Color(0xFF0F0F0F); // Black text on gold
  static const Color disabledButton = Color(0xFF3A3A3A);

  // 📝 Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB5B5B5);
  static const Color textMuted = Color(0xFF7A7A7A);
  static const Color textOnGold = Color(0xFF0F0F0F);

  // 🧭 Icons
  static const Color iconPrimary = primary;
  static const Color iconSecondary = Color(0xFF9E9E9E);

  // ➖ Borders / Dividers
  static const Color border = Color(0xFF2A2A2A);
  static const Color divider = Color(0xFF242424);

  // 📈 Trading States
  static const Color profit = Color(0xFF3DDC84); // Green profit
  static const Color loss = Color(0xFFE85C5C); // Red loss
  static const Color warning = Color(0xFFFFB020);
  static const Color info = Color(0xFF4D8DFF);

  // 🌫 Shadows
  static Color shadow = Colors.black.withOpacity(0.6);
}

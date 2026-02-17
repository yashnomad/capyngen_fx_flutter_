import 'package:flutter/material.dart';

// 🏆 AT7 – Premium Shield Trading Palette (Based on Logo)
class aurelianglobalColors {
  aurelianglobalColors._();

  // 🌌 Backgrounds (Deep Navy from shield)
  static const Color bg = Color(0xFF0B1C2D); // Main dark navy
  static const Color surface = Color(0xFF10273D); // Slightly lighter navy
  static const Color cardBg = Color(0xFF132F4A); // Card surface
  static const Color transparent = Colors.transparent;

  // 🟡 Primary Brand (Metallic Gold from AT)
  static const Color primary = Color(0xFFFFC83D); // Rich gold
  static const Color primarySoft = Color(0xFFFFD76A); // Highlight gold
  static const Color primaryDark = Color(0xFFE6A800); // Deep metallic gold

  // ✨ Gold Glow Accent (Light reflection effect)
  static const Color accent = Color(0xFFFFE8A3);

  // 🔵 Trading Blue (From chart & glow effects)
  static const Color electricBlue = Color(0xFF3DA5FF);
  static const Color chartBlue = Color(0xFF1F7AE0);

  // 🌈 Premium Gradients

  // Gold Button Gradient
  static const LinearGradient goldGradient = LinearGradient(
    colors: [
      Color(0xFFFFD76A),
      Color(0xFFE6A800),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shield Background Gradient
  static const LinearGradient navyGradient = LinearGradient(
    colors: [
      Color(0xFF0B1C2D),
      Color(0xFF132F4A),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 🔘 Buttons
  static const Color button = primary;
  static const Color buttonText = Color(0xFF0B1C2D); // Navy text on gold
  static const Color disabledButton = Color(0xFF2A3E55);

  // 📝 Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB8C7D9);
  static const Color textMuted = Color(0xFF6E8AA6);
  static const Color textOnGold = Color(0xFF0B1C2D);

  // 🧭 Icons
  static const Color iconPrimary = primary;
  static const Color iconSecondary = Color(0xFF8FA6C1);

  // ➖ Borders / Dividers
  static const Color border = Color(0xFF1C3A57);
  static const Color divider = Color(0xFF17324C);

  // 📈 Trading States
  static const Color profit = Color(0xFF3DDC84); // Green candle
  static const Color loss = Color(0xFFE85C5C); // Red candle
  static const Color warning = Color(0xFFFFB020);
  static const Color info = electricBlue;

  // 🌟 Glow Effects (For premium UI highlights)
  static Color goldGlow = const Color(0xFFFFC83D).withOpacity(0.4);
  static Color blueGlow = const Color(0xFF3DA5FF).withOpacity(0.35);

  // 🌫 Shadows
  static Color shadow = Colors.black.withOpacity(0.6);
}

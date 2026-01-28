import 'package:flutter/material.dart';
// 🎨 GaneCapitalFx Color Palette
// (Full class with updated gradients/dividers)
class GaneCapitalFxColors {
  // 🔹 Backgrounds
  static const Color bg = Color(0xFFFFFFFF);
  static const Color cardBg = Colors.white;
  static const Color transparent = Colors.transparent;

  // 🔹 Primary / Brand
  static const Color primary = Color(0xFF00202E); // Dark Teal
  static const Color primaryDark = Color(0xFF00151E); // Darker Teal
  static const Color secondary = Color(0xFFB3915C); // Gold
  static Color shadow = primary.withOpacity(0.4);

  // 🔹 Buttons
  static const Color button = primary;
  static const Color buttonText = Colors.white;
  static const Color disabledButton = Colors.grey;

  // 🔹 Text
  static const Color text = Color(0xFF00202E);
  static const Color textLight = Color(0xFF808080);
  static const Color textDark = Colors.black;
  static const Color headerText = Color(0xFF00202E);

  // 🔹 Icons
  static const Color icon = Color(0xFF00202E);
  static const Color iconSecondary = Color(0xFFB3915C);

  // 🔹 Dividers / Borders (Updated)
  static const Color divider = Color(0xFFB3915C); // Updated (matches secondary)
  static const Color border = Color(0xFFE0E0E0); // (Preserved neutral border)

  // 🔹 Gradients (Updated)
  static const Color gradient1 = Color(0xFF00202E); // Updated (matches primary)
  static const Color gradient2 = Color(0xFFB3915C); // Updated (matches secondary)

  // 🔹 Alerts / States (Preserved)
  static const Color success = Color(0xFF32A272);
  static const Color error = Color(0xFFF66D70);
  static const Color warning = Color(0xFFAEA4F8);
  static const Color info = Colors.blue;
}
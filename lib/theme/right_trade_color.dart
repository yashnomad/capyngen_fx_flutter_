import 'package:flutter/material.dart';

class RightTradeColors {
  // 🔹 Backgrounds
  static const Color bg = Color(0xFFFFFFFF);
  static const Color cardBg = Colors.white;
  static const Color transparent = Colors.transparent;

  // Brand colors (swapped primary/secondary)
  static const Color primary = Color(0xff243d8a);   // Gold / Yellow accent
  static const Color primaryDark = Color(0xff020d2f); // Darker shade of gold
  static const Color secondary = Color(0xFF19223F); // Navy / Dark Blue
  static const Color tertiary = Color(0xFFFFFFFF);  // White highlight
  static Color shadow = primary.withOpacity(0.4);

  // 🔹 Buttons
  static const Color button = primary;
  static const Color buttonText = Colors.white;
  static const Color disabledButton = Colors.grey;

  // 🔹 Text
  static const Color text = Color(0xFF101010);
  static const Color textLight = Color(0xFF6B6B6B);
  static const Color textDark = Colors.black;
  static const Color headerText = secondary;

  // 🔹 Icons
  static const Color icon = secondary;
  static const Color iconSecondary = Color(0xFF7A7A7A);

  // 🔹 Dividers / Borders
  static const Color divider = Color(0xFFB0B0B0);
  static const Color border = Color(0xFFE0E0E0);

  // 🔹 Gradients
  static const Color gradient1 = primary;
  static const Color gradient2 = primaryDark;

  // 🔹 Alerts / States
  static const Color success = Colors.green;
  static const Color error = Color(0xFFEB4335);
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;
}

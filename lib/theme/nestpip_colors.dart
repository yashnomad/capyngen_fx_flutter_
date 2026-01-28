import 'package:flutter/material.dart';

class NestPipColors {
  // 🔹 Backgrounds
  static const Color bg = Color(0xFFFFFFFF);
  static const Color cardBg = Colors.white;
  static const Color transparent = Colors.transparent;

  // 🔹 Primary / Brand
  static const Color primary = Color(0xFFE53935); // Red (logo arrow)
  static const Color primaryDark = Color(0xFFC62828); // Darker Red
  static const Color secondary = Color(0xFF2E7D32); // Green checkmark
  static Color shadow = primary.withValues(alpha: 0.4);

  // 🔹 Buttons
  static const Color button = primary;
  static const Color buttonText = Colors.white;
  static const Color disabledButton = Colors.grey;

  // 🔹 Text
  static const Color text = Color(0xFF1C1C1C);
  static const Color textLight = Color(0xFF626364);
  static const Color textDark = Colors.black;
  static const Color headerText = Color(0xFFF79B39);

  // 🔹 Icons
  static const Color icon = primary;
  static const Color iconSecondary = Color(0xFF7A7A7A);

  // 🔹 Dividers / Borders
  static const Color divider = Color(0xFFBDBDBD);
  static const Color border = Color(0xFFE0E0E0);

  // 🔹 Gradients
  static const Color gradient1 = Color(0xFFF8AE5F);
  static const Color gradient2 = Color(0xFFF79B39);

  // 🔹 Alerts / States
  static const Color success = Color(0xFF32A272);
  static const Color error = Color(0xFFFF4B4B);
  static const Color warning = Color(0xFFFBC142);
  static const Color info = Colors.blue;
}

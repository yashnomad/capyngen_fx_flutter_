import 'package:flutter/material.dart';

class SarthifxmColor {
  // 🔹 Backgrounds
  static const Color bg = Color(0xFFFFFFFF);
  static const Color cardBg = Colors.white;
  static const Color transparent = Colors.transparent;

  // 🔹 Primary / Brand
  static const Color primary = Color(0xFFF7941D); // Orange from "FXM"
  static const Color primaryDark = Color(0xFFD97E10); // Darker orange shade
  static const Color secondary = Color(0xFF2E3192); // Blue from "Sarthi"
  static Color shadow = primary.withValues(alpha: 0.4);

  // 🔹 Buttons
  static const Color button = primary;
  static const Color buttonText = Colors.white;
  static const Color disabledButton = Colors.grey;

  // 🔹 Text
  static const Color text = Color(0xFF0B0B0B);
  static const Color textLight = Color(0xFF3E4152);
  static const Color textDark = Colors.black;
  static const Color headerText = Color(0xFFF7941D); // Changed to new primary

  // 🔹 Icons
  static const Color icon = Color(0xFF111111);
  static const Color iconSecondary = Color(0xFF7A7A7A);

  // 🔹 Dividers / Borders
  static const Color divider = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFE0E0E0);

  // 🔹 Gradients (Swapped)
  static const Color gradient1 = Color(0xFFF7941D); // Primary Orange
  static const Color gradient2 = Color(0xFF2E3192); // Secondary Blue

  // 🔹 Alerts / States
  static const Color success = Color(0xFF3DE994);
  static const Color error = Color(0xFFBA3636);
  static const Color warning = Color(0xFFE7874B);
  static const Color info = Colors.blue;
}

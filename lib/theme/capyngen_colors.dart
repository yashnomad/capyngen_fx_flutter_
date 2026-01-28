import 'package:flutter/material.dart';

class CapyngenColors {
  // 🔹 Backgrounds
  static const Color bg = Color(0xFFFFFFFF);
  static const Color cardBg = Colors.white;
  static const Color transparent = Colors.transparent;

  // 🔹 Primary / Brand
  static const Color primary = Color(0xFF4A90E2); // Blue from logo
  static const Color primaryDark = Color(0xFF3A7BC8); // Darker blue shade
  static const Color secondary = Color(0xFF5A5A5A); // Dark grey from logo
  static Color shadow = primary.withValues(alpha: 0.4);

  // 🔹 Buttons
  static const Color button = primary;
  static const Color buttonText = Colors.white;
  static const Color disabledButton = Colors.grey;

  // 🔹 Text
  static const Color text = Color(0xFF0B0B0B);
  static const Color textLight = Color(0xFF3E4152);
  static const Color textDark = Colors.black;
  static const Color headerText = Color(0xFF4A90E2); // Updated to primary blue

  // 🔹 Icons
  static const Color icon = Color(0xFF111111);
  static const Color iconSecondary = Color(0xFF7A7A7A);

  // 🔹 Dividers / Borders
  static const Color divider = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFE0E0E0);

  // 🔹 Gradients
  static const Color gradient1 = Color(0xFF6AACFF); // Lighter shade of primary blue
  static const Color gradient2 = Color(0xFF3A7BC8); // Darker shade (primaryDark)

  // 🔹 Alerts / States
  static const Color success = Color(0xFF3DE994); // These can remain
  static const Color error = Color(0xFFBA3636);   // Or be updated if needed
  static const Color warning = Color(0xFFE7874B); // Or be updated if needed
  static const Color info = Colors.blue;          // This already fits
}
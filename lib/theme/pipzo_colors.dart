import 'package:flutter/material.dart';

class PipzoColors {
  // 🔹 Backgrounds
  static const Color bg =Color(0xFFFFFFFF);
  static const Color cardBg = Colors.white;
  static const Color transparent = Colors.transparent;

  // 🔹 Primary / Brand
  static const Color primary = Color(0xFF1A237E); // Deep Navy (compass outline)
  static const Color primaryDark = Color(0xFF0D1759); // Darker Navy
  static const Color secondary = Color(0xFFE53935); // Red accent in compass
  static Color shadow = primary.withValues(alpha: 0.4);

  // 🔹 Buttons
  static const Color button = primary;
  static const Color buttonText = Colors.white;
  static const Color disabledButton = Colors.grey;

  // 🔹 Text
  static const Color text = Color(0xFF020000);
  static const Color textLight = Color(0xFF808080);
  static const Color textDark = Colors.black;
  static const Color headerText = Color(0xFF283B96);

  // 🔹 Icons
  static const Color icon = Color(0xFF283B96);
  static const Color iconSecondary = Color(0xFF7A7A7A);

  // 🔹 Dividers / Borders
  static const Color divider = Color(0xFF7B5BDF);
  static const Color border = Color(0xFFE0E0E0);

  // 🔹 Gradients
  static const Color gradient1 = Color(0xFF77A6F8);
  static const Color gradient2 = Color(0xFF7B5BDF);

  // 🔹 Alerts / States
  static const Color success = Color(0xFF32A272);
  static const Color error = Color(0xFFF66D70);
  static const Color warning = Color(0xFFAEA4F8);
  static const Color info = Colors.blue;
}

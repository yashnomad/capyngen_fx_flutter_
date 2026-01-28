import 'package:flutter/material.dart';

// 🎨 BlueGateMarket Color Palette
class BlueGateMarketColors {
  // 🔹 Backgrounds
  static const Color bg = Color(0xFFFFFFFF); // White background
  static const Color cardBg = Colors.white;
  static const Color transparent = Colors.transparent;

  // 🔹 Primary / Brand Colors (Extracted from logo)
  static const Color primary = Color(0xFF3F4FA1); // Logo Blue
  static const Color primaryDark = Color(0xFF2F3C87); // Darker blue
  static Color shadow = primary.withOpacity(0.35);

  // 🔹 Secondary (Green from logo bars & underline)
  static const Color secondary = Color(0xFF4CAF50); // Brand green

  // 🔹 Buttons
  static const Color button = primary;
  static const Color buttonText = Colors.white;
  static const Color disabledButton = Colors.grey;

  // 🔹 Text
  static const Color text = Color(0xFF1C1C1C); // Dark readable text
  static const Color textLight = Color(0xFF8E8E8E);
  static const Color textDark = Colors.black;
  static const Color headerText = primary;

  // 🔹 Icons
  static const Color icon = primary;
  static const Color iconSecondary = secondary;

  // 🔹 Dividers / Borders
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);

  // 🔹 Gradients
  static const Color gradient1 = Color(0xFF3F4FA1); // Blue
  static const Color gradient2 = Color(0xFF4CAF50); // Green

  // 🔹 Alerts
  static const Color success = Color(0xFF32A272);
  static const Color error = Color(0xFFF66D70);
  static const Color warning = Color(0xFFAEA4F8);
  static const Color info = Colors.blue;
}

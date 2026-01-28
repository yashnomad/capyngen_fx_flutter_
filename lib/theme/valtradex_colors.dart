import 'package:flutter/material.dart';


class ValtradexColors {
  static const Color bg = Color(0xFF111111);
  static const Color cardBg = Color(0xFF1F1F1F);
  static const Color transparent = Colors.transparent;

  // Branding
  static const Color primary = Color(0xFF6B6451);      // Gold tone
  static const Color primaryDark = Color(0xFF504A39);
  static const Color secondary = Color(0xFF1A1A1A);
  static Color shadow = primary.withValues(alpha: 0.4);

  // Buttons
  static const Color button = primary;
  static const Color buttonText = Colors.white;
  static const Color disabledButton = Colors.grey;

  // Text
  static const Color text = Colors.white;
  static const Color textLight = Color(0xFFC7BEA8);
  static const Color textDark = Colors.black;
  static const Color headerText = primary;

  // Icons
  static const Color icon = Colors.white;
  static const Color iconSecondary = Color(0xFF6B6451);

  // Borders & Dividers
  static const Color divider = Color(0xFF4C4C4C);
  static const Color border = Color(0xFF6B6451);

  // Gradient
  static const Color gradient1 = Color(0xFF9A8F6C);
  static const Color gradient2 = Color(0xFF6B6451);

  // Alerts
  static const Color success = Color(0xFF3DE994);
  static const Color error = Color(0xFFBA3636);
  static const Color warning = Color(0xFFE7874B);
  static const Color info = Colors.blue;
}

import 'package:flutter/material.dart';

class LivefxmColors {
  static const Color bg = Color(0xFF0A0F1F);
  static const Color cardBg = Color(0xFF121A2C);
  static const Color transparent = Colors.transparent;

  // Branding
  static const Color primary = Color(0xFF254D4A);   // Deep blue-green
  static const Color primaryDark = Color(0xFF163331);
  static const Color secondary = Color(0xFF25D46A); // Neon green
  static Color shadow = primary.withValues(alpha: 0.4);

  // Buttons
  static const Color button = secondary;
  static const Color buttonText = Colors.black;
  static const Color disabledButton = Colors.grey;

  // Text
  static const Color text = Colors.white;
  static const Color textLight = Color(0xFF8EFFC4);
  static const Color textDark = Colors.black;
  static const Color headerText = secondary;

  // Icons
  static const Color icon = Colors.white;
  static const Color iconSecondary = Color(0xFF25D46A);

  // Borders & Dividers
  static const Color divider = Color(0xFF1C2F3A);
  static const Color border = Color(0xFF25D46A);

  // Gradient
  static const Color gradient1 = Color(0xFF254D4A);
  static const Color gradient2 = Color(0xFF25D46A);

  // Alerts
  static const Color success = Color(0xFF25D46A);
  static const Color error = Color(0xFFBA3636);
  static const Color warning = Color(0xFFE7874B);
  static const Color info = Colors.blue;
}

import 'package:flutter/material.dart';

class IglobefxColors {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color cardBg = Colors.white;
  static const Color transparent = Colors.transparent;

  // Branding
  static const Color primary = Color(0xFF223481);     // Navy blue
  static const Color primaryDark = Color(0xFF1A2766);
  static const Color secondary = Color(0xFF97E1F0);   // Sky-blue
  static Color shadow = primary.withValues(alpha: 0.4);

  // Buttons
  static const Color button = primary;
  static const Color buttonText = Colors.white;
  static const Color disabledButton = Colors.grey;

  // Text
  static const Color text = Colors.black;
  static const Color textLight = Color(0xFF3E4152);
  static const Color textDark = Colors.black;
  static const Color headerText = primary;

  // Icons
  static const Color icon = Color(0xFF111111);
  static const Color iconSecondary = Color(0xFF97E1F0);

  // Borders & Dividers
  static const Color divider = Color(0xFF9E9E9E);
  static const Color border = Color(0xFFD0EFFF);

  // Gradient
  static const Color gradient1 = Color(0xFF223481);
  static const Color gradient2 = Color(0xFF97E1F0);

  // Alerts
  static const Color success = Color(0xFF3DE994);
  static const Color error = Color(0xFFBA3636);
  static const Color warning = Color(0xFFE7874B);
  static const Color info = Colors.blue;
}

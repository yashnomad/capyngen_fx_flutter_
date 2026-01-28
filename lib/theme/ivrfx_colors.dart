import 'package:flutter/material.dart';

class IvrfxColors {
  // ðŸ”¹ Backgrounds
  static const Color bg = Color(0xFFFFFFFF);
  static const Color cardBg = Colors.white;
  static const Color transparent = Colors.transparent;

  // ðŸ”¹ Primary / Brand
  static const Color primary = Color(0xFF17477B);
  static const Color primaryDark = Color(0xFF17477B);
  static const Color secondary = Color(0xFFC2C2C2);
  static Color shadow = primary.withOpacity(0.4);

  // ðŸ”¹ Buttons
  static const Color button = primary;
  static const Color buttonText = Colors.white;
  static const Color disabledButton = Colors.grey;

  // ðŸ”¹ Text
  static const Color text = Color(0xFF020000);
  static const Color textLight = Color(0xFF808080);
  static const Color textDark = Colors.black;
  static const Color headerText = primary;

  // ðŸ”¹ Icons
  static const Color icon = primary;
  static const Color iconSecondary = secondary;

  // ðŸ”¹ Dividers / Borders
  static const Color divider = secondary;
  static const Color border = Color(0xFFE0E0E0);

  // ðŸ”¹ Gradients
  static const Color gradient1 = primary;
  static const Color gradient2 = secondary;

  // ðŸ”¹ Alerts / States
  static const Color success = Color(0xFF32A272);
  static const Color error = Color(0xFFF66D70);
  static const Color warning = Color(0xFFAEA4F8);
  static const Color info = Colors.blue;
}

import 'package:flutter/material.dart';

// ------------------ FinFlyMarket ------------------
class FinFlyMarketColors {
  // 🖼 Backgrounds
  static const Color bg = Color(0xFFFFFFFF);
  static const Color cardBg = Colors.white;
  static const Color transparent = Colors.transparent;

  // 🎨 Primary / Brand
  static const Color primary = Color(0xFF164885);
  static const Color primaryDark = Color(0xFF164885);
  static const Color secondary = Color(0xFF000000);
  static Color shadow = primary.withOpacity(0.4);

  // 🔘 Buttons
  static const Color button = primary;
  static const Color buttonText = Colors.white;
  static const Color disabledButton = Colors.grey;

  // 📝 Text
  static const Color text = Color(0xFF020000);
  static const Color textLight = Color(0xFF808080);
  static const Color textDark = Colors.black;
  static const Color headerText = primary;

  // 🔔 Icons
  static const Color icon = primary;
  static const Color iconSecondary = secondary;

  // 📏 Dividers / Borders
  static const Color divider = secondary;
  static const Color border = Color(0xFFE0E0E0);

  // 🌈 Gradients
  static const Color gradient1 = primary;
  static const Color gradient2 = secondary;

  // 🚨 Alerts / States
  static const Color success = Color(0xFF32A272);
  static const Color error = Color(0xFFF66D70);
  static const Color warning = Color(0xFFAEA4F8);
  static const Color info = Colors.blue;
}
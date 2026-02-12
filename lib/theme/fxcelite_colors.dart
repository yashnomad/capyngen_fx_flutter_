import 'package:flutter/material.dart';

class FxceliteColors {
  FxceliteColors._();

  // 🌐 Backgrounds
  static const Color bg = Color(0xFFF8F9FC); // soft light bg
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color darkBg = Color(0xFF020F35); // 🔥 main dark blue
  static const Color transparent = Colors.transparent;

  // 🎨 Primary Theme (Brand)
  static const Color primary = Color(0xFF020F35); // MAIN COLOR
  static const Color primaryDark = Color(0xFF010A26); // darker shade
  static const Color primaryLight = Color(0xFF1A2B6F); // lighter shade
  static const Color secondary = Color(0xFF2F4FD8); // brand blue accent

  // 🔘 Buttons
  static const Color button = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonText = Color(0xFFFFFFFF);

  // 📝 Text
  static const Color text = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color headerText = primary;

  // 🧩 Icons
  static const Color icon = Color(0xFF020F35);
  static const Color iconSecondary = Color(0xFF64748B);

  // 🌫 Shadow
  static const Color shadow = Color(0x26000000);

  // 🚦 Status
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFD50000);
  static const Color warning = Color(0xFFF9A825);
  static const Color info = Color(0xFF2979FF);

  // 💹 Trading
  static const Color buyGreen = Color(0xFF00E676);
  static const Color sellRed = Color(0xFFFF1744);
  static const Color profit = Color(0xFF00C853);
  static const Color loss = Color(0xFFD50000);
  static const Color orderLine = Color(0xFF2F4FD8);
}

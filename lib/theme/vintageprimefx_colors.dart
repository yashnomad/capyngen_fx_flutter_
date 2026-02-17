import 'package:flutter/material.dart';

class VintagePrimeFxColors {
  VintagePrimeFxColors._();

  // 🌑 Backgrounds
  // Switched to White to match Light Mode default, ensuring contrast with Black text elements.
  static const Color bg = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color darkBg = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // 🏆 Brand (Gold Theme)
  static const Color primary = Color(0xFFD4AF37); // classic gold
  static const Color primaryDark = Color(0xFFB8962E); // darker gold
  static const Color primaryLight = Color(0xFFF1D27A); // soft highlight gold

  static const Color secondary = Color(0xFF8C7A3D); // muted antique gold

  // 🔘 Buttons
  static const Color button = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonText =
      Color(0xFF000000); // black on gold is high contrast

  // 📝 Text
  // Updated to colors that work on the new White background.
  // Note: If AppFlavorColor.text represents "Text on Background", it should be dark.
  // If it represents "Text on Primary", it should be dark (since Primary is Gold).
  static const Color text =
      Color(0xFF1F2937); // Dark Grey/Black for visibility on White
  static const Color textSecondary = Color(0xFF6B7280); // Medium Gray
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textDark = Color(0xFF000000);

  static const Color headerText = primary;

  // 🧩 Icons
  static const Color icon = primary;
  static const Color iconSecondary = Color(0xFF9CA3AF);

  // 🌫 Shadow
  static const Color shadow = Color(0x1A000000); // Light shadow for white bg

  // 🚦 Status
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF1C40F);
  static const Color info = Color(0xFFD4AF37);

  // 💹 Trading
  static const Color buyGreen = Color(0xFF2ECC71);
  static const Color sellRed = Color(0xFFE74C3C);
  static const Color profit = Color(0xFF2ECC71);
  static const Color loss = Color(0xFFE74C3C);
  static const Color orderLine = primary;
}

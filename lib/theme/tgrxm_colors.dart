import 'package:flutter/material.dart';

class TgrxmColors {
  static const Color bg = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFF121212);
  static const Color transparent = Colors.transparent;

  // ✅ Branding (Bright Logo Gold)
  static const Color primary = Color(0xFFD4AF37);      // Classic Metallic Gold
  static const Color primaryDark = Color(0xFFB8962E);  // Dark Gold for depth
  static const Color secondary = Color(0xFF1A1A1A);

  static Color shadow = const Color(0xFFD4AF37).withOpacity(0.35);

  // ✅ Buttons
  static const Color button = primary;
  static const Color buttonText = Colors.black;
  static const Color disabledButton = Color(0xFF9E9E9E);

  // ✅ Text
  static const Color text = Colors.white;
  static const Color textLight = Color(0xFFEADFAF);   // Soft light gold
  static const Color textDark = Colors.black;
  static const Color headerText = primary;

  // ✅ Icons
  static const Color icon = Colors.white;
  static const Color iconSecondary = primary;

  // ✅ Borders & Dividers
  static const Color divider = Color(0xFF3A3A3A);
  static const Color border = primary;

  // ✅ Gradient (Logo-like Gold Shine)
  static const Color gradient1 = Color(0xFFFFE27A); // highlight gold
  static const Color gradient2 = Color(0xFFD4AF37); // base gold

  // ✅ Alerts
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);
  static const Color info = Colors.blue;
}

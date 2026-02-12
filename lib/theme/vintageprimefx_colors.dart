import 'package:flutter/material.dart';

class VintagePrimeFxColors {
  VintagePrimeFxColors._();

  // 🌑 Backgrounds
  static const Color bg = Color(0xFF0B0B0B); // deep black
  static const Color cardBg = Color(0xFF141414); // slightly lighter black
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
  static const Color buttonText = Color(0xFF000000); // black on gold

  // 📝 Text
  static const Color text = Color(0xFFE5E5E5); // soft white
  static const Color textSecondary = Color(0xFF9CA3AF); // muted gray
  static const Color headerText = primary;

  // 🧩 Icons
  static const Color icon = primary;
  static const Color iconSecondary = Color(0xFFB0B0B0);

  // 🌫 Shadow
  static const Color shadow = Color(0x66000000); // deep shadow

  // 🚦 Status
  static const Color success = Color(0xFF2ECC71); // premium green
  static const Color error = Color(0xFFE74C3C); // luxury red
  static const Color warning = Color(0xFFF1C40F);
  static const Color info = Color(0xFFD4AF37); // gold info

  // 💹 Trading
  static const Color buyGreen = Color(0xFF2ECC71);
  static const Color sellRed = Color(0xFFE74C3C);
  static const Color profit = Color(0xFF2ECC71);
  static const Color loss = Color(0xFFE74C3C);
  static const Color orderLine = primary;
}

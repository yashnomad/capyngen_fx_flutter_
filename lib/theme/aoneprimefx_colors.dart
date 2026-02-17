import 'package:flutter/material.dart';

class aoneprimefxColors {
  aoneprimefxColors._();

  // 🤍 Base
  static const Color bg = Color(0xFFFFFFFF); // Pure white
  static const Color surface = Color(0xFFFFFFFF); // Cards
  static const Color elevated = Color(0xFFFAFAFA); // Slight depth

  // 🟡 Luxury Gold (Less Yellow, More Elegant)
  static const Color primary = Color(0xFFC6A23E); // Premium gold
  static const Color primaryDark = Color(0xFF9E7B2E); // Rich, deep gold
  static const Color primarySoft = Color(0xFFE7D28B);
  static const Color primaryLight = Color(0xFFF4E7C1);

  // 📝 Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6E6E73);
  static const Color textMuted = Color(0xFF9A9A9A);
  static const Color textOnGold = Colors.white;

  // ➖ Lines
  static const Color border = Color(0xFFEAEAEA);
  static const Color divider = Color(0xFFF2F2F2);

  // 📈 States (keep subtle)
  static const Color profit = Color(0xFF2E7D32);
  static const Color loss = Color(0xFFC62828);

  static const BoxShadow shadow = BoxShadow(
    color: Color(0x0D000000),
    blurRadius: 20,
    offset: Offset(0, 8),
  );
}

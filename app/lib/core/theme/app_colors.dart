import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color headerStart = Color(0xFF0E2468);
  static const Color headerEnd = Color(0xFF4D2063);

  static const Color buttonStart = Color(0xFF193361);
  static const Color buttonMid = Color(0xFF5970AF);
  static const Color buttonEnd = Color(0xFF985AC0);

  static const Color accent = Color(0xFF9439D5);
  static const Color textPrimary = Color(0xFF121A2C);
  static const Color textSecondary = Color(0xFF737B8C);
  static const Color textMuted = Color(0xFF9EA1A8);
  static const Color border = Color(0xFFAAB2BC);
  static const Color inputBorder = Color(0xFFAAB2BC);

  static const Color success = Color(0xFF2DBE64);
  static const Color warning = Color(0xFFF5A524);
  static const Color danger = Color(0xFFE5484D);

  static const Color bgWhite = Colors.white;
  static const Color bgSoft = Color(0xFFF5F5F7);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [headerStart, headerEnd],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [buttonStart, buttonMid, buttonEnd],
    stops: [0.0, 0.475, 1.0],
  );
}

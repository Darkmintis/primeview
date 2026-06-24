import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF131725);
  static const Color surfaceLight = Color(0xFF1C2138);
  static const Color cardBackground = Color(0xFF161B2E);
  static const Color primary = Color(0xFF4A6CF7);
  static const Color primaryDark = Color(0xFF3B5DE7);
  static const Color primaryLight = Color(0xFF6B89FF);
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B8CC);
  static const Color textMuted = Color(0xFF6B7390);
  static const Color divider = Color(0xFF252D45);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color favorite = Color(0xFFF59E0B);
  static const Color overlay = Color(0x80000000);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xB00A0E1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroOverlay = LinearGradient(
    colors: [Color(0x80000000), Colors.transparent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF4A6CF7), Color(0xFF6B89FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

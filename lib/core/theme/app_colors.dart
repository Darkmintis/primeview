import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0B0B1A);
  static const Color surface = Color(0xFF151528);
  static const Color surfaceLight = Color(0xFF1F1F3A);
  static const Color cardBackground = Color(0xFF181830);
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5A4BD1);
  static const Color primaryLight = Color(0xFF8B7CF7);
  static const Color accent = Color(0xFFFFD700);
  static const Color accentLight = Color(0xFFFFE44D);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0C8);
  static const Color textMuted = Color(0xFF707090);
  static const Color divider = Color(0xFF2A2A48);
  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFD740);
  static const Color favorite = Color(0xFFFFD700);
  static const Color overlay = Color(0x80000000);

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xB00B0B1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroOverlay = LinearGradient(
    colors: [Color(0x80000000), Colors.transparent],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

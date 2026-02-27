import 'package:flutter/material.dart';

class AppThemeTokens {
  // Brand Colors - Professional Calm Palette
  static const Color brandPrimary = Color(0xFF1B263B); // Deep Navy
  static const Color brandSecondary = Color(0xFF415A77); // Slate Blue
  static const Color brandAccent = Color(0xFF778DA9); // Steel Blue
  static const Color brandSuccess = Color(0xFF2D6A4F); // Deep Green
  static const Color brandSuccessLight = Color(0xFF52B788);

  // Background Colors
  static const Color bgSurface = Color(0xFFF8F9FA);
  static const Color bgBackground = Color(0xFFE0E1DD); // Subtle cool grey
  static const Color bgSurfaceDark = Color(0xFF0D1B2A);
  static const Color bgBackgroundDark = Color(0xFF1B263B);

  // Text Colors (High Contrast)
  static const Color textPrimary = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF415A77);
  static const Color textPrimaryInverse = Color(0xFFE0E1DD);

  // Semantic Colors
  static const Color error = Color(0xFF780000); // Deep Accessible Red
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFFFB703);

  // Typography
  static const String fontFamily = 'Inter';
  static const double glassBlur = 12.0;

  // Spacing & Targets (Accessibility focused)
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;

  // Minimum Tap Target Size (WCAG Recommendation)
  static const double minTapTarget = 56.0;

  // Radii - Premium Soft Look
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 24.0;
  static const double radiusFull = 100.0;
}

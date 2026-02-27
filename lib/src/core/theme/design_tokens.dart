import 'package:flutter/material.dart';

/// DesignTokens centralizes all typography, colors, spacing, and radii
/// to ensure pixel-perfect fidelity and single-source-of-truth style updates.
class DesignTokens {
  // COLORS - Core
  static const Color primaryBlue = Color(0xFF004488);
  static const Color secondaryBlue = Color(0xFF003366);
  static const Color primaryCyan = Color(0xFF008394); // High contrast teal
  static const Color alertRed = Color(0xFFCC0000); // WCAG 2.1 AAA red

  // COLORS - Backgrounds
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceGrey = Color(0xFFF0F0F0);
  static const Color cardGrey = Color(0xFFF5F5F5);

  // COLORS - Text
  static const Color textOnLight = Color(0xFF000000);
  static const Color textOnDark = Color(0xFFFFFFFF);
  static const Color textSubtle = Color(0xFF666666);

  // COLORS - Status
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color warningYellow = Color(0xFFFBC02D);
  static const Color errorRed = Color(0xFFD32F2F);

  // SPACING
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // RADII
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;

  // TYPOGRAPHY (Sizes)
  static const double fontBody = 18.0; // Senior minimum reading size
  static const double fontHeaderItem = 22.0;
  static const double fontHeaderSection = 24.0;
  static const double fontHeaderPage = 28.0;
  static const double fontHeaderLarge = 32.0;
}

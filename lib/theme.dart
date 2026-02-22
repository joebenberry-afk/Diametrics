import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Senior Theme - Accessibility-first design system for elderly/visually impaired users.
///
/// Design Requirements (from ARCHITECTURE.md):
/// - Minimum font size: 18sp
/// - High contrast: Black/White/Yellow
/// - Font: Poppins, weight 500
/// - Primary Color: #004488 (High Contrast Blue)
class SeniorTheme {
  // ============================================================================
  // COLOR PALETTE - New UI Design
  // ============================================================================

  /// Primary brand color - Bright Cyan
  static const Color primaryCyan = Color(0xFF5CE1E6);

  /// Base Grey for the Glassy Cards
  static const Color cardGrey = Color(0xFFB3B3B3);

  /// Surface colors
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceBlack = Color(0xFF000000);

  /// Background Color
  static const Color backgroundLight = Color(0xFFE8F9F9);

  /// Text colors
  static const Color textOnLight = Color(0xFF000000);
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Error states
  static const Color errorRed = Color(0xFFE53935);
  static const Color successGreen = Color(0xFF2E7D32);

  // ============================================================================
  // TYPOGRAPHY - Minimum 18sp, Poppins Medium (500)
  // ============================================================================

  /// Base text style with Poppins font
  static TextStyle get _baseTextStyle =>
      GoogleFonts.poppins(fontWeight: FontWeight.w500, color: textOnLight);

  /// Heading - Large, prominent text (24sp)
  static TextStyle get headingStyle =>
      _baseTextStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w600);

  /// Body text - Standard readable size (18sp minimum)
  static TextStyle get bodyStyle => _baseTextStyle.copyWith(fontSize: 18);

  /// Button text - Slightly larger for touch targets (20sp)
  static TextStyle get buttonTextStyle => _baseTextStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textOnLight, // With bright cyan, dark text is better for contrast
  );

  /// Label text - For form fields and small labels (18sp minimum)
  static TextStyle get labelStyle =>
      _baseTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w500);

  // ============================================================================
  // THEME DATA - Complete Flutter ThemeData
  // ============================================================================

  /// Light theme for the app
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryCyan,
    scaffoldBackgroundColor: surfaceWhite,
    colorScheme: const ColorScheme.light(
      primary: primaryCyan,
      onPrimary: textOnLight,
      secondary: cardGrey,
      onSecondary: textOnLight,
      surface: surfaceWhite,
      onSurface: textOnLight,
      error: errorRed,
      onError: textOnDark,
    ),
    textTheme: TextTheme(
      headlineLarge: headingStyle,
      headlineMedium: headingStyle.copyWith(fontSize: 22),
      bodyLarge: bodyStyle,
      bodyMedium: bodyStyle,
      labelLarge: buttonTextStyle,
      labelMedium: labelStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryCyan,
        foregroundColor: textOnLight,
        textStyle: buttonTextStyle,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryCyan,
      foregroundColor: textOnLight,
      titleTextStyle: headingStyle.copyWith(color: textOnLight),
      elevation: 0,
      centerTitle: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: primaryCyan, width: 2),
      ),
      labelStyle: labelStyle,
      hintStyle: labelStyle.copyWith(color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),
  );

  /// Dark theme (Currently mirroring light theme structure just with dark bg, but can be adapted)
  static ThemeData get darkTheme => lightTheme.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: surfaceBlack,
    colorScheme: const ColorScheme.dark(
      primary: primaryCyan,
      onPrimary: textOnLight,
      secondary: cardGrey,
      onSecondary: textOnDark,
      surface: surfaceBlack,
      onSurface: textOnDark,
    ),
    // Can override other specific dark mode defaults here later if requested
  );
}

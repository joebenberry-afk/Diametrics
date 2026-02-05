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
  // COLOR PALETTE - High Contrast for Low Vision
  // ============================================================================

  /// Primary brand color - High Contrast Blue
  static const Color primaryBlue = Color(0xFF004488);

  /// Surface colors for maximum contrast
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceBlack = Color(0xFF000000);

  /// Accent color for warnings/alerts - High visibility yellow
  static const Color accentYellow = Color(0xFFFFD700);

  /// Text colors
  static const Color textOnLight = Color(0xFF000000);
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Error states
  static const Color errorRed = Color(0xFFB00020);
  static const Color successGreen = Color(0xFF2E7D32);

  // ============================================================================
  // TYPOGRAPHY - Minimum 18sp, Poppins Medium (500)
  // ============================================================================

  /// Base text style with Poppins font
  static TextStyle get _baseTextStyle => GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: textOnLight,
      );

  /// Heading - Large, prominent text (24sp)
  static TextStyle get headingStyle => _baseTextStyle.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  /// Body text - Standard readable size (18sp minimum)
  static TextStyle get bodyStyle => _baseTextStyle.copyWith(
        fontSize: 18,
      );

  /// Button text - Slightly larger for touch targets (20sp)
  static TextStyle get buttonTextStyle => _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textOnDark,
      );

  /// Label text - For form fields and small labels (18sp minimum)
  static TextStyle get labelStyle => _baseTextStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      );

  // ============================================================================
  // THEME DATA - Complete Flutter ThemeData
  // ============================================================================

  /// Light theme for the app
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: surfaceWhite,
        colorScheme: const ColorScheme.light(
          primary: primaryBlue,
          onPrimary: textOnDark,
          secondary: accentYellow,
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
            backgroundColor: primaryBlue,
            foregroundColor: textOnDark,
            textStyle: buttonTextStyle,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: textOnDark,
          titleTextStyle: headingStyle.copyWith(color: textOnDark),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 3),
          ),
          labelStyle: labelStyle,
          hintStyle: labelStyle.copyWith(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      );

  /// Dark theme (high contrast mode) for the app
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: accentYellow,
        scaffoldBackgroundColor: surfaceBlack,
        colorScheme: const ColorScheme.dark(
          primary: accentYellow,
          onPrimary: textOnLight,
          secondary: primaryBlue,
          onSecondary: textOnDark,
          surface: surfaceBlack,
          onSurface: textOnDark,
          error: errorRed,
          onError: textOnDark,
        ),
        textTheme: TextTheme(
          headlineLarge: headingStyle.copyWith(color: textOnDark),
          headlineMedium: headingStyle.copyWith(fontSize: 22, color: textOnDark),
          bodyLarge: bodyStyle.copyWith(color: textOnDark),
          bodyMedium: bodyStyle.copyWith(color: textOnDark),
          labelLarge: buttonTextStyle.copyWith(color: textOnLight),
          labelMedium: labelStyle.copyWith(color: textOnDark),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentYellow,
            foregroundColor: textOnLight,
            textStyle: buttonTextStyle.copyWith(color: textOnLight),
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: surfaceBlack,
          foregroundColor: textOnDark,
          titleTextStyle: headingStyle.copyWith(color: textOnDark),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accentYellow, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accentYellow, width: 3),
          ),
          labelStyle: labelStyle.copyWith(color: textOnDark),
          hintStyle: labelStyle.copyWith(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      );
}

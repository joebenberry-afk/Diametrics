import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_tokens.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppThemeTokens.brandPrimary,
        onPrimary: AppThemeTokens.textPrimaryInverse,
        secondary: AppThemeTokens.brandSecondary,
        onSecondary: AppThemeTokens.textPrimaryInverse,
        error: AppThemeTokens.error,
        onError: AppThemeTokens.textPrimaryInverse,
        surface: AppThemeTokens.bgSurface,
        onSurface: AppThemeTokens.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppThemeTokens.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppThemeTokens.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
          color: AppThemeTokens.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
          color: AppThemeTokens.textSecondary,
        ),
      ),
      scaffoldBackgroundColor: AppThemeTokens.bgBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppThemeTokens.brandPrimary,
        foregroundColor: AppThemeTokens.textPrimaryInverse,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppThemeTokens.brandPrimary,
          foregroundColor: AppThemeTokens.textPrimaryInverse,
          minimumSize: const Size.fromHeight(AppThemeTokens.minTapTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppThemeTokens.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
          side: const BorderSide(color: Color(0xFFD1D5DB), width: 1),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppThemeTokens.brandAccent,
        onPrimary: AppThemeTokens.textPrimary,
        secondary: AppThemeTokens.brandSecondary,
        onSecondary: AppThemeTokens.textPrimaryInverse,
        error: AppThemeTokens.error,
        onError: AppThemeTokens.textPrimaryInverse,
        surface: AppThemeTokens.bgSurfaceDark,
        onSurface: AppThemeTokens.textPrimaryInverse,
      ),
      textTheme:
          GoogleFonts.interTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme,
          ).copyWith(
            displayLarge: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppThemeTokens.textPrimaryInverse,
            ),
            headlineMedium: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppThemeTokens.textPrimaryInverse,
            ),
            bodyLarge: GoogleFonts.inter(
              fontSize: 18,
              color: AppThemeTokens.textPrimaryInverse,
            ),
            bodyMedium: GoogleFonts.inter(
              fontSize: 16,
              color: AppThemeTokens.textPrimaryInverse.withValues(alpha: 0.7),
            ),
          ),
      scaffoldBackgroundColor: AppThemeTokens.bgBackgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppThemeTokens.bgSurfaceDark,
        foregroundColor: AppThemeTokens.textPrimaryInverse,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppThemeTokens.brandAccent,
          foregroundColor: AppThemeTokens.textPrimary,
          minimumSize: const Size.fromHeight(AppThemeTokens.minTapTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppThemeTokens.radiusMd),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppThemeTokens.bgSurfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeTokens.radiusLg),
          side: BorderSide(
            color: AppThemeTokens.brandSecondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}

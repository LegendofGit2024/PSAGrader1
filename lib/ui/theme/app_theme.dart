import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Deep Onyx palette — "The Museum Principle"
abstract class AppColors {
  static const background = Color(0xFF0F1115);       // Deep Onyx
  static const surface = Color(0xFF1A1D23);          // Elevated surface
  static const surfaceVariant = Color(0xFF22262E);   // Card surface
  static const border = Color(0xFF2C313B);           // Subtle border

  static const accent = Color(0xFFE8C547);           // Gold — premium feel
  static const accentSoft = Color(0xFF4A9EFF);       // Blue — data/info
  static const success = Color(0xFF34C97B);          // Green — gains
  static const danger = Color(0xFFFF5A5A);           // Red — losses
  static const warning = Color(0xFFFFAA33);          // Amber — caution

  static const textPrimary = Color(0xFFF2F4F7);
  static const textSecondary = Color(0xFF8E95A3);
  static const textDisabled = Color(0xFF4A5060);
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        primary: AppColors.accent,
        secondary: AppColors.accentSoft,
        error: AppColors.danger,
        onSurface: AppColors.textPrimary,
        onPrimary: AppColors.background,
        outline: AppColors.border,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textDisabled,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }
}

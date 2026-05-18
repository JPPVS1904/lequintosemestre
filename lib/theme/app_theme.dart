import 'package:flutter/material.dart';

/// Design tokens matching the Svelte app.css color palette.
class AppColors {
  // ── Light Mode ──
  static const lightBgPrimary = Color(0xFFF2EDE4);
  static const lightBgSecondary = Color(0xFFEAE4D9);
  static const lightTextPrimary = Color(0xFF1A1C1E);
  static const lightTextSecondary = Color(0xFF44474A);
  static const lightBorderUi = Color(0xFFD9D3C8);

  // ── Dark Mode ──
  static const darkBgPrimary = Color(0xFF0D0F11);
  static const darkBgSecondary = Color(0xFF16191C);
  static const darkTextPrimary = Color(0xFFF0F2F5);
  static const darkTextSecondary = Color(0xFF9BA1A6);
  static const darkBorderUi = Color(0xFF2A2D31);

  // ── Brand (shared) ──
  static const brand = Color(0xFFC4982A);
  static const brandButton = Color(0xFFC79E3A);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.lightBgPrimary,
      colorScheme: ColorScheme.light(
        surface: AppColors.lightBgPrimary,
        onSurface: AppColors.lightTextPrimary,
        primary: AppColors.brand,
        onPrimary: Colors.white,
        secondary: AppColors.lightBgSecondary,
        onSecondary: AppColors.lightTextPrimary,
        outline: AppColors.lightBorderUi,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 20,
          fontFamily: 'Inter',
        ),
      ),
      dividerColor: AppColors.lightBorderUi,
      cardColor: AppColors.lightBgSecondary,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBgPrimary.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorderUi),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorderUi),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.brand, width: 2),
        ),
        labelStyle: const TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
        hintStyle: TextStyle(
          color: AppColors.lightTextSecondary.withValues(alpha: 0.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandButton,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.5,
            fontFamily: 'Inter',
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.brand;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: AppColors.lightBorderUi),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.darkBgPrimary,
      colorScheme: ColorScheme.dark(
        surface: AppColors.darkBgPrimary,
        onSurface: AppColors.darkTextPrimary,
        primary: AppColors.brand,
        onPrimary: Colors.white,
        secondary: AppColors.darkBgSecondary,
        onSecondary: AppColors.darkTextPrimary,
        outline: AppColors.darkBorderUi,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontWeight: FontWeight.w900,
          fontSize: 20,
          fontFamily: 'Inter',
        ),
      ),
      dividerColor: AppColors.darkBorderUi,
      cardColor: AppColors.darkBgSecondary,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBgPrimary.withValues(alpha: 0.5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorderUi),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkBorderUi),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.brand, width: 2),
        ),
        labelStyle: const TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
        hintStyle: TextStyle(
          color: AppColors.darkTextSecondary.withValues(alpha: 0.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandButton,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.5,
            fontFamily: 'Inter',
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.brand;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: AppColors.darkBorderUi),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

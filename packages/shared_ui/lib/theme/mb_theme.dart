import 'package:flutter/material.dart';
import 'mb_colors.dart';
import 'mb_radius.dart';
import 'mb_text_styles.dart';

class MBTheme {
  MBTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: MBTextStyles.fontFamily,
      scaffoldBackgroundColor: MBColors.background,
      primaryColor: MBColors.primary,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      disabledColor: MBColors.disabled,

      colorScheme: const ColorScheme.light(
        primary: MBColors.primary,
        secondary: MBColors.secondaryOrange,
        surface: MBColors.surface,
        error: MBColors.error,
        onPrimary: MBColors.textOnPrimary,
        onSurface: MBColors.textPrimary,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: MBColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        color: MBColors.card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MBRadius.lg),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: MBColors.divider,
        thickness: 1,
      ),

      textTheme: const TextTheme(
        headlineLarge: MBTextStyles.hero,
        headlineSmall: MBTextStyles.pageTitle,
        titleLarge: MBTextStyles.sectionTitle,
        bodyLarge: MBTextStyles.bodyMedium,
        bodyMedium: MBTextStyles.body,
        bodySmall: MBTextStyles.caption,
        labelLarge: MBTextStyles.button,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MBColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MBRadius.md),
          borderSide: const BorderSide(color: MBColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MBRadius.md),
          borderSide: const BorderSide(color: MBColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MBRadius.md),
          borderSide: const BorderSide(
            color: MBColors.primary,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MBRadius.md),
          borderSide: const BorderSide(color: MBColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(MBRadius.md),
          borderSide: const BorderSide(
            color: MBColors.error,
            width: 1.2,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          backgroundColor: MBColors.primary,
          foregroundColor: MBColors.textOnPrimary,
          disabledBackgroundColor: MBColors.disabled,
          disabledForegroundColor: MBColors.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MBRadius.md),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MBColors.primary,
          side: const BorderSide(color: MBColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MBRadius.md),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MBColors.primary,
        ),
      ),
    );
  }
}












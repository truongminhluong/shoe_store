import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_fonts.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    fontFamily: AppFonts.fontFamily,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),

    textTheme: const TextTheme(
      displayLarge: AppFonts.headingLarge,
      headlineMedium: AppFonts.headingMedium,
      titleLarge: AppFonts.title,
      bodyLarge: AppFonts.bodyMedium,
      bodyMedium: AppFonts.body,
      bodySmall: AppFonts.caption,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),

      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}

// lib/app/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,

    colorScheme: const ColorScheme.dark(
      primary:          AppColors.primary,
      primaryContainer: AppColors.primaryDark,
      secondary:        AppColors.primaryLight,
      surface:          AppColors.surface,
      error:            AppColors.error,
      onPrimary:        AppColors.textPrimary,
      onSurface:        AppColors.textPrimary,
      onError:          AppColors.textPrimary,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceElevated,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      prefixIconColor: AppColors.textHint,
      suffixIconColor: AppColors.textHint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      errorStyle: const TextStyle(color: AppColors.error, fontSize: 11),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textPrimary,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    ),

    textTheme: const TextTheme(
      headlineLarge:  TextStyle(color: AppColors.textPrimary, fontSize: 36, fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w700),
      titleLarge:     TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
      titleMedium:    TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge:      TextStyle(color: AppColors.textSecondary, fontSize: 15),
      bodyMedium:     TextStyle(color: AppColors.textSecondary, fontSize: 14),
      bodySmall:      TextStyle(color: AppColors.textHint, fontSize: 12),
      labelLarge:     TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.4),
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surface,
      contentTextStyle: const TextStyle(color: AppColors.textPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),

cardTheme: CardThemeData(
        color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
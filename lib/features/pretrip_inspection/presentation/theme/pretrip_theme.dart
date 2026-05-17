// lib/features/pretrip_inspection/presentation/theme/pretrip_theme.dart
//
// ⚠️  Ce fichier ne définit AUCUNE couleur.
//    Toutes les valeurs proviennent de AppColors (lib/app/theme/app_colors.dart).
//    Pour modifier une couleur, éditez AppColors uniquement.

import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

class PreTripTheme {
  PreTripTheme._();

  // ── Couleurs (délégation pure vers AppColors) ──────────
  static const Color primary       = AppColors.primary;
  static const Color primaryLight  = AppColors.primaryLight;
  static const Color primaryDark   = AppColors.primaryDark;
  static const Color bg            = AppColors.background;
  static const Color surface1      = AppColors.surface;
  static const Color surface2      = AppColors.surfaceElevated;
  static const Color border        = AppColors.border;
  static const Color textPrimary   = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textHint      = AppColors.textHint;
  static const Color success       = AppColors.success;
  static const Color error         = AppColors.error;

  // ── Couleurs dérivées (opacité) ────────────────────────
  static Color get primaryDim  => AppColors.primary.withOpacity(0.18);
  static Color get primaryGlow => AppColors.primaryGlow;

  // ── Shadows ────────────────────────────────────────────
  static List<BoxShadow> get orangeGlow => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.45),
          blurRadius: 16,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get orangeGlowStrong => [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.55),
          blurRadius: 24,
          spreadRadius: 2,
        ),
      ];

  // ── Gradients ──────────────────────────────────────────
  static LinearGradient get heroGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.background, AppColors.surface],
      );

  static LinearGradient get orangeGradient => const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [AppColors.primary, AppColors.primaryLight],
      );

  // ── Decorations helpers ────────────────────────────────
  static BoxDecoration cardDecoration({
    Color? borderColor,
    List<BoxShadow>? shadows,
    Color? bgColor,
  }) =>
      BoxDecoration(
        color: bgColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? AppColors.border, width: 1),
        boxShadow: shadows,
      );
}
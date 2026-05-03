// lib/app/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────
  static const Color primary         = Color(0xFFEA580C); // orange-600
  static const Color primaryLight    = Color(0xFFFB923C); // orange-400
  static const Color primaryDark     = Color(0xFFC2410C); // orange-700
  static const Color primaryGlow     = Color(0x40EA580C); // 25% opacity

  // ── Backgrounds ────────────────────────────────────────
  static const Color background      = Color(0xFF0A0A0A);
  static const Color surface         = Color(0xFF141414);
  static const Color surfaceElevated = Color(0xFF1E1E1E);
  static const Color overlay         = Color(0xFF2A2A2A);

  // ── Text ───────────────────────────────────────────────
  static const Color textPrimary     = Color(0xFFFFFFFF);
  static const Color textSecondary   = Color(0xFFB3B3B3);
  static const Color textHint        = Color(0xFF666666);
  static const Color textDisabled    = Color(0xFF3D3D3D);

  // ── Semantic ───────────────────────────────────────────
  static const Color error           = Color(0xFFFF6B6B);
  static const Color errorDark       = Color(0xFFD32F2F);
  static const Color success         = Color(0xFF4CAF50);

  // ── Borders ────────────────────────────────────────────
  static const Color border          = Color(0xFF2E2E2E);
}
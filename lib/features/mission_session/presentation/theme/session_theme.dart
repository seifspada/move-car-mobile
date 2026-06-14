// lib/features/mission_session/presentation/theme/session_theme.dart

import 'package:flutter/material.dart';

abstract class SessionTheme {
  // ── Couleurs ──────────────────────────────
  static const bg         = Color(0xFF0A0F1E);
  static const surface1   = Color(0xFF111827);
  static const surface2   = Color(0xFF1C2537);
  static const border     = Color(0xFF1E293B);

  static const primary      = Color(0xFFF97316); // orange
  static const primaryLight = Color(0xFFFB923C);
  static const primaryDim   = Color(0x26F97316);

  static const success = Color(0xFF22C55E);
  static const error   = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  static const textPrimary   = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textHint      = Color(0xFF64748B);

  // ── Gradients ─────────────────────────────
  static const orangeGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ── Shadows ───────────────────────────────
  static final orangeGlow = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
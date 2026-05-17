// lib/features/pretrip_inspection/presentation/widgets/inspection_status_badge.dart

import 'package:convoyeur_mobile/features/pretrip_inspection/data/models/pretrip_model.dart';
import 'package:flutter/material.dart';
import '../theme/pretrip_theme.dart';

class InspectionStatusBadge extends StatelessWidget {
  final StatutPreTrip statut;
  final bool compact;

  const InspectionStatusBadge({
    super.key,
    required this.statut,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (statut) {
      StatutPreTrip.draft      => ('BROUILLON',  PreTripTheme.textHint),
      StatutPreTrip.inProgress => ('EN COURS',   PreTripTheme.primary),
      StatutPreTrip.completed  => ('COMPLÈTE',   PreTripTheme.primaryLight),
      StatutPreTrip.validated  => ('VALIDÉE',    PreTripTheme.success),
      StatutPreTrip.rejected   => ('REJETÉE',    PreTripTheme.error),
    };

    final isActive = statut == StatutPreTrip.inProgress;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 5 : 7,
      ),
      // ✅ Couleur dans BoxDecoration
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(isActive ? 0.6 : 0.35),
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 10 : 11,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
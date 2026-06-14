// lib/features/mission_session/presentation/widgets/mission_session_status_badge.dart

import 'package:flutter/material.dart';
import '../../domain/entities/mission_session_entity.dart';
import '../theme/session_theme.dart';

class MissionSessionStatusBadge extends StatelessWidget {
  final StatutSession statut;

  const MissionSessionStatusBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final isActive = statut == StatutSession.EN_COURS;
    final color  = isActive ? SessionTheme.primary : SessionTheme.success;
    final label  = isActive ? 'EN COURS' : 'TERMINÉE';
    final icon   = isActive ? Icons.radio_button_checked : Icons.check_circle_outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
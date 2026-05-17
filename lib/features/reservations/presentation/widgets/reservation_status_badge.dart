// lib/features/reservations/presentation/widgets/reservation_status_badge.dart

import 'package:flutter/material.dart';

// ── Config par statut ──────────────────────────────────────
class _StatusConfig {
  final String label;
  final Color color;
  final bool pulse;
  const _StatusConfig(this.label, this.color, {this.pulse = false});
}

const _configs = {
  'EN_ATTENTE':            _StatusConfig('En attente',       Color(0xFFEAB308), pulse: true),
  'ACCEPTED_BY_AGENT':     _StatusConfig('À confirmer',      Color(0xFF3B82F6), pulse: true),
  'CONFIRMED_BY_ADHERENT': _StatusConfig('Confirmée',        Color(0xFF22C55E)),
  'ANNULATION_DEMANDEE':   _StatusConfig('Annul. demandée',  Color(0xFFF97316), pulse: true),
  'REFUSEE':               _StatusConfig('Refusée',          Color(0xFFEF4444)),
  'ANNULEE':               _StatusConfig('Annulée',          Color(0xFF71717A)),
  'TERMINEE':              _StatusConfig('Terminée',         Color(0xFFA855F7)),
  'EN_COURS':              _StatusConfig('En cours',         Color(0xFF06B6D4), pulse: true),
};

class ReservationStatusBadge extends StatefulWidget {
  final String statut;
  final bool small;

  const ReservationStatusBadge({
    super.key,
    required this.statut,
    this.small = false,
  });

  @override
  State<ReservationStatusBadge> createState() => _ReservationStatusBadgeState();
}

class _ReservationStatusBadgeState extends State<ReservationStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    final cfg = _configs[widget.statut];
    if (cfg?.pulse == true) {
      _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..repeat(reverse: true);
      _opacity = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
      );
    } else {
      _ctrl = AnimationController(vsync: this);
      _opacity = const AlwaysStoppedAnimation(1.0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _configs[widget.statut] ??
        const _StatusConfig('Inconnu', Color(0xFF71717A));
    final color = cfg.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.small ? 6 : 10,
        vertical:   widget.small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Dot animé
          AnimatedBuilder(
            animation: _opacity,
            builder: (_, __) => Opacity(
              opacity: _opacity.value,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            cfg.label,
            style: TextStyle(
              color: color,
              fontSize: widget.small ? 9 : 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
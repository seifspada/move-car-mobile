// lib/features/reservations/presentation/widgets/reservation_card.dart

import 'package:flutter/material.dart';
import 'package:convoyeur_mobile/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/reservation_entity.dart';
import 'cancel_modal.dart';
import 'countdown_badge.dart';
import 'reservation_status_badge.dart';

class ReservationCard extends StatefulWidget {
  final ReservationEntity reservation;
  final bool isActionLoading;
  final Future<void> Function(String id, String? motif) onCancel;
  final Future<void> Function(String id, String motif) onRequestCancellation;
  final Future<void> Function(String id) onConfirm;
  final Future<void> Function(String id) onCancelPending;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.isActionLoading,
    required this.onCancel,
    required this.onRequestCancellation,
    required this.onConfirm,
    required this.onCancelPending,
  });

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  late final AnimationController _expandCtrl;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(parent: _expandCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _expandCtrl.forward();
    } else {
      _expandCtrl.reverse();
    }
  }

  // ── Calculs délais ─────────────────────────────────────
  DateTime? get _departDate {
    try {
      final datePart = DateTime.parse(
        widget.reservation.dateDepart,
      ).toIso8601String().split('T')[0];
      return DateTime.parse('${datePart}T${widget.reservation.heureDepart}:00');
    } catch (_) {
      return null;
    }
  }

  DateTime? get _creationDate {
    final d = widget.reservation.dateCreation;
    if (d == null) return null;
    try {
      return DateTime.parse(d);
    } catch (_) {
      return null;
    }
  }

  bool get _isWithin24h {
    final c = _creationDate;
    if (c == null) return false;
    return DateTime.now().difference(c).inHours <= 24;
  }

  bool get _isTooClose {
    final d = _departDate;
    if (d == null) return false;
    return d.difference(DateTime.now()).inHours < 1;
  }

  bool get _isMissionReady {
    final d = _departDate;
    if (d == null) return false;
    return DateTime.now().isAfter(d) &&
        widget.reservation.statut == 'CONFIRMED_BY_ADHERENT';
  }

  // ── Permissions ────────────────────────────────────────
  bool get _canCancelPending =>
      widget.reservation.statut == 'EN_ATTENTE' && !_isTooClose;

  bool get _canCancelDirect =>
      widget.reservation.statut == 'ACCEPTED_BY_AGENT' &&
      _isWithin24h &&
      !_isTooClose;

  bool get _canRequestCancellation =>
      [
        'ACCEPTED_BY_AGENT',
        'CONFIRMED_BY_ADHERENT',
      ].contains(widget.reservation.statut) &&
      !_isWithin24h &&
      !_isTooClose;

  bool get _canConfirm => widget.reservation.statut == 'ACCEPTED_BY_AGENT';

  bool get _showCountdown =>
      [
        'EN_ATTENTE',
        'ACCEPTED_BY_AGENT',
        'CONFIRMED_BY_ADHERENT',
      ].contains(widget.reservation.statut) &&
      _departDate != null;

  // ── Border color selon statut ──────────────────────────
  Color get _borderColor {
    switch (widget.reservation.statut) {
      case 'ACCEPTED_BY_AGENT':
        return const Color(0xFF3B82F6).withOpacity(0.4);
      case 'CONFIRMED_BY_ADHERENT':
        return _isMissionReady
            ? const Color(0xFF22C55E).withOpacity(0.5)
            : AppColors.border;
      case 'ANNULATION_DEMANDEE':
        return AppColors.primary.withOpacity(0.3);
      default:
        return AppColors.border;
    }
  }

  String _formatDate(String? d) {
    if (d == null) return '—';
    try {
      final dt = DateTime.parse(d);
      return '${dt.day.toString().padLeft(2, '0')} ${_monthName(dt.month)} ${dt.year}';
    } catch (_) {
      return '—';
    }
  }

  String _monthName(int m) {
    const months = [
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'juin',
      'juil',
      'aoû',
      'sep',
      'oct',
      'nov',
      'déc',
    ];
    return months[m - 1];
  }

  void _handleCancelClick() {
    final mode = _isWithin24h ? CancelMode.direct : CancelMode.request;
    CancelModal.show(
      context: context,
      mode: mode,
      onConfirm: (motif) async {
        if (mode == CancelMode.direct) {
          await widget.onCancel(widget.reservation.id, motif);
        } else {
          await widget.onRequestCancellation(
            widget.reservation.id,
            motif ?? '',
          );
        }
      },
    );
  }

 // APRÈS
// APRÈS
void _handleLaunchMission() {
  context.go('/pretrip-inspection/${widget.reservation.id}');
}

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;
    final villeDepart = r.mission?.villeDepart ?? '?';
    final villeArrivee = r.mission?.villeArrivee ?? '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor, width: 1.5),
        boxShadow: [
          if (r.statut == 'ACCEPTED_BY_AGENT')
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          if (_isMissionReady)
            BoxShadow(
              color: const Color(0xFF22C55E).withOpacity(0.12),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Bandeaux statut ───────────────────────
            if (r.statut == 'ACCEPTED_BY_AGENT')
              _StatusBanner(
                color: const Color(0xFF3B82F6),
                icon: Icons.info_outline_rounded,
                text: 'Action requise — confirmez votre réservation',
              ),
            if (r.statut == 'ANNULATION_DEMANDEE')
              _StatusBanner(
                color: AppColors.primary,
                icon: Icons.access_time_rounded,
                text: "Demande d'annulation en attente de validation",
              ),
            if (_isMissionReady)
              _StatusBanner(
                color: const Color(0xFF22C55E),
                icon: Icons.rocket_launch_rounded,
                text: 'Mission prête — vous pouvez démarrer',
              ),

            // ── Corps ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trajet + badge statut
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: AppColors.primary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    villeDepart,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 6),
                                  child: Text(
                                    '→',
                                    style: TextStyle(
                                      color: AppColors.textHint,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    villeArrivee,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              r.numeroReservation,
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ReservationStatusBadge(statut: r.statut),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Date + heure
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        text: _formatDate(r.dateDepart),
                      ),
                      const SizedBox(width: 12),
                      _InfoChip(
                        icon: Icons.access_time_outlined,
                        text: '${r.heureDepart} → ${r.heureArrivee ?? '?'}',
                      ),
                      if (r.dureeEstimee != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${r.dureeEstimee} min',
                          style: const TextStyle(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  // ── Countdown ou Launch Mission ────────
                  if (_showCountdown) ...[
                    if (!_isMissionReady)
                      Text(
                        'Départ dans',
                        style: TextStyle(
                          color: AppColors.textHint.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                        ),
                      ),
                    if (!_isMissionReady) const SizedBox(height: 6),
                    CountdownBadge(
                      targetDate: _departDate!,
                      statut: r.statut,
                      onMissionReady: () => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // ── Bouton Launch Mission ──────────────
                  if (_isMissionReady) ...[
                    _LaunchMissionButton(onTap: _handleLaunchMission),
                    const SizedBox(height: 10),
                  ],

                  // Montant
                  if (r.montantTotal != null) ...[
                    Row(
                      children: [
                        Text(
                          '${r.montantTotal!.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (r.fraisPeage != null && r.fraisPeage! > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '+ ${r.fraisPeage!.toStringAsFixed(2)} € péage',
                            style: const TextStyle(
                              color: AppColors.textHint,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Motif refus
                  if (r.statut == 'REFUSEE' && r.motifRefus != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.2),
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(
                              text: 'Motif : ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                            TextSpan(text: r.motifRefus),
                          ],
                        ),
                      ),
                    ),

                  // ── Actions ──────────────────────────
                  Row(
                    children: [
                      // Annuler EN_ATTENTE
                      if (_canCancelPending)
                        Expanded(
                          child: _ActionButton(
                            label: 'Annuler la demande',
                            icon: Icons.cancel_outlined,
                            isLoading: widget.isActionLoading,
                            style: _ActionStyle.outline,
                            onTap: () => widget.onCancelPending(r.id),
                          ),
                        ),

                      // Confirmer
                      if (_canConfirm) ...[
                        Expanded(
                          child: _ActionButton(
                            label: 'Confirmer',
                            icon: Icons.check_circle_outline,
                            isLoading: widget.isActionLoading,
                            style: _ActionStyle.green,
                            onTap: () => widget.onConfirm(r.id),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Annuler / Demande annulation
                      if (_canCancelDirect || _canRequestCancellation) ...[
                        _canConfirm
                            ? _ActionButton(
                                label: _isWithin24h
                                    ? 'Annuler'
                                    : 'Dem. annulation',
                                icon: Icons.cancel_outlined,
                                isLoading: widget.isActionLoading,
                                style: _isWithin24h
                                    ? _ActionStyle.red
                                    : _ActionStyle.orange,
                                compact: true,
                                onTap: _handleCancelClick,
                              )
                            : Expanded(
                                child: _ActionButton(
                                  label: _isWithin24h
                                      ? 'Annuler'
                                      : 'Demander annulation',
                                  icon: Icons.cancel_outlined,
                                  isLoading: widget.isActionLoading,
                                  style: _isWithin24h
                                      ? _ActionStyle.red
                                      : _ActionStyle.orange,
                                  onTap: _handleCancelClick,
                                ),
                              ),
                        const SizedBox(width: 8),
                      ],

                      // Expand
                      GestureDetector(
                        onTap: _toggleExpand,
                        child: AnimatedRotation(
                          turns: _expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 280),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textHint,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ── Détails expandables ───────────────
                  SizeTransition(
                    sizeFactor: _expandAnim,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 14),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 16,
                          runSpacing: 10,
                          children: [
                            if (r.dateAcceptationAgent != null)
                              _DetailItem(
                                label: 'Acceptée le',
                                value: _formatDate(r.dateAcceptationAgent),
                              ),
                            if (r.dateConfirmationAdherent != null)
                              _DetailItem(
                                label: 'Confirmée le',
                                value: _formatDate(r.dateConfirmationAdherent),
                              ),
                            if (r.dateAnnulation != null)
                              _DetailItem(
                                label: 'Annulée le',
                                value: _formatDate(r.dateAnnulation),
                              ),
                            if (r.distanceKm != null)
                              _DetailItem(
                                label: 'Distance',
                                value: '${r.distanceKm!.toStringAsFixed(1)} km',
                              ),
                          ],
                        ),
                        if (r.motifAnnulation != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.2),
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Motif annulation : ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  TextSpan(text: r.motifAnnulation),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bandeau statut ─────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;

  const _StatusBanner({
    required this.color,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border(bottom: BorderSide(color: color.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chip info ──────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textHint, size: 12),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: AppColors.textHint, fontSize: 11),
        ),
      ],
    );
  }
}

// ── Détail item ────────────────────────────────────────────
class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textHint, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Bouton action ──────────────────────────────────────────
enum _ActionStyle { outline, green, red, orange }

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final bool compact;
  final _ActionStyle style;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.style,
    required this.onTap,
    this.compact = false,
  });

  Color get _color {
    switch (style) {
      case _ActionStyle.green:
        return const Color(0xFF22C55E);
      case _ActionStyle.red:
        return const Color(0xFFEF4444);
      case _ActionStyle.orange:
        return AppColors.primary;
      default:
        return AppColors.textHint;
    }
  }

  bool get _filled => style != _ActionStyle.outline;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 38,
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 0),
        decoration: BoxDecoration(
          color: _filled ? _color : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _filled ? _color : AppColors.border),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _filled ? Colors.white : AppColors.textHint,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 14,
                      color: _filled ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        color: _filled ? Colors.white : AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Bouton Launch Mission ──────────────────────────────────
class _LaunchMissionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LaunchMissionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Launch Mission',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

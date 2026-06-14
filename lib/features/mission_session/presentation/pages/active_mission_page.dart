// lib/features/mission_session/presentation/pages/active_mission_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/mission_session_entity.dart';
import '../theme/session_theme.dart';
import '../widgets/mission_session_status_badge.dart';
import 'end_mission_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────

class ActiveMissionPage extends ConsumerStatefulWidget {
  final String reservationId;
  final MissionSessionEntity session;
  final double latitudeArrivee;
  final double longitudeArrivee;
  final String villeArrivee;

  const ActiveMissionPage({
    super.key,
    required this.reservationId,
    required this.session,
    this.latitudeArrivee = 36.8189,
    this.longitudeArrivee = 10.1658,
    this.villeArrivee = 'Destination',
  });

  @override
  ConsumerState<ActiveMissionPage> createState() => _ActiveMissionPageState();
}

class _ActiveMissionPageState extends ConsumerState<ActiveMissionPage>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _entranceCtrl;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  late MissionSessionEntity _session;

  @override
  void initState() {
    super.initState();
    _session = widget.session;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Pulse animation for the "EN COURS" indicator
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Entrance animation
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  // ── Duration elapsed ──────────────────────────────────────────

  String get _elapsedLabel {
    final elapsed = DateTime.now().difference(_session.dateDebut);
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}min';
    return '${m}min';
  }

  String _fmt(DateTime d) {
    final l = d.toLocal();
    return '${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }

  // ── Navigation ────────────────────────────────────────────────

  void _openIncident() {
    // Navigate to incident page — route to be wired in go_router
    context.push(
      '/mission_incident/${_session.missionId}/${_session.id}',
      extra: {
        'reservationId': widget.reservationId,
        'latitude': _session.latitudeDebut,
        'longitude': _session.longitudeDebut,
      },
    );
  }

  void _openTracking() {
    // Navigate to GPS tracking page
    context.push(
      '/mission_tracking/${_session.missionId}/${_session.id}',
      extra: {
        'reservationId': widget.reservationId,
        'latitudeArrivee': widget.latitudeArrivee,
        'longitudeArrivee': widget.longitudeArrivee,
        'villeArrivee': widget.villeArrivee,
      },
    );
  }

  Future<void> _openEndMission() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EndMissionPage(
          reservationId: widget.reservationId,
          session: _session,
        ),
      ),
    );
    // If end was confirmed, pop back to reservation list
    if (result == true && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SessionTheme.bg,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(position: _slideAnim, child: _buildBody()),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: SessionTheme.surface1,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        color: SessionTheme.textSecondary,
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'Mission active',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: SessionTheme.textPrimary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: MissionSessionStatusBadge(statut: _session.statut),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        // ── Live indicator ────────────────────────
        _LiveIndicator(pulseAnim: _pulseAnim, elapsedLabel: _elapsedLabel),
        const SizedBox(height: 20),

        // ── Mission info card ─────────────────────
        _MissionInfoCard(session: _session, fmt: _fmt),
        const SizedBox(height: 32),

        // ── Section label ─────────────────────────
        const Text(
          'Actions disponibles',
          style: TextStyle(
            color: SessionTheme.textHint,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 14),

        // ── Button: Cas d'incident ────────────────
        _ActionButton(
          icon: Icons.warning_amber_rounded,
          label: "Signaler un incident",
          subtitle: "Accident, panne, déviation GPS...",
          color: SessionTheme.warning,
          onTap: _openIncident,
        ),
        const SizedBox(height: 12),

        // ── Button: Suivre le trajet ──────────────
        _ActionButton(
          icon: Icons.map_outlined,
          label: "Suivre le trajet",
          subtitle: "Carte GPS en temps réel",
          color: SessionTheme.primary,
          onTap: _openTracking,
        ),
        const SizedBox(height: 12),

        // ── Button: Terminer la mission ───────────
        _ActionButton(
          icon: Icons.flag_outlined,
          label: "Terminer la mission",
          subtitle: "Photos de livraison + confirmation GPS",
          color: SessionTheme.success,
          onTap: _openEndMission,
          isPrimary: true,
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Pulsing "live" indicator at the top of the page
class _LiveIndicator extends StatelessWidget {
  final Animation<double> pulseAnim;
  final String elapsedLabel;

  const _LiveIndicator({required this.pulseAnim, required this.elapsedLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: SessionTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SessionTheme.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          // Pulsing dot
          AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, __) => Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: SessionTheme.primary.withOpacity(pulseAnim.value),
                boxShadow: [
                  BoxShadow(
                    color: SessionTheme.primary.withOpacity(
                      pulseAnim.value * 0.5,
                    ),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Mission en cours',
            style: TextStyle(
              color: SessionTheme.primaryLight,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: SessionTheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.timer_outlined,
                  size: 12,
                  color: SessionTheme.primaryLight,
                ),
                const SizedBox(width: 4),
                Text(
                  elapsedLabel,
                  style: const TextStyle(
                    color: SessionTheme.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Info card: reservation ID, start time, km
class _MissionInfoCard extends StatelessWidget {
  final MissionSessionEntity session;
  final String Function(DateTime) fmt;

  const _MissionInfoCard({required this.session, required this.fmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SessionTheme.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SessionTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Détails de la mission',
            style: TextStyle(
              color: SessionTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.confirmation_number_outlined,
            label: 'Réservation',
            value: '#${session.reservationId.substring(0, 8).toUpperCase()}',
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.access_time_outlined,
            label: 'Départ',
            value: fmt(session.dateDebut),
          ),
          if (session.kilometrageDebut != null) ...[
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.speed_outlined,
              label: 'Km départ',
              value: '${session.kilometrageDebut} km',
            ),
          ],
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'GPS départ',
            value:
                '${session.latitudeDebut.toStringAsFixed(4)}, ${session.longitudeDebut.toStringAsFixed(4)}',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: SessionTheme.textHint),
        const SizedBox(width: 8),
        Text(
          '$label :',
          style: const TextStyle(color: SessionTheme.textHint, fontSize: 12),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: SessionTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// A tappable action button card
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _tapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _tapCtrl;
  }

  @override
  void dispose() {
    _tapCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _tapCtrl.reverse();
  void _onTapUp(_) {
    _tapCtrl.forward();
    widget.onTap();
  }

  void _onTapCancel() => _tapCtrl.forward();

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? widget.color.withOpacity(0.12)
                : SessionTheme.surface1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isPrimary
                  ? widget.color.withOpacity(0.4)
                  : SessionTheme.border,
              width: widget.isPrimary ? 1.5 : 1.0,
            ),
            boxShadow: widget.isPrimary
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(width: 14),
              // Labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.isPrimary
                            ? widget.color
                            : SessionTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: SessionTheme.textHint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow
              Icon(
                Icons.chevron_right_rounded,
                color: widget.isPrimary ? widget.color : SessionTheme.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

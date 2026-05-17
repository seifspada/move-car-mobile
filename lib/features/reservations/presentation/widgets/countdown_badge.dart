// lib/features/reservations/presentation/widgets/countdown_badge.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:convoyeur_mobile/app/theme/app_colors.dart';

class CountdownBadge extends StatefulWidget {
  final DateTime targetDate;
  final String statut;
  final VoidCallback? onMissionReady; // ← nouveau

  const CountdownBadge({
    super.key,
    required this.targetDate,
    required this.statut,
    this.onMissionReady,             // ← nouveau
  });

  @override
  State<CountdownBadge> createState() => _CountdownBadgeState();
}

class _CountdownBadgeState extends State<CountdownBadge>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  bool _missionReadyFired = false;   // ← évite les appels répétés

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _compute();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _compute());
  }

  void _compute() {
    final diff = widget.targetDate.difference(DateTime.now());
    final newTimeLeft = diff.isNegative ? Duration.zero : diff;

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _timeLeft = newTimeLeft);
      });
    }

    // ── Déclenche le callback une seule fois quand le compte atteint zéro ──
    if (newTimeLeft == Duration.zero &&
        !_missionReadyFired &&
        widget.onMissionReady != null) {
      _missionReadyFired = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onMissionReady!();
      });
    }

    final isUrgent  = _timeLeft.inHours < 2;
    final isWarning = _timeLeft.inHours < 24;
    if ((isUrgent || isWarning) && !_pulseCtrl.isAnimating) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!isUrgent && !isWarning && _pulseCtrl.isAnimating) {
      _pulseCtrl.stop();
      _pulseCtrl.value = 1.0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft == Duration.zero) {
      return _buildChip(
        color: const Color(0xFF71717A),
        label: 'Mission passée',
        pulse: false,
      );
    }

    final isUrgent    = _timeLeft.inHours < 2;
    final isWarning   = _timeLeft.inHours < 24;
    final isConfirmed = widget.statut == 'CONFIRMED_BY_ADHERENT';

    final color = isUrgent
        ? const Color(0xFFEF4444)
        : isWarning
            ? AppColors.primary
            : isConfirmed
                ? const Color(0xFF22C55E)
                : const Color(0xFF71717A);

    final days    = _timeLeft.inDays;
    final hours   = _timeLeft.inHours % 24;
    final minutes = _timeLeft.inMinutes % 60;
    final seconds = _timeLeft.inSeconds % 60;

    final label = days > 0
        ? '${days}j ${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m'
        : '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return _buildChip(
      color: color,
      label: label,
      pulse: isUrgent || isWarning,
    );
  }

  Widget _buildChip({
    required Color color,
    required String label,
    required bool pulse,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, color: color, size: 13),
          const SizedBox(width: 5),
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Opacity(
              opacity: pulse ? _pulseAnim.value : 1.0,
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
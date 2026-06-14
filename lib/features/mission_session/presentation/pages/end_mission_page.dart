// lib/features/mission_session/presentation/pages/end_mission_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/geolocator_service.dart';
import '../../../home/presentation/providers/nav_provider.dart';
import '../../data/models/mission_session_model.dart';
import '../../domain/entities/mission_session_entity.dart';
import '../providers/mission_session_providers.dart';
import '../theme/session_theme.dart';
import '../widgets/mission_session_status_badge.dart';
import '../widgets/photo_upload_checklist.dart';

class EndMissionPage extends ConsumerStatefulWidget {
  final String reservationId;
  final MissionSessionEntity session;

  const EndMissionPage({
    super.key,
    required this.reservationId,
    required this.session,
  });

  @override
  ConsumerState<EndMissionPage> createState() => _EndMissionPageState();
}

class _EndMissionPageState extends ConsumerState<EndMissionPage> {
  late final _sessionProvider = missionSessionProvider(widget.reservationId);

  // ── Form controllers ──────────────────────────────────────────
  final _kmCtrl      = TextEditingController();
  final _commentCtrl = TextEditingController();

  // ── GPS ───────────────────────────────────────────────────────
  bool _gpsGranted = false;
  bool _gpsLoading = false;
  double? _lat;
  double? _lng;

  // ── Anti double-soumission ──────────────────────────────────
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _kmCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  // ── GPS ───────────────────────────────────────────────────────

  Future<void> _requestGps() async {
    setState(() => _gpsLoading = true);
    try {
      final hasPermission = await GeolocatorService.requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Autorisation GPS refusée.');
      }

      final position = await GeolocatorService.getCurrentPosition();
      if (position == null) {
        throw Exception('Impossible de récupérer la position.');
      }

      setState(() {
        _gpsGranted = true;
        _lat = position.latitude;
        _lng = position.longitude;
      });
    } catch (e) {
      setState(() {
        _gpsGranted = false;
        _lat = null;
        _lng = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: SessionTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  // ── Submit ────────────────────────────────────────────────────

  bool get _canSubmit {
    final photos = ref.read(postPhotosProvider);
    return _gpsGranted &&
        _lat != null &&
        photos.hasAllRequired(kPhotosRequisePostLivraison) &&
        !_isEnding;
  }

  Future<void> _endMission() async {
    if (!_canSubmit) return;

    final confirmed = await _showConfirmDialog();
    if (!confirmed) return;

    setState(() => _isEnding = true);

    final postPhotos = ref.read(postPhotosProvider);
    final km      = int.tryParse(_kmCtrl.text.replaceAll(' ', ''));
    final comment = _commentCtrl.text.trim().isEmpty
        ? null
        : _commentCtrl.text.trim();

    try {
      await ref.read(_sessionProvider.notifier).endSession(
            EndMissionSessionInputModel(
              sessionId: widget.session.id,
              latitudeFin: _lat!,
              longitudeFin: _lng!,
              kilometrageFin: km,
              commentaireFin: comment,
              photosPost: postPhotos.toUploadInputs(),
            ),
          );

      ref.read(postPhotosProvider.notifier).clear();

      if (mounted) _goToReservationsList();
    } catch (_) {
      // erreur surfacée via state.error dans build
      if (mounted) setState(() => _isEnding = false);
    }
  }

  /// Bascule vers l'onglet "Réservations" de la HomePage et y retourne
  void _goToReservationsList() {
    // index 2 = "Réservations" dans BottomNavBar
    ref.read(navIndexProvider.notifier).state = 2;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mission terminée avec succès.'),
        backgroundColor: SessionTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );

    // Remplace toute la pile de navigation par /home (onglet Réservations actif)
    context.go('/home');
  }

  // ── Helpers ───────────────────────────────────────────────────

  String _formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy à HH:mm', 'fr').format(date.toLocal());

  Duration get _elapsed =>
      DateTime.now().difference(widget.session.dateDebut);

  String get _elapsedLabel {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}min';
    return '${m}min';
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state          = ref.watch(_sessionProvider);
    final currentSession = state.session ?? widget.session;
    final isTerminee     = currentSession.isTerminee;

    final photos    = ref.watch(postPhotosProvider);
    final canSubmit = _gpsGranted &&
        _lat != null &&
        photos.hasAllRequired(kPhotosRequisePostLivraison) &&
        !state.isLoading &&
        !_isEnding;

    return Scaffold(
      backgroundColor: SessionTheme.bg,
      appBar: AppBar(
        backgroundColor: SessionTheme.surface1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          color: SessionTheme.textSecondary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          isTerminee ? 'Mission terminée' : 'Terminer la mission',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: SessionTheme.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: MissionSessionStatusBadge(statut: currentSession.statut),
          ),
        ],
      ),
      body: isTerminee
          ? _FinishedBody(session: currentSession)
          : _buildForm(state, canSubmit),
    );
  }

  Widget _buildForm(dynamic state, bool canSubmit) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Header ────────────────────────────────
        const Text(
          'Terminer la mission',
          style: TextStyle(
            color: SessionTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Confirmez votre position GPS et remplissez le formulaire de fin',
          style: TextStyle(color: SessionTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 24),

        // ── Résumé mission ────────────────────────
        _MissionSummaryCard(
          session: widget.session,
          elapsedLabel: _elapsedLabel,
          formatDate: _formatDate,
        ),
        const SizedBox(height: 20),

        // ── GPS fin ───────────────────────────────
        _GpsCardEnd(
          gpsGranted: _gpsGranted,
          gpsLoading: _gpsLoading,
          lat: _lat,
          lng: _lng,
          onRequest: _requestGps,
        ),
        const SizedBox(height: 20),

        // ── Kilométrage fin ───────────────────────
        _SectionLabel(label: 'Kilométrage fin (optionnel)'),
        const SizedBox(height: 8),
        TextField(
          controller: _kmCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: SessionTheme.textPrimary),
          decoration: _inputDeco(
            hint: 'Ex: 45 150',
            icon: Icons.speed_outlined,
          ),
        ),
        const SizedBox(height: 20),

        // ── Commentaire ───────────────────────────
        _SectionLabel(label: 'Commentaire (optionnel)'),
        const SizedBox(height: 8),
        TextField(
          controller: _commentCtrl,
          maxLines: 3,
          style: const TextStyle(color: SessionTheme.textPrimary),
          decoration: _inputDeco(
            hint: 'Remarques sur la mission, état du véhicule...',
            icon: Icons.notes_outlined,
          ),
        ),
        const SizedBox(height: 24),

        // ── Photos post-livraison — WIDGET RÉUTILISABLE ──
        PhotoUploadChecklist(
          title: 'Photos post-livraison obligatoires',
          requiredPhotos: kPhotosRequisePostLivraison,
          photosProvider: postPhotosProvider,
        ),
        const SizedBox(height: 20),

        // ── Erreur ────────────────────────────────
        if (state.error != null) ...[
          _ErrorBanner(
            error: state.error!,
            isTimeout: state.error!.contains('Connexion trop lente') ||
                state.error!.contains('Délai dépassé'),
            onRetry: _endMission, // ← réessaie directement
          ),
          const SizedBox(height: 16),
        ],

        // ── Bouton terminer ───────────────────────
        _EndButton(
          canSubmit: canSubmit,
          isLoading: state.isLoading || _isEnding,
          onTap: _endMission,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  InputDecoration _inputDeco({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: SessionTheme.textHint),
      prefixIcon: Icon(icon, color: SessionTheme.textHint, size: 20),
      filled: true,
      fillColor: SessionTheme.surface2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SessionTheme.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SessionTheme.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: SessionTheme.primary),
      ),
    );
  }

  // ── Dialogs ───────────────────────────────────────────────────

  Future<bool> _showConfirmDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SessionTheme.surface1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Terminer la mission ?',
          style: TextStyle(color: SessionTheme.textPrimary),
        ),
        content: const Text(
          'La livraison sera enregistrée définitivement. Cette action est irréversible.',
          style: TextStyle(color: SessionTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: SessionTheme.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FINISHED BODY
// ─────────────────────────────────────────────────────────────────────────────

class _FinishedBody extends StatelessWidget {
  final MissionSessionEntity session;
  const _FinishedBody({required this.session});

  String _fmt(DateTime date) {
    final l = date.toLocal();
    return '${l.day.toString().padLeft(2, '0')}/'
        '${l.month.toString().padLeft(2, '0')}/'
        '${l.year} '
        '${l.hour.toString().padLeft(2, '0')}:'
        '${l.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SessionTheme.surface1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: SessionTheme.success.withOpacity(0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: SessionTheme.success,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'Livraison enregistrée',
                style: TextStyle(
                  color: SessionTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              if (session.dateFin != null)
                _Row(label: 'Fin', value: _fmt(session.dateFin!)),
              if (session.kilometrageFin != null)
                _Row(
                  label: 'Km final',
                  value: '${session.kilometrageFin} km',
                ),
              if (session.commentaireFin != null &&
                  session.commentaireFin!.isNotEmpty)
                _Row(label: 'Commentaire', value: session.commentaireFin!),
              const SizedBox(height: 16),
              const Text(
                'Cette mission est clôturée. Toutes les actions sont verrouillées.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SessionTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: SessionTheme.textHint, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                color: SessionTheme.textPrimary,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MISSION SUMMARY CARD
// ─────────────────────────────────────────────────────────────────────────────

class _MissionSummaryCard extends StatelessWidget {
  final MissionSessionEntity session;
  final String elapsedLabel;
  final String Function(DateTime) formatDate;

  const _MissionSummaryCard({
    required this.session,
    required this.elapsedLabel,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SessionTheme.primaryDim,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SessionTheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined,
                  color: SessionTheme.primaryLight, size: 20),
              const SizedBox(width: 10),
              const Text(
                'Mission en cours',
                style: TextStyle(
                  color: SessionTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: SessionTheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  elapsedLabel,
                  style: const TextStyle(
                    color: SessionTheme.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Départ', value: formatDate(session.dateDebut)),
          if (session.kilometrageDebut != null) ...[
            const SizedBox(height: 6),
            _InfoRow(
              label: 'Km départ',
              value: '${session.kilometrageDebut} km',
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: SessionTheme.textHint, fontSize: 12)),
        Text(value,
            style: const TextStyle(
              color: SessionTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GPS CARD END
// ─────────────────────────────────────────────────────────────────────────────

class _GpsCardEnd extends StatelessWidget {
  final bool gpsGranted;
  final bool gpsLoading;
  final double? lat;
  final double? lng;
  final Future<void> Function() onRequest;

  const _GpsCardEnd({
    required this.gpsGranted,
    required this.gpsLoading,
    required this.lat,
    required this.lng,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final hasGps = lat != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasGps
            ? SessionTheme.success.withOpacity(0.08)
            : SessionTheme.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasGps
              ? SessionTheme.success.withOpacity(0.4)
              : SessionTheme.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            hasGps ? Icons.location_on : Icons.location_off,
            color: hasGps ? SessionTheme.success : SessionTheme.textHint,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasGps
                  ? 'GPS fin : ${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}'
                  : 'GPS requis pour terminer',
              style: TextStyle(
                color: hasGps ? SessionTheme.textSecondary : SessionTheme.textHint,
                fontSize: 12,
              ),
            ),
          ),
          if (!hasGps && !gpsLoading)
            TextButton(
              onPressed: onRequest,
              style: TextButton.styleFrom(
                foregroundColor: SessionTheme.primary,
                padding: EdgeInsets.zero,
                minimumSize: const Size(60, 32),
              ),
              child: const Text('Activer'),
            ),
          if (gpsLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: SessionTheme.primary),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// END BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _EndButton extends StatelessWidget {
  final bool canSubmit;
  final bool isLoading;
  final VoidCallback onTap;

  const _EndButton({
    required this.canSubmit,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canSubmit && !isLoading ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        decoration: BoxDecoration(
          color: canSubmit && !isLoading
              ? SessionTheme.success
              : SessionTheme.surface2,
          borderRadius: BorderRadius.circular(16),
          boxShadow: canSubmit && !isLoading
              ? [
                  BoxShadow(
                    color: SessionTheme.success.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          border: Border.all(
            color: canSubmit && !isLoading
                ? Colors.transparent
                : SessionTheme.border,
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      color: canSubmit ? Colors.white : SessionTheme.textHint,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Terminer la mission',
                      style: TextStyle(
                        color: canSubmit
                            ? Colors.white
                            : SessionTheme.textHint,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: const TextStyle(
          color: SessionTheme.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String error;
  final bool isTimeout;
  final VoidCallback? onRetry;

  const _ErrorBanner({
    required this.error,
    this.isTimeout = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SessionTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SessionTheme.error.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline,
                  color: SessionTheme.error, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(
                      color: SessionTheme.textSecondary, fontSize: 12),
                ),
              ),
            ],
          ),
          if (isTimeout && onRetry != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh,
                    size: 16, color: SessionTheme.error),
                label: const Text(
                  'Réessayer',
                  style: TextStyle(color: SessionTheme.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: SessionTheme.error.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
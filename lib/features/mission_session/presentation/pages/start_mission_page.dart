// lib/features/mission_session/presentation/pages/start_mission_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/geolocator_service.dart';
import '../../data/models/mission_session_model.dart';
import '../../domain/entities/mission_session_entity.dart';
import '../providers/mission_session_providers.dart';
import '../theme/session_theme.dart';
import '../widgets/photo_upload_checklist.dart';
import 'active_mission_page.dart';

class StartMissionPage extends ConsumerStatefulWidget {
  final String reservationId;
  final double latitudeArrivee;
  final double longitudeArrivee;
  final String villeArrivee;

  const StartMissionPage({
    super.key,
    required this.reservationId,
    this.latitudeArrivee = 36.8189,
    this.longitudeArrivee = 10.1658,
    this.villeArrivee = 'Destination',
  });

  @override
  ConsumerState<StartMissionPage> createState() => _StartMissionPageState();
}

class _StartMissionPageState extends ConsumerState<StartMissionPage> {
  late final _sessionProvider = missionSessionProvider(widget.reservationId);

  // ── Form state ────────────────────────────────────────────────
  bool _consentAccepted = false;
  final _kmCtrl = TextEditingController();

  // ── GPS state ─────────────────────────────────────────────────
  bool _gpsGranted = false;
  bool _gpsLoading = false;
  double? _lat;
  double? _lng;
  String? _address;
  bool _addressLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref
          .read(_sessionProvider.notifier)
          .loadSession(widget.reservationId);
      final session = ref.read(_sessionProvider).session;
      if (mounted && session != null && session.isEnCours) {
        _goToActive(session);
      }
    });
  }

  @override
  void dispose() {
    _kmCtrl.dispose();
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

      // Obtenir l'adresse en arrière-plan
      setState(() {
        _gpsGranted = true;
        _lat = position.latitude;
        _lng = position.longitude;
        _addressLoading = true;
      });

      // Géocodage
      final address = await GeolocatorService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _address = address;
          _addressLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _gpsGranted = false;
        _lat = null;
        _lng = null;
        _address = null;
        _addressLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: SessionTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  // ── Submit ────────────────────────────────────────────────────

  bool get _canSubmit {
    final photos = ref.read(prePhotosProvider);
    return _consentAccepted &&
        _gpsGranted &&
        _lat != null &&
        photos.hasAllRequired(kPhotosRequisePreDepart);
  }

  Future<void> _startMission() async {
    if (!_canSubmit) return;

    final prePhotos = ref.read(prePhotosProvider);
    final km = int.tryParse(_kmCtrl.text.replaceAll(' ', ''));

    try {
      await ref
          .read(_sessionProvider.notifier)
          .startSession(
            StartMissionSessionInputModel(
              reservationId: widget.reservationId,
              consentAccepted: true,
              latitudeDebut: _lat!,
              longitudeDebut: _lng!,
              kilometrageDebut: km,
              photosPre: prePhotos.toUploadInputs(),
            ),
          );
      ref.read(prePhotosProvider.notifier).clear();

      if (!mounted) return;
      final session = ref.read(_sessionProvider).session;
      if (session == null) return;

      _goToActive(session);
    } catch (_) {
      // error surfaced via state.error in build
    }
  }

  void _goToActive(MissionSessionEntity session) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ActiveMissionPage(
          reservationId: widget.reservationId,
          session: session,
          latitudeArrivee: widget.latitudeArrivee,
          longitudeArrivee: widget.longitudeArrivee,
          villeArrivee: widget.villeArrivee,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_sessionProvider);
    final photos = ref.watch(prePhotosProvider);

    final canSubmit =
        _consentAccepted &&
        _gpsGranted &&
        _lat != null &&
        photos.hasAllRequired(kPhotosRequisePreDepart) &&
        !state.isLoading;

    if (state.isLoading && state.session == null) {
      return Scaffold(
        backgroundColor: SessionTheme.bg,
        body: const Center(
          child: CircularProgressIndicator(color: SessionTheme.primary),
        ),
      );
    }

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
        title: const Text(
          'Démarrer la mission',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: SessionTheme.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header ────────────────────────────────
          const Text(
            'Démarrer la mission',
            style: TextStyle(
              color: SessionTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Vérifiez votre position GPS et acceptez les conditions',
            style: TextStyle(color: SessionTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 28),

          // ── GPS ───────────────────────────────────
          _GpsCard(
            gpsGranted: _gpsGranted,
            gpsLoading: _gpsLoading,
            lat: _lat,
            lng: _lng,
            address: _address,
            addressLoading: _addressLoading,
            onRequest: _requestGps,
          ),
          const SizedBox(height: 20),

          // ── Kilométrage ───────────────────────────
          _SectionLabel(label: 'Kilométrage départ (optionnel)'),
          const SizedBox(height: 8),
          TextField(
            controller: _kmCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: SessionTheme.textPrimary),
            decoration: _inputDeco(
              hint: 'Ex: 45 000',
              icon: Icons.speed_outlined,
            ),
          ),
          const SizedBox(height: 24),

          // ── Consentement ──────────────────────────
          _ConsentClause(
            value: _consentAccepted,
            onChanged: (v) => setState(() => _consentAccepted = v),
          ),
          const SizedBox(height: 24),

          // ── Photos pré-départ — WIDGET RÉUTILISABLE ──
          PhotoUploadChecklist(
            title: 'Photos pré-départ obligatoires',
            requiredPhotos: kPhotosRequisePreDepart,
            photosProvider: prePhotosProvider,
          ),
          const SizedBox(height: 20),

          // ── Erreur ────────────────────────────────
        // ── Erreur ────────────────────────────────
if (state.error != null) ...[
  _ErrorBanner(
    error: state.error!,
    isTimeout: state.error!.contains('Connexion trop lente') ||
        state.error!.contains('Délai dépassé'),
    onRetry: _startMission,  // ← réessaie directement
  ),
  const SizedBox(height: 16),
],

          // ── Bouton démarrer ───────────────────────
          _StartButton(
            canSubmit: canSubmit,
            isLoading: state.isLoading,
            onTap: _startMission,
          ),
          const SizedBox(height: 40),
        ],
      ),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// GPS CARD
// ─────────────────────────────────────────────────────────────────────────────

class _GpsCard extends StatelessWidget {
  final bool gpsGranted;
  final bool gpsLoading;
  final double? lat;
  final double? lng;
  final String? address;
  final bool addressLoading;
  final Future<void> Function() onRequest;

  const _GpsCard({
    required this.gpsGranted,
    required this.gpsLoading,
    required this.lat,
    required this.lng,
    required this.address,
    required this.addressLoading,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final hasGps = lat != null && lng != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasGps
            ? SessionTheme.success.withOpacity(0.08)
            : SessionTheme.surface2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasGps
              ? SessionTheme.success.withOpacity(0.4)
              : SessionTheme.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasGps
                  ? SessionTheme.success.withOpacity(0.15)
                  : SessionTheme.surface1,
              shape: BoxShape.circle,
            ),
            child: gpsLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: SessionTheme.primary,
                    ),
                  )
                : Icon(
                    hasGps ? Icons.gps_fixed : Icons.gps_not_fixed,
                    color: hasGps
                        ? SessionTheme.success
                        : SessionTheme.textHint,
                    size: 22,
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hasGps
                          ? 'Position GPS obtenue ✓'
                          : 'Position GPS requise',
                      style: TextStyle(
                        color: hasGps
                            ? SessionTheme.success
                            : SessionTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (hasGps && addressLoading)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: SessionTheme.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  hasGps
                      ? (address ?? 'Récupération de l\'adresse...')
                      : 'Appuyez pour activer',
                  style: const TextStyle(
                    color: SessionTheme.textHint,
                    fontSize: 11,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasGps && (lat != null && lng != null))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: SessionTheme.textHint,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (!hasGps && !gpsLoading)
            TextButton(
              onPressed: onRequest,
              style: TextButton.styleFrom(
                foregroundColor: SessionTheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              child: const Text(
                'Activer',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONSENT CLAUSE
// ─────────────────────────────────────────────────────────────────────────────

class _ConsentClause extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ConsentClause({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value
              ? SessionTheme.primary.withOpacity(0.08)
              : SessionTheme.surface2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value
                ? SessionTheme.primary.withOpacity(0.5)
                : SessionTheme.border,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: value ? SessionTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? SessionTheme.primary : SessionTheme.border,
                  width: 1.5,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "J'accepte les conditions de mission",
                    style: TextStyle(
                      color: SessionTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Je confirme avoir vérifié le véhicule, être apte à conduire '
                    'et accepter le suivi GPS en temps réel durant la mission.',
                    style: TextStyle(
                      color: SessionTheme.textSecondary,
                      fontSize: 12,
                      height: 1.4,
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

// ─────────────────────────────────────────────────────────────────────────────
// START BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _StartButton extends StatelessWidget {
  final bool canSubmit;
  final bool isLoading;
  final VoidCallback onTap;

  const _StartButton({
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
          gradient: canSubmit && !isLoading
              ? SessionTheme.orangeGradient
              : null,
          color: canSubmit && !isLoading ? null : SessionTheme.surface2,
          borderRadius: BorderRadius.circular(16),
          boxShadow: canSubmit && !isLoading ? SessionTheme.orangeGlow : null,
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
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.rocket_launch,
                      color: canSubmit ? Colors.white : SessionTheme.textHint,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Démarrer la mission',
                      style: TextStyle(
                        color: canSubmit ? Colors.white : SessionTheme.textHint,
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
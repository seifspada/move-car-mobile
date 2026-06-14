// lib/features/mission_session/presentation/widgets/start_mission_form.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/mission_session_entity.dart';
import '../providers/mission_session_providers.dart';
import '../theme/session_theme.dart';
import '../utils/camera_capture.dart';

class StartMissionForm extends ConsumerStatefulWidget {
  final bool gpsGranted;
  final bool gpsLoading;
  final double? lat;
  final double? lng;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRequestGps;
  final Future<void> Function({int? kilometrageDebut}) onStart;

  const StartMissionForm({
    super.key,
    required this.gpsGranted,
    required this.gpsLoading,
    required this.lat,
    required this.lng,
    required this.isLoading,
    required this.onRequestGps,
    required this.onStart,
    this.error,
  });

  @override
  ConsumerState<StartMissionForm> createState() => _StartMissionFormState();
}

class _StartMissionFormState extends ConsumerState<StartMissionForm> {
  bool _consentAccepted = false;
  final _kmCtrl = TextEditingController();
  String? _photoError;

  @override
  void dispose() {
    _kmCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _consentAccepted &&
      widget.gpsGranted &&
      widget.lat != null &&
      ref.watch(prePhotosProvider).hasAllRequired(kPhotosRequisePreDepart) &&
      !widget.isLoading;

  Future<void> _capturePhoto(TypeMediaSession type) async {
    setState(() => _photoError = null);
    try {
      final file = await captureInspectionPhoto();
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final base64Data = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      ref.read(prePhotosProvider.notifier).addPhoto(type, base64Data);
    } catch (e) {
      setState(() => _photoError = 'Impossible de prendre la photo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(prePhotosProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Titre ─────────────────────────────────
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
          gpsGranted: widget.gpsGranted,
          gpsLoading: widget.gpsLoading,
          lat: widget.lat,
          lng: widget.lng,
          onRequest: widget.onRequestGps,
        ),
        const SizedBox(height: 20),

        // ── Kilométrage optionnel ─────────────────
        _SectionLabel(label: 'Kilométrage départ (optionnel)'),
        const SizedBox(height: 8),
        TextField(
          controller: _kmCtrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: SessionTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Ex: 45 000',
            hintStyle: const TextStyle(color: SessionTheme.textHint),
            prefixIcon: const Icon(
              Icons.speed_outlined,
              color: SessionTheme.textHint,
              size: 20,
            ),
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
          ),
        ),
        const SizedBox(height: 24),

        // ── Clause de consentement ────────────────
        _ConsentClause(
          value: _consentAccepted,
          onChanged: (v) => setState(() => _consentAccepted = v),
        ),
        const SizedBox(height: 20),

        _PhotoChecklist(
          title: 'Photos pre-depart obligatoires',
          requiredPhotos: kPhotosRequisePreDepart,
          photos: photos,
          onCapturePhoto: _capturePhoto,
          onRemovePhoto: (type) =>
              ref.read(prePhotosProvider.notifier).removePhoto(type),
        ),
        const SizedBox(height: 12),

        // ── Erreur ────────────────────────────────
        if (_photoError != null) ...[
          _ErrorBanner(error: _photoError!),
          const SizedBox(height: 16),
        ],
      if (widget.error != null) ...[
  _ErrorBanner(
    error: widget.error!,
    isTimeout: widget.error!.contains('Connexion trop lente') ||
        widget.error!.contains('Délai dépassé'),
    onRetry: () {
      final km = int.tryParse(_kmCtrl.text.replaceAll(' ', ''));
      widget.onStart(kilometrageDebut: km);
    },
  ),
  const SizedBox(height: 16),
],

        // ── Bouton démarrer ───────────────────────
        const SizedBox(height: 8),
        _StartButton(
          canSubmit: _canSubmit,
          isLoading: widget.isLoading,
          onTap: () {
            final km = int.tryParse(_kmCtrl.text.replaceAll(' ', ''));
            widget.onStart(kilometrageDebut: km);
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ── GPS Card ──────────────────────────────────────────────────

class _GpsCard extends StatelessWidget {
  final bool gpsGranted;
  final bool gpsLoading;
  final double? lat;
  final double? lng;
  final Future<void> Function() onRequest;

  const _GpsCard({
    required this.gpsGranted,
    required this.gpsLoading,
    required this.lat,
    required this.lng,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    final hasGps = lat != null && lng != null;

    return Container(
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
                Text(
                  hasGps ? 'Position GPS obtenue ✓' : 'Position GPS requise',
                  style: TextStyle(
                    color: hasGps
                        ? SessionTheme.success
                        : SessionTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasGps
                      ? '${lat!.toStringAsFixed(5)}, ${lng!.toStringAsFixed(5)}'
                      : 'Appuyez pour activer',
                  style: const TextStyle(
                    color: SessionTheme.textHint,
                    fontSize: 11,
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

class _PhotoChecklist extends StatelessWidget {
  final String title;
  final List<TypeMediaSession> requiredPhotos;
  final LocalPhotoState photos;
  final ValueChanged<TypeMediaSession> onCapturePhoto;
  final ValueChanged<TypeMediaSession> onRemovePhoto;

  const _PhotoChecklist({
    required this.title,
    required this.requiredPhotos,
    required this.photos,
    required this.onCapturePhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final completed = requiredPhotos.where(photos.hasPhoto).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SessionTheme.surface1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SessionTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.photo_camera_outlined,
                  color: SessionTheme.primaryLight, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: SessionTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '$completed/${requiredPhotos.length}',
                style: const TextStyle(
                  color: SessionTheme.primaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final type in requiredPhotos)
            _PhotoRow(
              type: type,
              taken: photos.hasPhoto(type),
              onCapture: () => onCapturePhoto(type),
              onRemove: () => onRemovePhoto(type),
            ),
        ],
      ),
    );
  }
}

class _PhotoRow extends StatelessWidget {
  final TypeMediaSession type;
  final bool taken;
  final VoidCallback onCapture;
  final VoidCallback onRemove;

  const _PhotoRow({
    required this.type,
    required this.taken,
    required this.onCapture,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: SessionTheme.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: taken
              ? SessionTheme.success.withOpacity(0.45)
              : SessionTheme.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            taken ? Icons.check_circle : Icons.radio_button_unchecked,
            color: taken ? SessionTheme.success : SessionTheme.textHint,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: const TextStyle(
                    color: SessionTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  taken ? 'Prise, validee localement' : 'Manquante',
                  style: TextStyle(
                    color: taken ? SessionTheme.success : SessionTheme.warning,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: taken ? 'Reprendre' : 'Prendre',
            onPressed: onCapture,
            icon: Icon(taken ? Icons.refresh : Icons.camera_alt_outlined),
            color: SessionTheme.primaryLight,
          ),
          if (taken)
            IconButton(
              tooltip: 'Supprimer',
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              color: SessionTheme.error,
            ),
        ],
      ),
    );
  }
}

// ── Consent clause ────────────────────────────────────────────

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
            // Checkbox
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

// ── Start button ──────────────────────────────────────────────

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
                      color: canSubmit
                          ? Colors.white
                          : SessionTheme.textHint,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Démarrer la mission',
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

// ── Helpers ───────────────────────────────────────────────────

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
    this.isTimeout = false,  // ← valeur par défaut = pas obligatoire
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
          // Bouton Réessayer uniquement si timeout
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
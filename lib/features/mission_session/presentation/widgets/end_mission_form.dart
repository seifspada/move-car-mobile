// lib/features/mission_session/presentation/widgets/end_mission_form.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/mission_session_entity.dart';
import '../providers/mission_session_providers.dart';
import '../theme/session_theme.dart';
import '../utils/camera_capture.dart';

class EndMissionForm extends ConsumerStatefulWidget {
  final MissionSessionEntity session;
  final bool gpsGranted;
  final bool gpsLoading;
  final double? lat;
  final double? lng;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRequestGps;
  final Future<void> Function({
    int? kilometrageFin,
    String? commentaireFin,
  }) onEnd;

  const EndMissionForm({
    super.key,
    required this.session,
    required this.gpsGranted,
    required this.gpsLoading,
    required this.lat,
    required this.lng,
    required this.isLoading,
    required this.onRequestGps,
    required this.onEnd,
    this.error,
  });

  @override
  ConsumerState<EndMissionForm> createState() => _EndMissionFormState();
}

class _EndMissionFormState extends ConsumerState<EndMissionForm> {
  final _kmCtrl      = TextEditingController();
  final _commentCtrl = TextEditingController();
  String? _photoError;

  @override
  void dispose() {
    _kmCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      widget.lat != null &&
      widget.gpsGranted &&
      ref.watch(postPhotosProvider).hasAllRequired(kPhotosRequisePostLivraison) &&
      !widget.isLoading;

  Future<void> _capturePhoto(TypeMediaSession type) async {
    setState(() => _photoError = null);
    try {
      final file = await captureInspectionPhoto();
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final base64Data = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      ref.read(postPhotosProvider.notifier).addPhoto(type, base64Data);
    } catch (e) {
      setState(() => _photoError = 'Impossible de prendre la photo: $e');
    }
  }

  String _formatDate(DateTime d) =>
      DateFormat('dd/MM/yyyy à HH:mm', 'fr').format(d.toLocal());

  Duration get _elapsed =>
      DateTime.now().difference(widget.session.dateDebut);

  String get _elapsedLabel {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}min';
    return '$m min';
  }

  @override
  Widget build(BuildContext context) {
    final photos = ref.watch(postPhotosProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Titre ─────────────────────────────────
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

        // ── GPS ───────────────────────────────────
        _GpsCardEnd(
          gpsGranted: widget.gpsGranted,
          gpsLoading: widget.gpsLoading,
          lat: widget.lat,
          lng: widget.lng,
          onRequest: widget.onRequestGps,
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
        const SizedBox(height: 20),

        _PhotoChecklist(
          title: 'Photos post-livraison obligatoires',
          requiredPhotos: kPhotosRequisePostLivraison,
          photos: photos,
          onCapturePhoto: _capturePhoto,
          onRemovePhoto: (type) =>
              ref.read(postPhotosProvider.notifier).removePhoto(type),
        ),
        const SizedBox(height: 20),

        // ── Erreur ────────────────────────────────
        if (_photoError != null) ...[
          _ErrorBanner(error: _photoError!),
          const SizedBox(height: 16),
        ],
        if (widget.error != null) ...[
          _ErrorBanner(error: widget.error!),
          const SizedBox(height: 16),
        ],

        // ── Bouton terminer ───────────────────────
        _EndButton(
          canSubmit: _canSubmit,
          isLoading: widget.isLoading,
          onTap: () {
            final km = int.tryParse(_kmCtrl.text.replaceAll(' ', ''));
            final comment = _commentCtrl.text.trim().isEmpty
                ? null
                : _commentCtrl.text.trim();
            widget.onEnd(kilometrageFin: km, commentaireFin: comment);
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
  }) {
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

// ── Mission summary ────────────────────────────────────────────

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
              const Icon(
                Icons.timer_outlined,
                color: SessionTheme.primaryLight,
                size: 20,
              ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
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
          _InfoRow(
            label: 'Départ',
            value: formatDate(session.dateDebut),
          ),
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
        Text(
          label,
          style: const TextStyle(
            color: SessionTheme.textHint,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: SessionTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── GPS card end ───────────────────────────────────────────────

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
    return Container(
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
                  ? 'GPS : ${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}'
                  : 'GPS requis pour terminer',
              style: TextStyle(
                color: hasGps
                    ? SessionTheme.textSecondary
                    : SessionTheme.textHint,
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
                strokeWidth: 2,
                color: SessionTheme.primary,
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

// ── End button ─────────────────────────────────────────────────

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
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
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
  const _ErrorBanner({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SessionTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SessionTheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: SessionTheme.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: SessionTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

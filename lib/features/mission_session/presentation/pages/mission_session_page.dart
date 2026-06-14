// lib/features/mission_session/presentation/pages/mission_session_page.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../data/models/mission_session_model.dart';
import '../../domain/entities/mission_session_entity.dart';
import '../providers/mission_session_providers.dart';
import '../theme/session_theme.dart';
import '../utils/camera_capture.dart';

class MissionSessionPage extends ConsumerStatefulWidget {
  final String reservationId;

  const MissionSessionPage({super.key, required this.reservationId});

  @override
  ConsumerState<MissionSessionPage> createState() => _MissionSessionPageState();
}

class _MissionSessionPageState extends ConsumerState<MissionSessionPage> {
  late final _sessionProvider = missionSessionProvider(widget.reservationId);
  final _startKmController = TextEditingController();
  final _endKmController = TextEditingController();
  final _commentController = TextEditingController();

  bool _consentAccepted = false;
  bool _gpsLoading = false;
  Position? _position;
  String? _localError;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(_sessionProvider.notifier).loadSession(widget.reservationId);
    });
  }

  @override
  void dispose() {
    _startKmController.dispose();
    _endKmController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _requestGps() async {
    setState(() {
      _gpsLoading = true;
      _localError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Activez la localisation GPS pour continuer.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Autorisation GPS refusée.');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _position = position);
    } catch (e) {
      setState(() => _localError = _cleanError(e));
    } finally {
      if (mounted) setState(() => _gpsLoading = false);
    }
  }

  Future<void> _capturePhoto(TypeMediaSession type, bool isPost) async {
    setState(() => _localError = null);
    try {
      final file = await captureInspectionPhoto();
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final base64Data = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      final provider = isPost ? postPhotosProvider : prePhotosProvider;
      ref.read(provider.notifier).addPhoto(type, base64Data);
    } catch (e) {
      setState(() => _localError = 'Impossible de prendre la photo: $e');
    }
  }

  Future<void> _startMission() async {
    final prePhotos = ref.read(prePhotosProvider);
    if (!_consentAccepted || _position == null ||
        !prePhotos.hasAllRequired(kPhotosRequisePreDepart)) {
      setState(() {
        _localError =
            'Consentement, GPS et toutes les photos pré-départ sont obligatoires.';
      });
      return;
    }

    final confirmed = await _confirm(
      title: 'Démarrer la mission ?',
      message: 'La session sera créée avec votre position GPS et les photos.',
    );
    if (!confirmed) return;

    try {
      await ref.read(_sessionProvider.notifier).startSession(
            StartMissionSessionInputModel(
              reservationId: widget.reservationId,
              consentAccepted: _consentAccepted,
              latitudeDebut: _position!.latitude,
              longitudeDebut: _position!.longitude,
              kilometrageDebut: _parseKm(_startKmController.text),
              photosPre: prePhotos.toUploadInputs(),
            ),
          );
      ref.read(prePhotosProvider.notifier).clear();
      _showSnack('Mission démarrée.', SessionTheme.success);
    } catch (e) {
      setState(() => _localError = _cleanError(e));
    }
  }

  Future<void> _endMission(MissionSessionEntity session) async {
    final postPhotos = ref.read(postPhotosProvider);
    if (_position == null ||
        !postPhotos.hasAllRequired(kPhotosRequisePostLivraison)) {
      setState(() {
        _localError =
            'GPS final et toutes les photos post-livraison sont obligatoires.';
      });
      return;
    }

    final confirmed = await _confirm(
      title: 'Terminer la mission ?',
      message: 'La livraison sera enregistrée définitivement.',
    );
    if (!confirmed) return;

    try {
      await ref.read(_sessionProvider.notifier).endSession(
            EndMissionSessionInputModel(
              sessionId: session.id,
              latitudeFin: _position!.latitude,
              longitudeFin: _position!.longitude,
              kilometrageFin: _parseKm(_endKmController.text),
              commentaireFin: _commentController.text.trim().isEmpty
                  ? null
                  : _commentController.text.trim(),
              photosPost: postPhotos.toUploadInputs(),
            ),
          );
      ref.read(postPhotosProvider.notifier).clear();
      if (mounted) _showSuccessDialog();
    } catch (e) {
      setState(() => _localError = _cleanError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_sessionProvider);
    final session = state.session;
    final prePhotos = ref.watch(prePhotosProvider);
    final postPhotos = ref.watch(postPhotosProvider);
    final error = _localError ?? state.error;

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
          session == null
              ? 'Démarrer la mission'
              : session.isTerminee
                  ? 'Mission terminée'
                  : 'Mission en cours',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (session != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _StatusBadge(statut: session.statut),
            ),
        ],
      ),
      body: state.isLoading && session == null
          ? const _LoadingView()
          : RefreshIndicator(
              color: SessionTheme.primary,
              backgroundColor: SessionTheme.surface1,
              onRefresh: () => ref
                  .read(_sessionProvider.notifier)
                  .loadSession(widget.reservationId),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SessionHeader(session: session, reservationId: widget.reservationId),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    _ErrorBanner(message: error),
                  ],
                  const SizedBox(height: 16),
                  if (session == null)
                    _StartPanel(
                      consentAccepted: _consentAccepted,
                      position: _position,
                      gpsLoading: _gpsLoading,
                      kmController: _startKmController,
                      photos: prePhotos,
                      isLoading: state.isLoading,
                      onConsentChanged: (value) =>
                          setState(() => _consentAccepted = value),
                      onRequestGps: _requestGps,
                      onCapturePhoto: (type) => _capturePhoto(type, false),
                      onRemovePhoto: (type) =>
                          ref.read(prePhotosProvider.notifier).removePhoto(type),
                      onStart: _startMission,
                    )
                  else if (session.isTerminee)
                    _FinishedView(session: session)
                  else
                    _InProgressPanel(
                      session: session,
                      position: _position,
                      gpsLoading: _gpsLoading,
                      kmController: _endKmController,
                      commentController: _commentController,
                      photos: postPhotos,
                      isLoading: state.isLoading,
                      onRequestGps: _requestGps,
                      onCapturePhoto: (type) => _capturePhoto(type, true),
                      onRemovePhoto: (type) =>
                          ref.read(postPhotosProvider.notifier).removePhoto(type),
                      onEnd: () => _endMission(session),
                    ),
                ],
              ),
            ),
    );
  }

  Future<bool> _confirm({required String title, required String message}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SessionTheme.surface1,
        title: Text(title, style: const TextStyle(color: SessionTheme.textPrimary)),
        content: Text(message, style: const TextStyle(color: SessionTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: SessionTheme.primary),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: SessionTheme.surface1,
        icon: const Icon(Icons.check_circle_outline,
            color: SessionTheme.success, size: 42),
        title: const Text(
          'Mission terminée',
          textAlign: TextAlign.center,
          style: TextStyle(color: SessionTheme.textPrimary),
        ),
        content: const Text(
          'La preuve de livraison et les photos finales ont été enregistrées.',
          textAlign: TextAlign.center,
          style: TextStyle(color: SessionTheme.textSecondary),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).maybePop(true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: SessionTheme.primary),
            child: const Text('Retour'),
          ),
        ],
      ),
    );
  }

  int? _parseKm(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : int.tryParse(trimmed);
  }

  String _cleanError(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }
}

class _StartPanel extends StatelessWidget {
  final bool consentAccepted;
  final Position? position;
  final bool gpsLoading;
  final TextEditingController kmController;
  final LocalPhotoState photos;
  final bool isLoading;
  final ValueChanged<bool> onConsentChanged;
  final VoidCallback onRequestGps;
  final ValueChanged<TypeMediaSession> onCapturePhoto;
  final ValueChanged<TypeMediaSession> onRemovePhoto;
  final VoidCallback onStart;

  const _StartPanel({
    required this.consentAccepted,
    required this.position,
    required this.gpsLoading,
    required this.kmController,
    required this.photos,
    required this.isLoading,
    required this.onConsentChanged,
    required this.onRequestGps,
    required this.onCapturePhoto,
    required this.onRemovePhoto,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final canStart = consentAccepted &&
        position != null &&
        photos.hasAllRequired(kPhotosRequisePreDepart) &&
        !isLoading;

    return Column(
      children: [
        _SectionCard(
          title: 'Consentement',
          icon: Icons.verified_user_outlined,
          child: CheckboxListTile(
            value: consentAccepted,
            onChanged: (value) => onConsentChanged(value ?? false),
            activeColor: SessionTheme.primary,
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'J’accepte les conditions de mission',
              style: TextStyle(color: SessionTheme.textPrimary),
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        const SizedBox(height: 12),
        _GpsCard(position: position, loading: gpsLoading, onRequest: onRequestGps),
        const SizedBox(height: 12),
        _KmField(controller: kmController, label: 'Kilométrage de départ (optionnel)'),
        const SizedBox(height: 12),
        _PhotoChecklist(
          title: 'Photos pré-départ obligatoires',
          requiredPhotos: kPhotosRequisePreDepart,
          photos: photos,
          onCapturePhoto: onCapturePhoto,
          onRemovePhoto: onRemovePhoto,
        ),
        const SizedBox(height: 18),
        _PrimaryActionButton(
          label: 'Démarrer la mission',
          icon: Icons.play_arrow_rounded,
          enabled: canStart,
          loading: isLoading,
          onPressed: onStart,
        ),
      ],
    );
  }
}

class _InProgressPanel extends StatelessWidget {
  final MissionSessionEntity session;
  final Position? position;
  final bool gpsLoading;
  final TextEditingController kmController;
  final TextEditingController commentController;
  final LocalPhotoState photos;
  final bool isLoading;
  final VoidCallback onRequestGps;
  final ValueChanged<TypeMediaSession> onCapturePhoto;
  final ValueChanged<TypeMediaSession> onRemovePhoto;
  final VoidCallback onEnd;

  const _InProgressPanel({
    required this.session,
    required this.position,
    required this.gpsLoading,
    required this.kmController,
    required this.commentController,
    required this.photos,
    required this.isLoading,
    required this.onRequestGps,
    required this.onCapturePhoto,
    required this.onRemovePhoto,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final canEnd = position != null &&
        photos.hasAllRequired(kPhotosRequisePostLivraison) &&
        !isLoading;

    return Column(
      children: [
        _SectionCard(
          title: 'Session en cours',
          icon: Icons.route_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoLine(label: 'Démarrage', value: _fmt(session.dateDebut)),
              _InfoLine(
                label: 'GPS départ',
                value:
                    '${session.latitudeDebut.toStringAsFixed(5)}, ${session.longitudeDebut.toStringAsFixed(5)}',
              ),
              const SizedBox(height: 8),
              const Text(
                'Structure prête pour le suivi GPS futur.',
                style: TextStyle(color: SessionTheme.textHint, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _GpsCard(position: position, loading: gpsLoading, onRequest: onRequestGps),
        const SizedBox(height: 12),
        _KmField(controller: kmController, label: 'Kilométrage final (optionnel)'),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Commentaire final',
          icon: Icons.notes_outlined,
          child: TextField(
            controller: commentController,
            maxLines: 3,
            style: const TextStyle(color: SessionTheme.textPrimary),
            decoration: _inputDecoration('Commentaire optionnel'),
          ),
        ),
        const SizedBox(height: 12),
        _PhotoChecklist(
          title: 'Photos post-livraison obligatoires',
          requiredPhotos: kPhotosRequisePostLivraison,
          photos: photos,
          onCapturePhoto: onCapturePhoto,
          onRemovePhoto: onRemovePhoto,
        ),
        const SizedBox(height: 18),
        _PrimaryActionButton(
          label: 'Terminer la mission',
          icon: Icons.flag_rounded,
          enabled: canEnd,
          loading: isLoading,
          onPressed: onEnd,
        ),
      ],
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

    return _SectionCard(
      title: title,
      icon: Icons.photo_camera_outlined,
      trailing: Text(
        '$completed/${requiredPhotos.length}',
        style: const TextStyle(
          color: SessionTheme.primaryLight,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Column(
        children: [
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
        borderRadius: BorderRadius.circular(8),
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
                  taken ? 'Prise, validée localement' : 'Manquante',
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

class _GpsCard extends StatelessWidget {
  final Position? position;
  final bool loading;
  final VoidCallback onRequest;

  const _GpsCard({
    required this.position,
    required this.loading,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Position GPS',
      icon: Icons.my_location_outlined,
      child: Row(
        children: [
          Expanded(
            child: Text(
              position == null
                  ? 'Position obligatoire non récupérée'
                  : '${position!.latitude.toStringAsFixed(5)}, ${position!.longitude.toStringAsFixed(5)}',
              style: TextStyle(
                color: position == null
                    ? SessionTheme.textSecondary
                    : SessionTheme.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: loading ? null : onRequest,
            icon: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.gps_fixed_rounded),
            label: Text(position == null ? 'Récupérer' : 'Actualiser'),
          ),
        ],
      ),
    );
  }
}

class _SessionHeader extends StatelessWidget {
  final MissionSessionEntity? session;
  final String reservationId;

  const _SessionHeader({required this.session, required this.reservationId});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Mission',
      icon: Icons.directions_car_filled_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine(label: 'Réservation', value: reservationId),
          if (session != null) ...[
            _InfoLine(label: 'Mission', value: session!.missionId),
            _InfoLine(label: 'Créée le', value: _fmt(session!.dateCreation)),
          ] else
            const Text(
              'Aucune session active. Complétez les prérequis pour démarrer.',
              style: TextStyle(color: SessionTheme.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _KmField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _KmField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: label,
      icon: Icons.speed_outlined,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: SessionTheme.textPrimary),
        decoration: _inputDecoration('Ex: 45210'),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SessionTheme.surface1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SessionTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: SessionTheme.primaryLight),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: SessionTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final bool loading;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: SessionTheme.primary,
          disabledBackgroundColor: SessionTheme.surface2,
          foregroundColor: Colors.white,
          disabledForegroundColor: SessionTheme.textHint,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final StatutSession statut;

  const _StatusBadge({required this.statut});

  @override
  Widget build(BuildContext context) {
    final isActive = statut == StatutSession.EN_COURS;
    final color = isActive ? SessionTheme.primary : SessionTheme.success;
    final label = isActive ? 'EN COURS' : 'TERMINÉE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SessionTheme.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SessionTheme.error.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: SessionTheme.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: SessionTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: SessionTheme.primary),
    );
  }
}

class _FinishedView extends StatelessWidget {
  final MissionSessionEntity session;

  const _FinishedView({required this.session});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Livraison enregistrée',
      icon: Icons.check_circle_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoLine(label: 'Fin', value: session.dateFin == null ? '-' : _fmt(session.dateFin!)),
          if (session.kilometrageFin != null)
            _InfoLine(label: 'Kilométrage final', value: '${session.kilometrageFin} km'),
          if (session.commentaireFin != null && session.commentaireFin!.isNotEmpty)
            _InfoLine(label: 'Commentaire', value: session.commentaireFin!),
          const SizedBox(height: 8),
          const Text(
            'Cette mission est terminée. Les actions de démarrage et de fin sont verrouillées.',
            style: TextStyle(color: SessionTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(color: SessionTheme.textHint, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: SessionTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InputDecoration _inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: SessionTheme.textHint),
    filled: true,
    fillColor: SessionTheme.surface2,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: SessionTheme.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: SessionTheme.primary),
    ),
  );
}

String _fmt(DateTime date) {
  final local = date.toLocal();
  return '${local.day.toString().padLeft(2, '0')}/'
      '${local.month.toString().padLeft(2, '0')}/'
      '${local.year} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

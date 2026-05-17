// lib/features/pretrip_inspection/presentation/widgets/media_upload_card.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/pretrip_entity.dart';
import '../theme/pretrip_theme.dart';
import '../utils/camera_capture.dart';

class MediaUploadCard extends StatefulWidget {
  final TypeMediaInspection type;
  final MediaUploadState uploadState;
  final Future<bool> Function(TypeMediaInspection type, XFile file) onUpload;

  const MediaUploadCard({
    super.key,
    required this.type,
    required this.uploadState,
    required this.onUpload,
  });

  @override
  State<MediaUploadCard> createState() => _MediaUploadCardState();
}

class _MediaUploadCardState extends State<MediaUploadCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..value = 1.0;
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    await _scaleCtrl.animateTo(
      0.97,
      duration: const Duration(milliseconds: 80),
    );
    await _scaleCtrl.animateTo(
      1.0,
      duration: const Duration(milliseconds: 120),
    );

    final picked = await captureInspectionPhoto();
    if (picked == null) return;

    await widget.onUpload(widget.type, picked);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.uploadState;

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTap: state.isUploading ? null : () => _pickAndUpload(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 130,
          // ✅ Couleur dans BoxDecoration, pas de conflit
          decoration: BoxDecoration(
            color: _bgColor(state),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _borderColor(state),
              width: state.isUploaded ? 1.5 : 1,
            ),
            boxShadow: state.isUploaded
                ? [
                    BoxShadow(
                      color: PreTripTheme.success.withOpacity(0.15),
                      blurRadius: 12,
                    ),
                  ]
                : state.error != null
                ? [
                    BoxShadow(
                      color: PreTripTheme.error.withOpacity(0.15),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (state.localBytes != null && state.error == null)
                  Opacity(
                    opacity: state.isUploaded ? 1.0 : 0.45,
                    child: Image.memory(state.localBytes!, fit: BoxFit.cover),
                  ),
                if (state.isUploaded)
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0x99000000)],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                _buildStateOverlay(state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStateOverlay(MediaUploadState state) {
    // UPLOADING
    if (state.isUploading) {
      return Container(
        // ✅ Uniquement color, pas de decoration
        color: Colors.black.withOpacity(0.75),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: PreTripTheme.primaryLight,
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Capture en cours...',
              style: TextStyle(
                color: PreTripTheme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // UPLOADED (success)
    if (state.isUploaded) {
      return Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 22,
              height: 22,
              // ✅ Couleur dans BoxDecoration
              decoration: BoxDecoration(
                color: PreTripTheme.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: PreTripTheme.success.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.check, size: 13, color: Colors.white),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                // ✅ Couleur dans BoxDecoration
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: const Text(
                  'Reprendre',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // ERROR
    if (state.error != null) {
      return Container(
        // ✅ Uniquement color, pas de decoration
        color: const Color(0xEE1F0F12),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: PreTripTheme.error.withOpacity(0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 18,
                color: PreTripTheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatError(state.error!),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade100,
                fontSize: 10,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Text(
              'Réessayer',
              style: TextStyle(
                color: PreTripTheme.error,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // IDLE — camera-first
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          // ✅ Couleur dans BoxDecoration
          decoration: BoxDecoration(
            color: PreTripTheme.primaryDim,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            size: 20,
            color: PreTripTheme.primaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            widget.type.label,
            style: const TextStyle(
              color: PreTripTheme.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Prendre une photo',
          style: TextStyle(
            color: PreTripTheme.textHint,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _bgColor(MediaUploadState state) {
    if (state.isUploaded) return PreTripTheme.success.withOpacity(0.06);
    if (state.error != null) return PreTripTheme.error.withOpacity(0.06);
    return PreTripTheme.surface1;
  }

  Color _borderColor(MediaUploadState state) {
    if (state.isUploaded) return PreTripTheme.success.withOpacity(0.5);
    if (state.error != null) return PreTripTheme.error.withOpacity(0.4);
    if (state.isUploading) return PreTripTheme.primary.withOpacity(0.5);
    return PreTripTheme.border;
  }

  String _formatError(String error) {
    final lower = error.toLowerCase();
    if (lower.contains('unauthorized') ||
        lower.contains('no auth token') ||
        lower.contains('identifiants incorrects')) {
      return 'Session expirée. Reconnectez-vous.';
    }
    if (lower.contains('image.file is not supported') ||
        lower.contains('flutter web')) {
      return 'Aperçu Web non supporté par Image.file.';
    }
    if (lower.contains('decoration') && lower.contains('color')) {
      return 'Erreur UI : color doit être dans BoxDecoration.';
    }
    if (lower.contains('dioexception')) {
      return 'Upload refusé par le serveur.';
    }
    return error.replaceFirst('Exception: ', '');
  }
}

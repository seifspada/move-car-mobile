// lib/features/mission_session/presentation/widgets/photo_upload_checklist.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/mission_session_entity.dart';
import '../providers/mission_session_providers.dart';
import '../theme/session_theme.dart';
import '../utils/camera_capture.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC WIDGET
// ─────────────────────────────────────────────────────────────────────────────

/// Reusable photo upload checklist.
///
/// Usage (pre-départ) :
/// ```dart
/// PhotoUploadChecklist(
///   title: 'Photos pré-départ',
///   requiredPhotos: kPhotosRequisePreDepart,
///   photosProvider: prePhotosProvider,
/// )
/// ```
///
/// Usage (post-livraison) :
/// ```dart
/// PhotoUploadChecklist(
///   title: 'Photos post-livraison',
///   requiredPhotos: kPhotosRequisePostLivraison,
///   photosProvider: postPhotosProvider,
/// )
/// ```
class PhotoUploadChecklist extends ConsumerWidget {
  final String title;
  final List<TypeMediaSession> requiredPhotos;

  /// Pass either [prePhotosProvider] or [postPhotosProvider]
  final AutoDisposeStateNotifierProvider<LocalPhotoNotifier, LocalPhotoState>
      photosProvider;

  const PhotoUploadChecklist({
    super.key,
    required this.title,
    required this.requiredPhotos,
    required this.photosProvider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photos = ref.watch(photosProvider);
    final completed = requiredPhotos.where(photos.hasPhoto).length;
    final allDone = completed == requiredPhotos.length;

    return Container(
      decoration: BoxDecoration(
        color: SessionTheme.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: allDone
              ? SessionTheme.success.withOpacity(0.4)
              : SessionTheme.border,
          width: allDone ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────
          _ChecklistHeader(
            title: title,
            completed: completed,
            total: requiredPhotos.length,
            allDone: allDone,
          ),

          // ── Progress bar ────────────────────────
          _ProgressBar(completed: completed, total: requiredPhotos.length),

          // ── Photo rows ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              children: requiredPhotos
                  .map(
                    (type) => _PhotoTile(
                      type: type,
                      photos: photos,
                      onAdd: () => _capturePhoto(context, ref, type),
                      onRemove: () =>
                          ref.read(photosProvider.notifier).removePhoto(type),
                      onPreview: () =>
                          _showPreview(context, photos.getBase64(type)!),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _capturePhoto(
    BuildContext context,
    WidgetRef ref,
    TypeMediaSession type,
  ) async {
    try {
      final file = await captureInspectionPhoto();
      if (file == null) return;
      final bytes = await file.readAsBytes();
      final base64Data = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      ref.read(photosProvider.notifier).addPhoto(type, base64Data);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur photo : $e'),
            backgroundColor: SessionTheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showPreview(BuildContext context, String base64Data) {
    final bytes = base64Decode(base64Data.split(',').last);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(bytes, fit: BoxFit.contain),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERNAL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _ChecklistHeader extends StatelessWidget {
  final String title;
  final int completed;
  final int total;
  final bool allDone;

  const _ChecklistHeader({
    required this.title,
    required this.completed,
    required this.total,
    required this.allDone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: allDone
                  ? SessionTheme.success.withOpacity(0.15)
                  : SessionTheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              allDone ? Icons.check_circle_outline : Icons.photo_camera_outlined,
              color: allDone ? SessionTheme.success : SessionTheme.primaryLight,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: SessionTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  allDone
                      ? 'Toutes les photos sont prises ✓'
                      : '${total - completed} photo(s) manquante(s)',
                  style: TextStyle(
                    color: allDone
                        ? SessionTheme.success
                        : SessionTheme.textHint,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Counter badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: allDone
                  ? SessionTheme.success.withOpacity(0.15)
                  : SessionTheme.surface2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: allDone
                    ? SessionTheme.success.withOpacity(0.4)
                    : SessionTheme.border,
              ),
            ),
            child: Text(
              '$completed/$total',
              style: TextStyle(
                color: allDone
                    ? SessionTheme.success
                    : SessionTheme.primaryLight,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int completed;
  final int total;

  const _ProgressBar({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : completed / total;
    final isComplete = completed == total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 4,
          backgroundColor: SessionTheme.surface2,
          valueColor: AlwaysStoppedAnimation<Color>(
            isComplete ? SessionTheme.success : SessionTheme.primary,
          ),
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final TypeMediaSession type;
  final LocalPhotoState photos;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onPreview;

  const _PhotoTile({
    required this.type,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final taken = photos.hasPhoto(type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: taken
            ? SessionTheme.success.withOpacity(0.05)
            : SessionTheme.surface2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: taken
              ? SessionTheme.success.withOpacity(0.35)
              : SessionTheme.border,
        ),
      ),
      child: Row(
        children: [
          // Status icon
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              taken ? Icons.check_circle : Icons.radio_button_unchecked,
              key: ValueKey(taken),
              color: taken ? SessionTheme.success : SessionTheme.textHint,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),

          // Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.label,
                  style: const TextStyle(
                    color: SessionTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  taken ? 'Photo enregistrée' : 'Manquante — obligatoire',
                  style: TextStyle(
                    color: taken
                        ? SessionTheme.success
                        : SessionTheme.warning,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          if (taken) ...[
            // Preview button
            _IconBtn(
              icon: Icons.visibility_outlined,
              color: SessionTheme.primaryLight,
              tooltip: 'Aperçu',
              onTap: onPreview,
            ),
            const SizedBox(width: 2),
            // Retake button
            _IconBtn(
              icon: Icons.refresh_rounded,
              color: SessionTheme.primaryLight,
              tooltip: 'Reprendre',
              onTap: onAdd,
            ),
            const SizedBox(width: 2),
            // Delete button
            _IconBtn(
              icon: Icons.delete_outline,
              color: SessionTheme.error,
              tooltip: 'Supprimer',
              onTap: onRemove,
            ),
          ] else ...[
            // Capture button
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: SessionTheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: SessionTheme.primary.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 13,
                      color: SessionTheme.primaryLight,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Prendre',
                      style: TextStyle(
                        color: SessionTheme.primaryLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}
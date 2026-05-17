// lib/features/pretrip_inspection/presentation/pages/pretrip_inspection_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/entities/pretrip_entity.dart';
import '../providers/pretrip_providers.dart';
import '../theme/pretrip_theme.dart';
import '../widgets/inspection_step_indicator.dart';
import '../widgets/media_upload_card.dart';
import '../widgets/consent_bottom_sheet.dart';
import '../widgets/inspection_status_badge.dart';

class PreTripInspectionPage extends ConsumerStatefulWidget {
  final String reservationId;

  const PreTripInspectionPage({super.key, required this.reservationId});

  @override
  ConsumerState<PreTripInspectionPage> createState() =>
      _PreTripInspectionPageState();
}

class _PreTripInspectionPageState extends ConsumerState<PreTripInspectionPage> {
  late final _provider = preTripProvider(widget.reservationId);

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
      _initInspection();
    });
  }

  Future<void> _initInspection() async {
    final notifier = ref.read(_provider.notifier);
    await notifier.loadInspection(widget.reservationId);

    final state = ref.read(_provider);
    if (state.inspection == null && !state.isLoading) {
      await notifier.startInspection(reservationId: widget.reservationId);
    }
  }

  Future<bool> _handleUpload(TypeMediaInspection type, XFile file) async {
    final ok = await ref
        .read(_provider.notifier)
        .uploadMedia(type: type, imageFile: file);
    if (_shouldShowUploadSnackBar() && !ok && mounted) {
      final err = ref.read(_provider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'Upload échoué'),
          backgroundColor: PreTripTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
    return ok;
  }

  bool _shouldShowUploadSnackBar() => false;

  Future<void> _openConsent() async {
    await ConsentBottomSheet.show(
      context,
      onSubmit: (clauses) =>
          ref.read(_provider.notifier).submitConsent(clauses: clauses),
    );
  }

  Future<void> _validateAndStart() async {
    final result = await ref.read(_provider.notifier).validateAndStart();
    if (!mounted) return;

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur lors de la validation'),
          backgroundColor: PreTripTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (result.success) {
      _showSuccessDialog(result.inspection.reservationId);
    } else {
      final motif = result.motifRejet ?? 'Raison inconnue';
      _showRejectionDialog(motif);
    }
  }

  void _showSuccessDialog(String reservationId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: PreTripTheme.surface1,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: PreTripTheme.success.withOpacity(0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: PreTripTheme.success.withOpacity(0.2),
                blurRadius: 32,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: PreTripTheme.success.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PreTripTheme.success.withOpacity(0.4),
                  ),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: PreTripTheme.success,
                  size: 34,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Mission démarrée !',
                style: TextStyle(
                  color: PreTripTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Réservation #$reservationId\nBonne route !',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: PreTripTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: PreTripTheme.orangeGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: PreTripTheme.orangeGlowStrong,
                  ),
                  child: const Center(
                    child: Text(
                      'Commencer la mission',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectionDialog(String motifRejet) {
    final reasons = motifRejet.split(' | ').where((s) => s.isNotEmpty).toList();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: PreTripTheme.surface1,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: PreTripTheme.error.withOpacity(0.35),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: PreTripTheme.error,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Validation échouée',
                    style: TextStyle(
                      color: PreTripTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Raisons du rejet :',
                style: TextStyle(
                  color: PreTripTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              ...reasons.map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(color: PreTripTheme.error),
                      ),
                      Expanded(
                        child: Text(
                          r,
                          style: const TextStyle(
                            color: PreTripTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: 46,
                  decoration: BoxDecoration(
                    color: PreTripTheme.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PreTripTheme.border),
                  ),
                  child: const Center(
                    child: Text(
                      'Fermer',
                      style: TextStyle(
                        color: PreTripTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_provider);

    return Scaffold(
      backgroundColor: PreTripTheme.bg,
      body: !state.initialized || state.isLoading
          ? const _LoadingView()
          : state.inspection == null
          ? _ErrorView(
              error: state.error ?? "Impossible de créer l'inspection.",
              onRetry: _initInspection,
            )
          : _InspectionBody(
              state: state,
              onUpload: _handleUpload,
              onConsent: _openConsent,
              onValidate: _validateAndStart,
            ),
    );
  }
}

// ─────────────────────────────────────────
// INSPECTION BODY
// ─────────────────────────────────────────

class _InspectionBody extends StatelessWidget {
  final PreTripState state;
  final Future<bool> Function(TypeMediaInspection, XFile) onUpload;
  final VoidCallback onConsent;
  final VoidCallback onValidate;

  const _InspectionBody({
    required this.state,
    required this.onUpload,
    required this.onConsent,
    required this.onValidate,
  });

  @override
  Widget build(BuildContext context) {
    final inspection = state.inspection!;
    final totalMedia = InspectionStepMedia.totalMediaCount;
    final uploaded = state.uploadedCount;

    return CustomScrollView(
      slivers: [
        // ── Hero AppBar ──────────────────────────
        SliverAppBar(
          expandedHeight: 150,
          pinned: true,
          backgroundColor: PreTripTheme.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: PreTripTheme.textSecondary,
              size: 18,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [PreTripTheme.bg, PreTripTheme.surface1],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Title row
                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pré-inspection véhicule',
                                  style: TextStyle(
                                    color: PreTripTheme.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Avant de démarrer, vérifiez le véhicule',
                                  style: TextStyle(
                                    color: PreTripTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InspectionStatusBadge(
                            statut: inspection.statut,
                            compact: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Progress
                      Row(
                        children: [
                          Text(
                            '$uploaded / $totalMedia photos',
                            style: const TextStyle(
                              color: PreTripTheme.textHint,
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${((uploaded / totalMedia.clamp(1, totalMedia)) * 100).round()}%',
                            style: const TextStyle(
                              color: PreTripTheme.primaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: totalMedia > 0 ? uploaded / totalMedia : 0,
                          backgroundColor: PreTripTheme.border,
                          valueColor: const AlwaysStoppedAnimation(
                            PreTripTheme.primaryLight,
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Step indicator ───────────────────────
        SliverToBoxAdapter(
          child: InspectionStepIndicator(currentStep: inspection.etapeCourante),
        ),
        if (state.error != null)
          SliverToBoxAdapter(child: _ErrorBanner(error: state.error!)),

        // ── Photo sections ───────────────────────
        ...InspectionStepMedia.byStep.entries.map((entry) {
          final step = entry.key;
          final types = entry.value;

          return SliverToBoxAdapter(
            child: _PhotoSection(
              step: step,
              types: types,
              isComplete: state.isStepComplete(step),
              mediaStates: {
                for (final t in types)
                  t: state.mediaStates[t] ?? MediaUploadState(type: t),
              },
              onUpload: onUpload,
            ),
          );
        }),

        // ── Consent ─────────────────────────────
        SliverToBoxAdapter(
          child: _ConsentSection(
            consentDone: state.consentSubmitted || inspection.consent != null,
            allPhotosUploaded: uploaded >= totalMedia,
            onTap: onConsent,
          ),
        ),

        // ── Validate CTA ─────────────────────────
        SliverToBoxAdapter(
          child: _ValidateSection(
            canValidate: inspection.peutEtreValidee,
            isLoading: state.isLoading,
            onTap: onValidate,
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
    );
  }
}

// ─────────────────────────────────────────
// PHOTO SECTION
// ─────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String error;

  const _ErrorBanner({required this.error});

  @override
  Widget build(BuildContext context) {
    final message = _formatError(error);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: PreTripTheme.error.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: PreTripTheme.error.withOpacity(0.32)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline,
              color: PreTripTheme.error,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Erreur détectée',
                    style: TextStyle(
                      color: PreTripTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: PreTripTheme.textSecondary,
                      fontSize: 12,
                      height: 1.35,
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

  String _formatError(String error) {
    final lower = error.toLowerCase();
    if (lower.contains('unauthorized') ||
        lower.contains('no auth token') ||
        lower.contains('identifiants incorrects')) {
      return 'Session expirée ou token manquant. Reconnectez-vous avant de reprendre les photos.';
    }
    if (lower.contains('image.file is not supported') ||
        lower.contains('flutter web')) {
      return 'Flutter Web ne supporte pas Image.file. Les aperçus doivent passer par Image.memory ou Image.network.';
    }
    if (lower.contains('decoration') && lower.contains('color')) {
      return 'Erreur UI : un Container utilise color et decoration ensemble. La couleur doit être placée dans BoxDecoration.';
    }
    if (lower.contains('dioexception')) {
      return 'Le serveur a refusé la requête upload. Vérifiez l’authentification et la session.';
    }
    return error.replaceFirst('Exception: ', '');
  }
}

class _PhotoSection extends StatelessWidget {
  final EtapeInspection step;
  final List<TypeMediaInspection> types;
  final bool isComplete;
  final Map<TypeMediaInspection, MediaUploadState> mediaStates;
  final Future<bool> Function(TypeMediaInspection, XFile) onUpload;

  const _PhotoSection({
    required this.step,
    required this.types,
    required this.isComplete,
    required this.mediaStates,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.label,
                      style: const TextStyle(
                        color: PreTripTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Prenez toutes les photos demandées',
                      style: TextStyle(
                        color: PreTripTheme.textHint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isComplete
                    ? _Badge(
                        key: const ValueKey('done'),
                        label: 'Complet',
                        color: PreTripTheme.success,
                        icon: Icons.check,
                      )
                    : _Badge(
                        key: const ValueKey('pending'),
                        label:
                            '${mediaStates.values.where((s) => s.isUploaded).length} / ${types.length}',
                        color: PreTripTheme.primaryLight,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Photo grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.25,
            children: types.map((type) {
              return MediaUploadCard(
                type: type,
                uploadState: mediaStates[type] ?? MediaUploadState(type: type),
                onUpload: onUpload,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _Badge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// CONSENT SECTION
// ─────────────────────────────────────────

class _ConsentSection extends StatelessWidget {
  final bool consentDone;
  final bool allPhotosUploaded;
  final VoidCallback onTap;

  const _ConsentSection({
    required this.consentDone,
    required this.allPhotosUploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = allPhotosUploaded && !consentDone;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: consentDone
                ? PreTripTheme.success.withOpacity(0.08)
                : isEnabled
                ? PreTripTheme.primaryDim
                : PreTripTheme.surface1,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: consentDone
                  ? PreTripTheme.success.withOpacity(0.5)
                  : isEnabled
                  ? PreTripTheme.primary.withOpacity(0.6)
                  : PreTripTheme.border,
              width: 1,
            ),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: PreTripTheme.primary.withOpacity(0.25),
                      blurRadius: 16,
                    ),
                  ]
                : consentDone
                ? [
                    BoxShadow(
                      color: PreTripTheme.success.withOpacity(0.15),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: consentDone
                      ? PreTripTheme.success.withOpacity(0.15)
                      : isEnabled
                      ? PreTripTheme.primaryDim
                      : PreTripTheme.surface2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  consentDone ? Icons.verified : Icons.shield_outlined,
                  color: consentDone
                      ? PreTripTheme.success
                      : isEnabled
                      ? PreTripTheme.primaryLight
                      : PreTripTheme.textHint,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consentDone
                          ? 'Conditions validées ✓'
                          : 'Conditions obligatoires',
                      style: TextStyle(
                        color: consentDone
                            ? PreTripTheme.success
                            : isEnabled
                            ? PreTripTheme.textPrimary
                            : PreTripTheme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      consentDone
                          ? ''
                          : !allPhotosUploaded
                          ? 'Terminez les photos d\'abord'
                          : 'Appuyez pour valider',
                      style: const TextStyle(
                        color: PreTripTheme.textHint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (isEnabled)
                const Icon(
                  Icons.chevron_right,
                  color: PreTripTheme.primaryLight,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// VALIDATE SECTION
// ─────────────────────────────────────────

class _ValidateSection extends StatelessWidget {
  final bool canValidate;
  final bool isLoading;
  final VoidCallback onTap;

  const _ValidateSection({
    required this.canValidate,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: GestureDetector(
        onTap: canValidate && !isLoading ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 56,
          decoration: BoxDecoration(
            gradient: canValidate && !isLoading
                ? PreTripTheme.orangeGradient
                : null,
            color: canValidate && !isLoading ? null : PreTripTheme.surface2,
            borderRadius: BorderRadius.circular(16),
            boxShadow: canValidate && !isLoading
                ? PreTripTheme.orangeGlowStrong
                : null,
            border: Border.all(
              color: canValidate && !isLoading
                  ? Colors.transparent
                  : PreTripTheme.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              else
                Icon(
                  Icons.rocket_launch,
                  color: canValidate ? Colors.white : PreTripTheme.textHint,
                  size: 20,
                ),
              const SizedBox(width: 10),
              Text(
                canValidate ? 'Démarrer la mission' : "Complétez l'inspection",
                style: TextStyle(
                  color: canValidate ? Colors.white : PreTripTheme.textHint,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// LOADING / ERROR VIEWS
// ─────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: PreTripTheme.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: PreTripTheme.primary),
            SizedBox(height: 16),
            Text(
              "Chargement de l'inspection...",
              style: TextStyle(color: PreTripTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PreTripTheme.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: PreTripTheme.error.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: PreTripTheme.error.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 38,
                  color: PreTripTheme.error,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Erreur',
                style: TextStyle(
                  color: PreTripTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: PreTripTheme.textSecondary),
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: PreTripTheme.orangeGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: PreTripTheme.orangeGlow,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Réessayer',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

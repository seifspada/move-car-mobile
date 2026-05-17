// lib/features/home/presentation/widgets/notification_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:convoyeur_mobile/app/theme/app_colors.dart';
import '../../../missions/data/models/mission_model.dart';
import '../../../missions/presentation/providers/mission_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Couleurs cohérentes avec les modals existants
// ─────────────────────────────────────────────────────────────────────────────
const _bgModal   = Color(0xFF18181B); // zinc-900
const _bgSection = Color(0xFF27272A); // zinc-800
const _bgSlider  = Color(0xFF3F3F46); // zinc-700
const _orange    = Color(0xFFEA580C); // orange-600
const _orangeTxt = Color(0xFFF97316); // orange-500
const _green     = Color(0xFF10B981); // emerald-500
const _textPrimary   = Colors.white;
const _textSecondary = Color(0xFFD4D4D8);
const _textMuted     = Color(0xFF71717A);

/// Affiche le panneau de notifications (bottom sheet)
void showNotificationPanel(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => const _NotificationSheet(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet principal
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationSheet extends ConsumerWidget {
  const _NotificationSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: _bgModal,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _bgSlider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // ── Header ───────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.notifications_active,
                            color: _orangeTxt,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Mes alertes',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Refresh
                        GestureDetector(
                          onTap: () => ref.invalidate(myAlertesProvider),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _bgSection,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _bgSlider),
                            ),
                            child: const Icon(
                              Icons.refresh,
                              color: _textSecondary,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(
                            Icons.close,
                            color: _textMuted,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Divider ──────────────────────────────────────
              Container(
                height: 1,
                color: _bgSlider.withOpacity(0.5),
              ),

              // ── Contenu ──────────────────────────────────────
              Expanded(
                child: ref.watch(myAlertesProvider).when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: _orange),
                  ),
                  error: (e, _) => _ErrorState(
                    message: e.toString(),
                    onRetry: () => ref.invalidate(myAlertesProvider),
                  ),
                  data: (alertes) {
                    if (alertes.isEmpty) {
                      return const _EmptyState();
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: alertes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _AlerteTile(alerte: alertes[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tile d'une alerte
// ─────────────────────────────────────────────────────────────────────────────
class _AlerteTile extends StatelessWidget {
  final AlerteModel alerte;
  const _AlerteTile({required this.alerte});

  @override
  Widget build(BuildContext context) {
    final bool isTrajet = alerte.type == 'TRAJET';
    final Color accentColor = isTrajet ? _orangeTxt : _green;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _bgSection,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: alerte.actif
              ? accentColor.withOpacity(0.25)
              : _bgSlider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Icône ──────────────────────────────────────────
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isTrajet ? Icons.route : Icons.location_on,
              color: accentColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // ── Texte ──────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerte.displayTitle,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  alerte.displaySubtitle,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                  ),
                ),
                if (alerte.formattedDate.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    alerte.formattedDate,
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Badges ─────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Statut actif/inactif
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: alerte.actif
                      ? _green.withOpacity(0.12)
                      : Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  alerte.actif ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    color: alerte.actif ? _green : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Push / Email indicators
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (alerte.pushActif)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        Icons.phone_android,
                        color: _orangeTxt.withOpacity(0.7),
                        size: 14,
                      ),
                    ),
                  if (alerte.emailActif)
                    Icon(
                      Icons.email_outlined,
                      color: _textMuted.withOpacity(0.7),
                      size: 14,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// État vide
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _bgSection,
                shape: BoxShape.circle,
                border: Border.all(color: _bgSlider),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: _textMuted,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucune alerte',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Créez une alerte depuis la recherche\npour être notifié des nouvelles missions',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// État erreur
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                color: _textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textMuted, fontSize: 12),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: _textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

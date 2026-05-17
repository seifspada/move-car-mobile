// lib/features/reservations/presentation/widgets/cancel_modal.dart

import 'package:flutter/material.dart';
import 'package:convoyeur_mobile/app/theme/app_colors.dart';

enum CancelMode { direct, request }

class CancelModal extends StatefulWidget {
  final CancelMode mode;
  final bool isLoading;
  final Future<void> Function(String? motif) onConfirm;

  const CancelModal({
    super.key,
    required this.mode,
    required this.isLoading,
    required this.onConfirm,
  });

  // Helper statique pour afficher le modal
  static Future<void> show({
    required BuildContext context,
    required CancelMode mode,
    required Future<void> Function(String? motif) onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CancelModal(
        mode: mode,
        isLoading: false,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<CancelModal> createState() => _CancelModalState();
}

class _CancelModalState extends State<CancelModal> {
  final _motifCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _motifCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (widget.mode == CancelMode.request && _motifCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await widget.onConfirm(
        _motifCtrl.text.trim().isEmpty ? null : _motifCtrl.text.trim(),
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDirect = widget.mode == CancelMode.direct;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ────────────────────────────────
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // ── Header ────────────────────────────────
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDirect ? 'Annuler la réservation' : "Demande d'annulation",
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDirect
                            ? 'Cette action est irréversible'
                            : "L'agent devra valider votre demande",
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close, color: AppColors.textHint, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Info box ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDirect
                    ? const Color(0xFFEAB308).withOpacity(0.1)
                    : const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDirect
                      ? const Color(0xFFEAB308).withOpacity(0.2)
                      : const Color(0xFF3B82F6).withOpacity(0.2),
                ),
              ),
              child: Text(
                isDirect
                    ? '⏱️ Annulation gratuite — vous êtes dans le délai de 24h'
                    : "📋 Délai de 24h dépassé — votre demande sera soumise à l'agent pour validation",
                style: TextStyle(
                  color: isDirect
                      ? const Color(0xFFEAB308)
                      : const Color(0xFF3B82F6),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Motif ─────────────────────────────────
            Row(
              children: [
                Text(
                  "Motif d'annulation",
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!isDirect) ...[
                  const SizedBox(width: 4),
                  const Text('*', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
                ],
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _motifCtrl,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: isDirect ? 'Optionnel...' : 'Expliquez votre demande...',
              ),
            ),
            const SizedBox(height: 20),

            // ── Boutons ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Retour',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: _loading ? null : _handleConfirm,
                        child: Center(
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isDirect
                                      ? "Confirmer l'annulation"
                                      : 'Envoyer la demande',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
// lib/features/pretrip_inspection/presentation/widgets/consent_bottom_sheet.dart

import 'package:flutter/material.dart';
import '../theme/pretrip_theme.dart';

class ConsentBottomSheet extends StatefulWidget {
  final Future<bool> Function(Map<String, bool> clauses) onSubmit;

  const ConsentBottomSheet({super.key, required this.onSubmit});

  static Future<bool?> show(
    BuildContext context, {
    required Future<bool> Function(Map<String, bool>) onSubmit,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) => ConsentBottomSheet(onSubmit: onSubmit),
    );
  }

  @override
  State<ConsentBottomSheet> createState() => _ConsentBottomSheetState();
}

class _ConsentBottomSheetState extends State<ConsentBottomSheet> {
  final Map<String, bool> _clauses = {
    'vehiculeVerifie': false,
    'photosReelles': false,
    'codeRoute': false,
    'conduiteResponsable': false,
    'suiviGps': false,
    'scoringConduite': false,
    'responsabiliteNegligence': false,
    'apteAConduire': false,
    'acceptationGlobale': false,
  };

  bool _isSubmitting = false;

  static const Map<String, _ClauseData> _clausesData = {
    'vehiculeVerifie': _ClauseData(
      icon: Icons.car_repair,
      label: "J'ai vérifié le véhicule avant le départ",
    ),
    'photosReelles': _ClauseData(
      icon: Icons.camera_alt_outlined,
      label: 'Les photos sont réelles et prises maintenant',
    ),
    'codeRoute': _ClauseData(
      icon: Icons.traffic_outlined,
      label: 'Je respecterai le code de la route',
    ),
    'conduiteResponsable': _ClauseData(
      icon: Icons.self_improvement,
      label: 'Je conduirai de manière responsable',
    ),
    'suiviGps': _ClauseData(
      icon: Icons.location_on_outlined,
      label: "J'accepte le suivi GPS en temps réel",
    ),
    'scoringConduite': _ClauseData(
      icon: Icons.analytics_outlined,
      label: "J'accepte le scoring de ma conduite",
    ),
    'responsabiliteNegligence': _ClauseData(
      icon: Icons.warning_amber_outlined,
      label: "J'assume ma responsabilité en cas de négligence",
    ),
    'apteAConduire': _ClauseData(
      icon: Icons.bedtime_outlined,
      label: 'Je suis reposé et apte à conduire',
    ),
    'acceptationGlobale': _ClauseData(
      icon: Icons.verified_outlined,
      label: "J'accepte toutes les conditions ci-dessus",
      isGlobal: true,
    ),
  };

  bool get _allAccepted => _clauses.values.every((v) => v);

  Future<void> _submit() async {
    if (!_allAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez accepter toutes les clauses'),
          backgroundColor: PreTripTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final ok = await widget.onSubmit(_clauses);
    if (mounted) {
      setState(() => _isSubmitting = false);
      Navigator.of(context).pop(ok);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ Couleur dans BoxDecoration
      decoration: const BoxDecoration(
        color: PreTripTheme.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.6,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                // ✅ Couleur dans BoxDecoration
                decoration: BoxDecoration(
                  color: PreTripTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    // ✅ Couleur dans BoxDecoration
                    decoration: BoxDecoration(
                      color: PreTripTheme.primaryDim,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: PreTripTheme.primaryLight,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conditions de mission',
                          style: TextStyle(
                            color: PreTripTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Lisez et acceptez chaque clause',
                          style: TextStyle(
                            color: PreTripTheme.textHint,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: PreTripTheme.border),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                children: [
                  ..._clausesData.entries.map((e) {
                    final data = e.value;
                    return _ClauseItem(
                      key: Key(e.key),
                      clauseKey: e.key,
                      data: data,
                      value: _clauses[e.key] ?? false,
                      onChanged: (v) => setState(() => _clauses[e.key] = v),
                    );
                  }),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _SubmitButton(
                  isSubmitting: _isSubmitting,
                  isEnabled: _allAccepted,
                  onTap: _submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClauseData {
  final IconData icon;
  final String label;
  final bool isGlobal;

  const _ClauseData({
    required this.icon,
    required this.label,
    this.isGlobal = false,
  });
}

class _ClauseItem extends StatelessWidget {
  final String clauseKey;
  final _ClauseData data;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ClauseItem({
    super.key,
    required this.clauseKey,
    required this.data,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isGlobal) {
      return Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: GestureDetector(
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(14),
            // ✅ Couleur dans BoxDecoration
            decoration: BoxDecoration(
              color: value
                  ? PreTripTheme.success.withOpacity(0.1)
                  : PreTripTheme.surface2,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: value
                    ? PreTripTheme.success.withOpacity(0.5)
                    : PreTripTheme.primary.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: value
                  ? [
                      BoxShadow(
                        color: PreTripTheme.success.withOpacity(0.15),
                        blurRadius: 12,
                      )
                    ]
                  : [
                      BoxShadow(
                        color: PreTripTheme.primary.withOpacity(0.15),
                        blurRadius: 10,
                      )
                    ],
            ),
            child: Row(
              children: [
                Icon(
                  value ? Icons.check_circle : Icons.check_circle_outline,
                  color: value ? PreTripTheme.success : PreTripTheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.label,
                    style: TextStyle(
                      color: value
                          ? PreTripTheme.success
                          : PreTripTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _Checkbox(value: value),
              ],
            ),
          ),
        ),
      );
    }

    // Regular clause
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        // ✅ Couleur dans BoxDecoration
        decoration: BoxDecoration(
          color: value
              ? PreTripTheme.primary.withOpacity(0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? PreTripTheme.primary.withOpacity(0.3)
                : PreTripTheme.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              data.icon,
              size: 18,
              color: value
                  ? PreTripTheme.primaryLight
                  : PreTripTheme.textHint,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                data.label,
                style: TextStyle(
                  color: value
                      ? PreTripTheme.textPrimary
                      : PreTripTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: value ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            _Checkbox(value: value),
          ],
        ),
      ),
    );
  }
}

class _Checkbox extends StatelessWidget {
  final bool value;
  const _Checkbox({required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 20,
      height: 20,
      // ✅ Couleur dans BoxDecoration
      decoration: BoxDecoration(
        color: value ? PreTripTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: value ? PreTripTheme.primary : PreTripTheme.border,
          width: 1.5,
        ),
      ),
      child: value
          ? const Icon(Icons.check, size: 13, color: Colors.white)
          : null,
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final bool isEnabled;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.isSubmitting,
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSubmitting || !isEnabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 54,
        // ✅ Gradient OU couleur dans BoxDecoration (jamais les deux)
        decoration: BoxDecoration(
          gradient: isEnabled && !isSubmitting
              ? const LinearGradient(
                  colors: [PreTripTheme.primary, PreTripTheme.primaryLight],
                )
              : null,
          color: isEnabled && !isSubmitting ? null : PreTripTheme.surface2,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isEnabled && !isSubmitting
              ? [
                  BoxShadow(
                    color: PreTripTheme.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Center(
          child: isSubmitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  'Confirmer et continuer',
                  style: TextStyle(
                    color: isEnabled ? Colors.white : PreTripTheme.textHint,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}
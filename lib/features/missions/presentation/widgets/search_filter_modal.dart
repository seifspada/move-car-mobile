// lib/widgets/search_filter_modal.dart
//
// Inspiré de SearchFilter.tsx (Next.js)
// Utilise MapComponent depuis map.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:convoyeur_mobile/features/missions/data/models/mission_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'map.dart'; // ← MapComponent + MapPoint
import '../providers/mission_providers.dart';
import 'city_autocomplete.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────
class SearchFilterModal extends ConsumerStatefulWidget {
  const SearchFilterModal({super.key});

  @override
  ConsumerState<SearchFilterModal> createState() => _SearchFilterModalState();
}

class _SearchFilterModalState extends ConsumerState<SearchFilterModal> {
  DateTime? _selectedDateDepart;
  DateTime? _selectedDateRetour;
  bool _isCreatingAlert = false;

  // ── Palette zinc/orange (identique à search_position_modal) ──────────────
  static const _bgModal   = Color(0xFF18181B); // zinc-900
  static const _bgSection = Color(0xFF27272A); // zinc-800
  static const _bgSlider  = Color(0xFF3F3F46); // zinc-700
  static const _orange    = Color(0xFFEA580C); // orange-600
  static const _orangeTxt = Color(0xFFF97316); // orange-500
  static const _green     = Color(0xFF10B981); // emerald-500 (arrivée)
  static const _textPrimary   = Colors.white;
  static const _textSecondary = Color(0xFFD4D4D8); // gray-300
  static const _textMuted     = Color(0xFF71717A); // gray-500

  // ─────────────────────────────────────────────────────────────────────────
  // Logique des points de la carte — fidèle au .tsx
  // ─────────────────────────────────────────────────────────────────────────
  List<MapPoint> _buildMapPoints({
    required dynamic depart,
    required dynamic arrivee,
    required double radius,
  }) {
    final List<MapPoint> pts = [];

    if (depart != null) {
      pts.add(MapPoint(
        position: LatLng(depart.lat, depart.lon),
        radius: radius * 1000, // km → mètres
        color: _orangeTxt,
        label: 'départ',
      ));
    }
    if (arrivee != null) {
      pts.add(MapPoint(
        position: LatLng(arrivee.lat, arrivee.lon),
        radius: radius * 1000,
        color: _green,
        label: 'arrivée',
      ));
    }

    return pts;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final depart      = ref.watch(selectedTrajetDepartProvider);
    final arrivee     = ref.watch(selectedTrajetArriveeProvider);
    final radius      = ref.watch(trajetRadiusProvider);
    final alertActive = ref.watch(trajetAlertActiveProvider);

    final mapPoints = _buildMapPoints(
      depart: depart,
      arrivee: arrivee,
      radius: radius,
    );

    final bool showMap  = mapPoints.isNotEmpty;
    final bool showAlert = depart != null && arrivee != null;
    final bool canSearch = (depart != null || arrivee != null) && !_isCreatingAlert;

    return DraggableScrollableSheet(
      initialChildSize: 0.93,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (context, scrollController) {
        return Material(
          color: Colors.transparent,
          child: Container(
          decoration: const BoxDecoration(
            color: _bgModal,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Drag handle ──────────────────────────────────────
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: _bgSlider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Header ───────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.search, color: _orangeTxt, size: 22),
                        const SizedBox(width: 10),
                        const Text(
                          'Chercher une mission',
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
                        // Bouton "Effacer" — visible si au moins une ville
                        if (depart != null || arrivee != null)
                          TextButton(
                            onPressed: _clearFilters,
                            style: TextButton.styleFrom(
                              foregroundColor: _textMuted,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                            ),
                            child: const Text('Effacer',
                                style: TextStyle(fontSize: 13)),
                          ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Icon(Icons.close,
                              color: _textMuted, size: 22),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Villes départ / arrivée (colonne sur mobile) ─────
                CityAutocompleteField(
                  label: 'Ville de départ',
                  placeholder: 'Ex: Paris',
                  onCitySelected: (city) =>
                      ref.read(selectedTrajetDepartProvider.notifier).state =
                          city,
                ),
                const SizedBox(height: 14),
                CityAutocompleteField(
                  label: 'Ville d\'arrivée',
                  placeholder: 'Ex: Lyon',
                  onCitySelected: (city) =>
                      ref.read(selectedTrajetArriveeProvider.notifier).state =
                          city,
                ),
                const SizedBox(height: 20),

                // ── Carte — visible seulement si ≥ 1 point ───────────
                // Reproduit le comportement conditionnel du .tsx
                if (showMap) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: _bgSlider),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      // MapComponent gère fitBounds automatiquement
                      // quand points.length > 1 (cf. map.dart)
                      child: MapComponent(points: mapPoints),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Slider rayon ─────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rayon de recherche',
                      style: TextStyle(
                          color: _textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${radius.toInt()} km',
                      style: const TextStyle(
                          color: _orangeTxt,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _orange,
                    inactiveTrackColor: _bgSlider,
                    thumbColor: _orange,
                    overlayColor: _orange.withOpacity(0.15),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: radius,
                    min: 0,
                    max: 300,
                    divisions: 30,
                    onChanged: (v) =>
                        ref.read(trajetRadiusProvider.notifier).state = v,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('0 km',
                        style: TextStyle(color: _textMuted, fontSize: 11)),
                    Text('300 km',
                        style: TextStyle(color: _textMuted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Alerte trajet — visible si départ ET arrivée ──────
                if (showAlert) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _bgSection,
                      border: Border.all(
                          color: _orange.withOpacity(0.2), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications,
                            color: Color(0xFFEAB308), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Activer l\'alerte trajet',
                                style: TextStyle(
                                    color: _textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Notification pour '
                                '${depart!.name} → ${arrivee!.name}',
                                style: const TextStyle(
                                    color: _textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        // Toggle custom (même animation que SearchPosition)
                        GestureDetector(
                          onTap: () => ref
                              .read(trajetAlertActiveProvider.notifier)
                              .state = !alertActive,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 26,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: alertActive ? _orange : _bgSlider,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            alignment: alertActive
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // ── Dates ─────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _DatePickerButton(
                        label: 'Date de départ',
                        date: _selectedDateDepart,
                        onTap: () async {
                          final d = await _pickDate(context);
                          if (d != null) {
                            setState(() => _selectedDateDepart = d);
                            ref.read(trajetDateDepartProvider.notifier).state =
                                d;
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DatePickerButton(
                        label: 'Date de retour',
                        date: _selectedDateRetour,
                        onTap: () async {
                          final d = await _pickDate(context);
                          if (d != null) {
                            setState(() => _selectedDateRetour = d);
                            ref.read(trajetDateRetourProvider.notifier).state =
                                d;
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Boutons Annuler / Rechercher ──────────────────────
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _bgSection,
                          foregroundColor: _textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('Annuler',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: canSearch
                            ? () => _handleSearch(
                                  context: context,
                                  depart: depart,
                                  arrivee: arrivee,
                                  radius: radius,
                                  alertActive: alertActive,
                                )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orange,
                          foregroundColor: _textPrimary,
                          disabledBackgroundColor: _bgSection,
                          disabledForegroundColor: _textMuted,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: _isCreatingAlert
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Rechercher',
                                style:
                                    TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ), // Container
        ); // Material
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<DateTime?> _pickDate(BuildContext context) => showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFEA580C),
              surface: Color(0xFF27272A),
            ),
          ),
          child: child!,
        ),
      );

  void _clearFilters() {
    ref.read(selectedTrajetDepartProvider.notifier).state = null;
    ref.read(selectedTrajetArriveeProvider.notifier).state = null;
    ref.read(trajetRadiusProvider.notifier).state = 50;
    ref.read(trajetAlertActiveProvider.notifier).state = false;
    ref.read(trajetDateDepartProvider.notifier).state = null;
    ref.read(trajetDateRetourProvider.notifier).state = null;
    setState(() {
      _selectedDateDepart = null;
      _selectedDateRetour = null;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Filtres effacés')));
  }

  Future<void> _handleSearch({
    required BuildContext context,
    required dynamic depart,
    required dynamic arrivee,
    required double radius,
    required bool alertActive,
  }) async {
    // 1. Créer l'alerte dès que les deux villes sont renseignées
    if (depart != null && arrivee != null) {
      setState(() => _isCreatingAlert = true);
      try {
        // ✅ Récupérer le fcmToken (try-catch pour éviter l'erreur MIME sur Flutter Web)
        String? fcmToken;
        try {
          fcmToken = await FirebaseMessaging.instance.getToken();
        } catch (e) {
          debugPrint('⚠️ FCM getToken échoué (normal sur web): $e');
        }

        final alert = MissionAlert.trajet(
          villeDepartNom: depart.name,
          latitudeDepart: depart.lat,
          longitudeDepart: depart.lon,
          villeArriveeNom: arrivee.name,
          latitudeArrivee: arrivee.lat,
          longitudeArrivee: arrivee.lon,
          rayon: radius,
          dateDepart: _selectedDateDepart?.toIso8601String(),
          dateRetour: _selectedDateRetour?.toIso8601String(),
          pushActif: alertActive,
          fcmToken: fcmToken,
        );
        await ref.read(createAlertProvider(alert).future);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur: $e')));
        setState(() => _isCreatingAlert = false);
        return;
      } finally {
        setState(() => _isCreatingAlert = false);
      }
    }

    // 2. Basculer en mode trajet + page 1
    ref.read(searchModeProvider.notifier).state = SearchMode.trajet;
    ref.read(currentPageProvider.notifier).state = 1;

    if (mounted) Navigator.of(context).pop();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sous-widget date picker — extrait pour clarté
// ─────────────────────────────────────────────────────────────────────────────
class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = date != null
        ? '${date!.day.toString().padLeft(2, '0')}/'
            '${date!.month.toString().padLeft(2, '0')}/'
            '${date!.year}'
        : '--/--/----';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF27272A),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF3F3F46)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                  color: Color(0xFF71717A),
                  fontSize: 11,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Color(0xFFF97316), size: 14),
                const SizedBox(width: 6),
                Text(
                  formatted,
                  style: TextStyle(
                    color: date != null ? Colors.white : const Color(0xFF71717A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

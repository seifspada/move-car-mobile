// lib/features/missions/presentation/widgets/search_position_modal.dart

import 'package:convoyeur_mobile/features/missions/data/models/mission_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'map.dart';
import '../providers/mission_providers.dart';
import 'city_autocomplete.dart';

double _zoomFromRadius(double radiusKm) {
  if (radiusKm <= 20) return 10;
  if (radiusKm <= 50) return 9;
  if (radiusKm <= 100) return 8;
  if (radiusKm <= 150) return 7;
  return 6;
}

class SearchPositionModal extends ConsumerStatefulWidget {
  const SearchPositionModal({super.key});

  @override
  ConsumerState<SearchPositionModal> createState() => _SearchPositionModalState();
}

class _SearchPositionModalState extends ConsumerState<SearchPositionModal> {
  bool _isCreatingAlert = false;
  DateTime? _selectedDateDepart;
  DateTime? _selectedDateDepartMax;

  static const _bgModal    = Color(0xFF18181B);
  static const _bgSection  = Color(0xFF27272A);
  static const _bgSlider   = Color(0xFF3F3F46);
  static const _orange     = Color(0xFFEA580C);
  static const _orangeText = Color(0xFFF97316);
  static const _textPrimary   = Colors.white;
  static const _textSecondary = Color(0xFFD4D4D8);
  static const _textMuted     = Color(0xFF71717A);

  @override
  Widget build(BuildContext context) {
    final selectedCity = ref.watch(selectedPositionCityProvider);
    final radius       = ref.watch(positionRadiusProvider);
    final alertActive  = ref.watch(positionAlertActiveProvider);

    final LatLng mapCenter = selectedCity != null
        ? LatLng(selectedCity.lat, selectedCity.lon)
        : const LatLng(46.603354, 1.888334);

    final double mapZoom = selectedCity != null ? _zoomFromRadius(radius) : 5;

    final List<MapPoint>? mapPoints = selectedCity != null
        ? [
            MapPoint(
              position: LatLng(selectedCity.lat, selectedCity.lon),
              radius: radius * 1000,
              color: _orangeText,
              label: selectedCity.name,
            ),
          ]
        : null;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (context, scrollController) {
        return Container(
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
                // ── Drag handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: _bgSlider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ── Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      const Icon(Icons.location_on, color: _orangeText, size: 22),
                      const SizedBox(width: 10),
                      const Text('Missions autour de moi',
                          style: TextStyle(color: _textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    ]),
                    Row(children: [
                      if (selectedCity != null)
                        TextButton(
                          onPressed: _clearFilters,
                          style: TextButton.styleFrom(
                              foregroundColor: _textMuted,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                          child: const Text('Effacer', style: TextStyle(fontSize: 13)),
                        ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(Icons.close, color: _textMuted, size: 22),
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Autocomplete ville
                CityAutocompleteField(
                  label: 'Ville',
                  placeholder: 'Entrez votre ville (min. 2 caractères)',
                  onCitySelected: (city) =>
                      ref.read(selectedPositionCityProvider.notifier).state = city,
                ),
                const SizedBox(height: 16),

                // ── Carte
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 320,
                    decoration: BoxDecoration(
                      border: Border.all(color: _bgSlider, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: MapComponent(
                      center: mapCenter,
                      zoom: mapZoom,
                      points: mapPoints,
                      radius: selectedCity != null ? radius * 1000 : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Slider rayon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Rayon de recherche',
                        style: TextStyle(color: _textSecondary, fontSize: 14, fontWeight: FontWeight.w500)),
                    Text('${radius.toInt()} km',
                        style: const TextStyle(color: _orangeText, fontSize: 15, fontWeight: FontWeight.bold)),
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
                    value: radius, min: 10, max: 300, divisions: 29,
                    onChanged: (v) => ref.read(positionRadiusProvider.notifier).state = v,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('10 km', style: TextStyle(color: _textMuted, fontSize: 11)),
                    Text('300 km', style: TextStyle(color: _textMuted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Bloc alerte
                if (selectedCity != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _bgSection,
                      border: Border.all(color: _orange.withOpacity(0.2), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications, color: Color(0xFFEAB308), size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Activer l\'alerte',
                                  style: TextStyle(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text(
                                'Recevoir une notification pour chaque nouvelle mission près de ${selectedCity.name}',
                                style: const TextStyle(color: _textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => ref.read(positionAlertActiveProvider.notifier).state = !alertActive,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48, height: 26,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: alertActive ? _orange : _bgSlider,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            alignment: alertActive ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              width: 20, height: 20,
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ Dates — visibles seulement si alerte activée
                  if (alertActive) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DatePickerButton(
                            label: 'Date de départ',
                            date: _selectedDateDepart,
                            onTap: () async {
                              final d = await _pickDate(context);
                              if (d != null) setState(() => _selectedDateDepart = d);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DatePickerButton(
                            label: 'Date limite',
                            date: _selectedDateDepartMax,
                            onTap: () async {
                              final d = await _pickDate(context);
                              if (d != null) setState(() => _selectedDateDepartMax = d);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                ],

                // ── Boutons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _bgSection, foregroundColor: _textPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (selectedCity != null && !_isCreatingAlert)
                            ? () => _handleSearch(
                                  context: context,
                                  selectedCity: selectedCity,
                                  radius: radius,
                                  alertActive: alertActive,
                                )
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _orange, foregroundColor: _textPrimary,
                          disabledBackgroundColor: _bgSection, disabledForegroundColor: _textMuted,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: _isCreatingAlert
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Rechercher', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
    ref.read(selectedPositionCityProvider.notifier).state = null;
    ref.read(positionRadiusProvider.notifier).state = 10;
    ref.read(positionAlertActiveProvider.notifier).state = false;
    setState(() {
      _selectedDateDepart = null;
      _selectedDateDepartMax = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtres effacés')),
    );
  }

  Future<void> _handleSearch({
    required BuildContext context,
    required selectedCity,
    required double radius,
    required bool alertActive,
  }) async {
    // 1. Créer l'alerte dès qu'une ville est sélectionnée
    if (selectedCity != null) {
      setState(() => _isCreatingAlert = true);
      try {
        // ✅ Récupérer le fcmToken (try-catch pour éviter l'erreur MIME sur Flutter Web)
        String? fcmToken;
        try {
          fcmToken = await FirebaseMessaging.instance.getToken();
        } catch (e) {
          debugPrint('⚠️ FCM getToken échoué (normal sur web): $e');
        }

        final alert = MissionAlert.geographique(
          villeNom:  selectedCity.name,
          latitude:  selectedCity.lat,
          longitude: selectedCity.lon,
          rayon:     radius,
          fcmToken:  fcmToken,
          pushActif: alertActive,
          dateDepart:  _selectedDateDepart?.toIso8601String(),
          dateRetour:  _selectedDateDepartMax?.toIso8601String(),
        );
        await ref.read(createAlertProvider(alert).future);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
        setState(() => _isCreatingAlert = false);
        return;
      } finally {
        setState(() => _isCreatingAlert = false);
      }
    }

    ref.read(searchModeProvider.notifier).state = SearchMode.position;
    ref.read(currentPageProvider.notifier).state = 1;
    if (mounted) Navigator.of(context).pop();
  }
}

// ── Date picker button
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
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF71717A), fontSize: 11, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFFF97316), size: 14),
                const SizedBox(width: 6),
                Text(formatted,
                    style: TextStyle(
                      color: date != null ? Colors.white : const Color(0xFF71717A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
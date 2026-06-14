// lib/features/missions/presentation/widgets/DynamicMissionsMap.dart

import 'dart:convert';
import 'package:convoyeur_mobile/features/missions/domain/entities/mission_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Modèles internes
// ─────────────────────────────────────────────────────────────────────────────

class _RouteStats {
  final double distanceKm;
  final int? durationMinutes;

  const _RouteStats({required this.distanceKm, this.durationMinutes});
}

class _RouteData {
  final List<LatLng> coordinates;
  final double? distanceKm;
  final int? durationMinutes;
  final bool isDirect;

  const _RouteData({
    required this.coordinates,
    this.distanceKm,
    this.durationMinutes,
    this.isDirect = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget principal
// ─────────────────────────────────────────────────────────────────────────────

class DynamicMissionsMap extends StatefulWidget {
  final MissionDetail mission;
  final void Function(int durationMinutes)? onDurationCalculated;

  const DynamicMissionsMap({
    super.key,
    required this.mission,
    this.onDurationCalculated,
  });

  @override
  State<DynamicMissionsMap> createState() => _DynamicMissionsMapState();
}

class _DynamicMissionsMapState extends State<DynamicMissionsMap> {
  final MapController _mapController = MapController();

  bool _loading = true;
  String? _error;
  _RouteStats? _routeStats;
  _RouteData? _routeData;

  LatLng? _startCoords;
  LatLng? _endCoords;

  static final Map<String, LatLng> _geocodeCache = {};

  static const _orange = Color(0xFFF97316);
  static const _green  = Color(0xFF10B981);

  // ✅ FIX 3 — Centre Tunisie
  static const _tunisieCenter = LatLng(33.8869, 9.5375);

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  @override
  void didUpdateWidget(DynamicMissionsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mission.id != widget.mission.id) {
      setState(() {
        _loading = true;
        _error = null;
        _routeStats = null;
        _routeData = null;
      });
      _loadRoute();
    }
  }

  Future<LatLng?> _getCoordinates(
    String villeNom, {
    double? latitude,
    double? longitude,
  }) async {
    if (latitude != null && longitude != null && latitude != 0 && longitude != 0) {
      return LatLng(latitude, longitude);
    }
    return _geocodeCity(villeNom);
  }

  // ✅ FIX 4 — Géocodage Tunisie
  Future<LatLng?> _geocodeCity(String cityName) async {
    if (_geocodeCache.containsKey(cityName)) {
      return _geocodeCache[cityName];
    }
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?format=json'
        '&q=${Uri.encodeComponent("$cityName, Tunisie")}'
        '&limit=1',
      );
      final response = await http.get(uri, headers: {
        'User-Agent': 'MoveCar/1.0',
      });
      final data = jsonDecode(response.body) as List;
      if (data.isNotEmpty) {
        final coords = LatLng(
          double.parse(data[0]['lat'] as String),
          double.parse(data[0]['lon'] as String),
        );
        _geocodeCache[cityName] = coords;
        return coords;
      }
    } catch (e) {
      debugPrint('Erreur géocodage $cityName: $e');
    }
    return null;
  }

  Future<_RouteData> _fetchRoute(LatLng start, LatLng end) async {
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};'
          '${end.longitude},${end.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['code'] == 'Ok') {
        final route = (data['routes'] as List).first as Map<String, dynamic>;
        final durationMin = (route['duration'] as num) ~/ 60;
        final distKm      = (route['distance'] as num) / 1000;

        widget.onDurationCalculated?.call(durationMin);

        final rawCoords = (route['geometry']['coordinates'] as List)
            .map((c) => LatLng(
                  (c[1] as num).toDouble(),
                  (c[0] as num).toDouble(),
                ))
            .toList();

        return _RouteData(
          coordinates: rawCoords,
          distanceKm: distKm,
          durationMinutes: durationMin,
        );
      }
    } catch (e) {
      debugPrint('Erreur OSRM: $e');
    }

    return _RouteData(
      coordinates: [start, end],
      isDirect: true,
    );
  }

  Future<void> _loadRoute() async {
    final mission = widget.mission;

    final startCoords = await _getCoordinates(
      mission.adresseDepart?.villeNom ?? '',
      latitude:  mission.adresseDepart?.latitude,
      longitude: mission.adresseDepart?.longitude,
    );

    await Future.delayed(const Duration(milliseconds: 100));

    final endCoords = await _getCoordinates(
      mission.adresseArrivee?.villeNom ?? '',
      latitude:  mission.adresseArrivee?.latitude,
      longitude: mission.adresseArrivee?.longitude,
    );

    if (!mounted) return;

    if (startCoords == null || endCoords == null) {
      setState(() {
        _error = 'Impossible de localiser '
            '${startCoords == null ? (mission.adresseDepart?.villeNom ?? "départ") : (mission.adresseArrivee?.villeNom ?? "arrivée")}';
        _loading = false;
      });
      return;
    }

    final routeData = await _fetchRoute(startCoords, endCoords);

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bounds = LatLngBounds.fromPoints([startCoords, endCoords]);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60),
        ),
      );
    });

    setState(() {
      _startCoords = startCoords;
      _endCoords   = endCoords;
      _routeData   = routeData;
      _routeStats  = _RouteStats(
        distanceKm: routeData.distanceKm ??
            (mission.calculs?.distanceKm ?? 0).toDouble(),
        durationMinutes: routeData.durationMinutes,
      );
      _loading = false;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final mission = widget.mission;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Erreur ────────────────────────────────────────────────────────
        if (_error != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline,
                    color: Color(0xFFDC2626), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Erreur de géocodage',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF991B1B),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // ── Stats route ────────────────────────────────────────────────────
        if (_routeStats != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFED7AA)),
            ),
            child: Row(
              children: [
                const Icon(Icons.navigation_rounded, color: _orange, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mission.adresseDepart?.villeNom ?? "?"} → ${mission.adresseArrivee?.villeNom ?? "?"}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '📏 ${_routeStats!.distanceKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              color: Color(0xFF92400E),
                              fontSize: 12,
                            ),
                          ),
                          if (_routeStats!.durationMinutes != null) ...[
                            const SizedBox(width: 16),
                            Text(
                              '⏱️ ${_routeStats!.durationMinutes! ~/ 60}h '
                              '${(_routeStats!.durationMinutes! % 60).toString().padLeft(2, '0')}min',
                              style: const TextStyle(
                                color: Color(0xFF92400E),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // ── Carte ──────────────────────────────────────────────────────────
        Container(
          height: 340,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFED7AA), width: 2),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  // ✅ FIX 3 — Centre Tunisie
                  initialCenter: _tunisieCenter,
                  initialZoom: 6,
                ),
                children: [
                  // ✅ FIX 1 — userAgentPackageName MoveCar
                  // ✅ FIX 2 — additionalOptions supprimé
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.movecar.app',
                  ),

                  if (_routeData != null &&
                      _routeData!.coordinates.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routeData!.coordinates,
                          color: _orange,
                          strokeWidth: 5,
                        ),
                      ],
                    ),

                  MarkerLayer(
                    markers: [
                      if (_startCoords != null)
                        Marker(
                          point: _startCoords!,
                          width: 44,
                          height: 44,
                          child: const _CircleMarker(
                            label: 'D',
                            color: _orange,
                          ),
                        ),
                      if (_endCoords != null)
                        Marker(
                          point: _endCoords!,
                          width: 44,
                          height: 44,
                          child: const _CircleMarker(
                            label: 'A',
                            color: _green,
                          ),
                        ),
                    ],
                  ),

                  const SimpleAttributionWidget(
                    source: Text(
                      '© OpenStreetMap contributors',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),

              // ✅ FIX 5 — withOpacity → withValues
              if (_loading)
                Container(
                  color: Colors.white.withValues(alpha: 0.92),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: _orange,
                          strokeWidth: 3,
                        ),
                        SizedBox(height: 14),
                        Text(
                          'Chargement de l\'itinéraire...',
                          style: TextStyle(
                            color: Color(0xFF1E293B),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Calcul du trajet en cours',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Marqueur cercle coloré (D / A)
// ─────────────────────────────────────────────────────────────────────────────

class _CircleMarker extends StatelessWidget {
  final String label;
  final Color color;

  const _CircleMarker({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
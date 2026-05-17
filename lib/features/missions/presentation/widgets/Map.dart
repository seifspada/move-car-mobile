import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ─────────────────────────────────────────────
// Data model — équivalent de MapPoint (TS)
// ─────────────────────────────────────────────
class MapPoint {
  final LatLng position;
  final double radius; // en mètres
  final Color color;
  final String? label;

  const MapPoint({
    required this.position,
    required this.radius,
    this.color = const Color(0xFFF97316), // orange par défaut
    this.label,
  });
}

// ─────────────────────────────────────────────
// MapComponent — widget principal
// ─────────────────────────────────────────────
class MapComponent extends StatefulWidget {
  /// Centre initial de la carte (optionnel).
  final LatLng? center;

  /// Rayon du cercle autour du centre (si points est null).
  final double? radius;

  /// Niveau de zoom initial.
  final double zoom;

  /// Liste de points à afficher (prioritaire sur center+radius).
  final List<MapPoint>? points;

  const MapComponent({
    super.key,
    this.center,
    this.radius,
    this.zoom = 5,
    this.points,
  });

  @override
  State<MapComponent> createState() => _MapComponentState();
}

class _MapComponentState extends State<MapComponent> {
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  // Calcule la liste effective de MapPoint (même logique que le composant React)
  List<MapPoint> get _resolvedPoints {
    if (widget.points != null && widget.points!.isNotEmpty) {
      return widget.points!;
    }
    if (widget.center != null && widget.radius != null) {
      return [
        MapPoint(
          position: widget.center!,
          radius: widget.radius!,
          color: const Color(0xFFF97316),
        ),
      ];
    }
    return [];
  }

  LatLng get _initialCenter =>
      widget.center ?? const LatLng(46.603354, 1.888334); // France par défaut

  @override
  void didUpdateWidget(MapComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reproduit le comportement flyTo quand center / zoom change
    if (widget.center != null &&
        (widget.center != oldWidget.center || widget.zoom != oldWidget.zoom)) {
      _mapController.move(widget.center!, widget.zoom);
    }

    // Reproduit le fitBounds quand plusieurs points sont fournis
    final pts = _resolvedPoints;
    if (pts.length > 1) {
      final bounds = LatLngBounds.fromPoints(pts.map((p) => p.position).toList());
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  // Icône bleue (départ) — équivalent customIcon
  Widget _defaultMarker() => const Icon(
        Icons.location_on,
        color: Color(0xFF2A81CB),
        size: 36,
      );

  // Icône verte (arrivée) — équivalent arrivalIcon
  Widget _arrivalMarker() => const Icon(
        Icons.location_on,
        color: Color(0xFF2AAD27),
        size: 36,
      );

  @override
  Widget build(BuildContext context) {
    final mapPoints = _resolvedPoints;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _initialCenter,
        initialZoom: widget.zoom,
      ),
      children: [
        // ── Tuile OpenStreetMap ──────────────────────────────────────
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
          // Attribution affichée en bas de carte
          additionalOptions: const {
            'attribution':
                '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
          },
        ),

        // ── Cercles ──────────────────────────────────────────────────
        CircleLayer(
          circles: mapPoints
              .map(
                (point) => CircleMarker(
                  point: point.position,
                  radius: point.radius,
                  useRadiusInMeter: true, // rayon en mètres (comme Leaflet)
                  color: point.color.withOpacity(0.15),
                  borderColor: point.color,
                  borderStrokeWidth: 1.5,
                ),
              )
              .toList(),
        ),

        // ── Marqueurs ────────────────────────────────────────────────
        MarkerLayer(
          markers: mapPoints
              .map(
                (point) => Marker(
                  point: point.position,
                  width: 36,
                  height: 36,
                  child: point.label == 'arrivée'
                      ? _arrivalMarker()
                      : _defaultMarker(),
                ),
              )
              .toList(),
        ),

        // ── Attribution (bonne pratique OSM) ─────────────────────────
        const SimpleAttributionWidget(
          source: Text('© OpenStreetMap contributors'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Exemple d'utilisation
// ─────────────────────────────────────────────
//
// // Un seul point (centre + rayon)
// MapComponent(
//   center: LatLng(48.8566, 2.3522),
//   radius: 5000,
//   zoom: 13,
// )
//
// // Plusieurs points
// MapComponent(
//   points: [
//     MapPoint(position: LatLng(48.8566, 2.3522), radius: 3000, label: 'départ'),
//     MapPoint(position: LatLng(48.9000, 2.4000), radius: 2000, label: 'arrivée'),
//   ],
// )
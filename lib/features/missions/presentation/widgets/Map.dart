import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ─────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────
class MapPoint {
  final LatLng position;
  final double radius; // en mètres
  final Color color;
  final String? label;

  const MapPoint({
    required this.position,
    required this.radius,
    this.color = const Color(0xFFF97316),
    this.label,
  });
}

// ─────────────────────────────────────────────
// MapComponent — widget principal
// ─────────────────────────────────────────────
class MapComponent extends StatefulWidget {
  final LatLng? center;
  final double? radius;
  final double zoom;
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

  // ✅ FIX 3 — Centre Tunisie par défaut
  LatLng get _initialCenter =>
      widget.center ?? const LatLng(33.8869, 9.5375);

  @override
  void didUpdateWidget(MapComponent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.center != null &&
        (widget.center != oldWidget.center || widget.zoom != oldWidget.zoom)) {
      _mapController.move(widget.center!, widget.zoom);
    }

    final pts = _resolvedPoints;
    if (pts.length > 1) {
      final bounds =
          LatLngBounds.fromPoints(pts.map((p) => p.position).toList());
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(50),
        ),
      );
    }
  }

  Widget _defaultMarker() => const Icon(
        Icons.location_on,
        color: Color(0xFF2A81CB),
        size: 36,
      );

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
        // ✅ FIX 1 — userAgentPackageName correct
        // ✅ FIX 2 — additionalOptions supprimé (API obsolète)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.movecar.app',
        ),

        CircleLayer(
          circles: mapPoints
              .map(
                (point) => CircleMarker(
                  point: point.position,
                  radius: point.radius,
                  useRadiusInMeter: true,
                  // ✅ FIX 4 — withOpacity → withValues
                  color: point.color.withValues(alpha: 0.15),
                  borderColor: point.color,
                  borderStrokeWidth: 1.5,
                ),
              )
              .toList(),
        ),

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

        const SimpleAttributionWidget(
          source: Text('© OpenStreetMap contributors'),
        ),
      ],
    );
  }
}
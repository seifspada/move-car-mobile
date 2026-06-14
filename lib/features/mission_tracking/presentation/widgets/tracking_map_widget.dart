
// lib/features/mission_tracking/presentation/widgets/tracking_map_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackingMapWidget extends StatelessWidget {
  // Historique GPS (chemin parcouru)
  final List<LatLng> polylinePoints;

  // ✅ NOUVEAU : route OSRM planifiée (de la position vers destination)
  final List<LatLng> routePolyline;

  final LatLng? currentPosition;
  final LatLng destinationPosition;
  final String villeArrivee;

  // ✅ NOUVEAU : chargement de la route en cours
  final bool routeLoading;

  const TrackingMapWidget({
    super.key,
    required this.polylinePoints,
    required this.routePolyline,
    this.currentPosition,
    required this.destinationPosition,
    required this.villeArrivee,
    this.routeLoading = false,
  });

  // Calcule les bounds pour afficher tout le trajet
  LatLngBounds? _computeBounds() {
    final points = <LatLng>[];
    if (currentPosition != null) points.add(currentPosition!);
    points.add(destinationPosition);
    if (points.length < 2) return null;
    return LatLngBounds.fromPoints(points);
  }

  @override
  Widget build(BuildContext context) {
    final center = currentPosition ?? destinationPosition;

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: center,
            initialZoom: 13,
          ),
          children: [
            // Tuiles OpenStreetMap
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.convoyeur_mobile',
            ),

            // ✅ NOUVEAU : Route planifiée OSRM (bleu vif, comme Google Maps)
            if (routePolyline.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePolyline,
                    color: const Color(0xFF4285F4),   // bleu Google Maps
                    strokeWidth: 6,
                    borderColor: Colors.white,
                    borderStrokeWidth: 2,
                  ),
                ],
              ),

            // Chemin parcouru (gris, en dessous)
            if (polylinePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints,
                    color: Colors.grey.shade400,
                    strokeWidth: 3,
                  ),
                ],
              ),

            // Marqueurs
            MarkerLayer(
              markers: [
                // ✅ Position actuelle : point bleu avec halo
                if (currentPosition != null)
                  Marker(
                    point: currentPosition!,
                    width: 48,
                    height: 48,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4285F4).withOpacity(0.2),
                          ),
                        ),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4285F4),
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4285F4).withOpacity(0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Destination : pin rouge
                Marker(
                  point: destinationPosition,
                  width: 48,
                  height: 60,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          villeArrivee,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 32,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // ✅ NOUVEAU : indicateur de chargement de la route
        if (routeLoading)
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Calcul de l\'itinéraire...',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
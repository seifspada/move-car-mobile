import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/service/routing_service.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/bottom_mission_nav_bar.dart';
import '../widgets/map_controls.dart';

class NavigationScreen extends StatefulWidget {
  final String villeDepart;
  final String villeArrivee;
  final LatLng positionDepart;
  final LatLng positionArrivee;

  const NavigationScreen({
    super.key,
    required this.villeDepart,
    required this.villeArrivee,
    required this.positionDepart,
    required this.positionArrivee,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  LatLng? _currentPosition;
  double _distanceKm = 0;
  int _dureeMinutes = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await RoutingService.getRoute(
      widget.positionDepart,
      widget.positionArrivee,
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _routePoints = result.points;
        _distanceKm = result.distanceKm;
        _dureeMinutes = result.dureeMinutes;
        _currentPosition = widget.positionDepart;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _error = 'Impossible de calculer l\'itinéraire.';
      });
    }
  }

  void _recenter() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 14.0);
    }
  }

  String get _heureArrivee {
    final now = DateTime.now().add(Duration(minutes: _dureeMinutes));
    return '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
  }

  void _signalerAlerte() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alerte signalée — l\'agent a été notifié'),
        backgroundColor: Color(0xFFF5A623),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Carte OSM ──────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.positionDepart,
              initialZoom: 13.0,
            ),
            children: [
              // ✅ FIX 1 — userAgentPackageName MoveCar (plus de com.example)
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.movecar.app',
              ),

              // Tracé de l'itinéraire (double polyline pour effet épaisseur)
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 8.0,
                      // ✅ FIX 2 — withOpacity → withValues
                      color: const Color(0xFF4444CC).withValues(alpha: 0.3),
                    ),
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 5.0,
                      color: const Color(0xFF4444CC),
                    ),
                  ],
                ),

              // Marqueurs
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      point: _currentPosition!,
                      width: 48,
                      height: 48,
                      child: _ConvoyeurMarker(),
                    ),
                  Marker(
                    point: widget.positionArrivee,
                    width: 48,
                    height: 56,
                    child: _DestinationMarker(ville: widget.villeArrivee),
                  ),
                ],
              ),
            ],
          ),

          // ── Top bar ────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: IconButton(
                      tooltip: 'Retour',
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      color: Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: TopNavBar(villeArrivee: widget.villeArrivee),
                  ),
                ],
              ),
            ),
          ),

          // ── Contrôles droite ───────────────────────────────
          Positioned(
            right: 12,
            top: MediaQuery.of(context).size.height * 0.35,
            child: MapControls(
              onAlerte: _signalerAlerte,
              onRecenter: _recenter,
            ),
          ),

          // ── Erreur ─────────────────────────────────────────
          if (_error != null)
            Center(
              child: Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 40),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loadRoute,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              ),
            ),

          // ── Loading ────────────────────────────────────────
          if (_isLoading)
            Container(
              // ✅ FIX 2 — withOpacity → withValues
              color: Colors.white.withValues(alpha: 0.6),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // ── Bottom bar ETA ─────────────────────────────────
          if (!_isLoading && _error == null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BottomMissionNavBar(
                distanceKm: _distanceKm,
                dureeMinutes: _dureeMinutes,
                heureArrivee: _heureArrivee,
                villeArrivee: widget.villeArrivee,
                onExit: () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Marqueur convoyeur ─────────────────────────────────────

class _ConvoyeurMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // ✅ FIX 2 — withOpacity → withValues
        color: Colors.white.withValues(alpha: 0.95),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF4444CC), width: 2.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6),
        ],
      ),
      child: const Icon(
        Icons.navigation,
        color: Color(0xFF4444CC),
        size: 26,
      ),
    );
  }
}

// ── Marqueur destination ───────────────────────────────────

class _DestinationMarker extends StatelessWidget {
  final String ville;
  const _DestinationMarker({required this.ville});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4),
            ],
          ),
          child: Text(
            ville,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const Icon(Icons.location_pin, color: Colors.red, size: 36),
      ],
    );
  }
}
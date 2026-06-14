// lib/features/mission_tracking/presentation/pages/mission_tracking_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

import '../../data/service/gps_background_service.dart';
import '../../../mission_session/presentation/providers/mission_session_providers.dart';
import '../providers/mission_tracking_providers.dart';
import '../widgets/tracking_map_widget.dart';
import '../widgets/gps_status_indicator.dart';
import '../widgets/arrival_banner.dart';
import '../widgets/incident_bottom_sheet.dart';
import '../widgets/bottom_mission_nav_bar.dart';

class MissionTrackingPage extends ConsumerStatefulWidget {
  final String missionId;
  final String sessionId;
  final String reservationId;
  final double latitudeArrivee;
  final double longitudeArrivee;
  final String villeArrivee;

  const MissionTrackingPage({
    super.key,
    required this.missionId,
    required this.sessionId,
    required this.reservationId,
    this.latitudeArrivee = 36.8189,
    this.longitudeArrivee = 10.1658,
    this.villeArrivee = 'Destination',
  });

  @override
  ConsumerState<MissionTrackingPage> createState() =>
      _MissionTrackingPageState();
}

class _MissionTrackingPageState extends ConsumerState<MissionTrackingPage> {
  @override
  void initState() {
    super.initState();
    _startTracking();
    _listenToBackground();
    // ✅ Initialiser la destination dans le provider
    Future.microtask(() {
      ref
          .read(missionTrackingProvider(widget.missionId).notifier)
          .setDestination(
            LatLng(widget.latitudeArrivee, widget.longitudeArrivee),
          );
    });
  }

  Future<void> _startTracking() async {
    await startMissionTracking(
      missionId: widget.missionId,
      sessionId: widget.sessionId,
    );
  }

  void _listenToBackground() {
    FlutterBackgroundService().on(kBgPositionUpdate).listen((data) {
      if (data == null) return;
      ref
          .read(missionTrackingProvider(widget.missionId).notifier)
          .onPositionReceived(
            missionId: data['missionId'],
            sessionId: data['sessionId'],
            latitude: (data['latitude'] as num).toDouble(),
            longitude: (data['longitude'] as num).toDouble(),
            accuracy: (data['accuracy'] as num?)?.toDouble(),
          );
    });
  }

  Future<void> _showIncidentSheet() async {
    final state = ref.read(missionTrackingProvider(widget.missionId));
    final pos = state.currentPosition;
    if (pos == null) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => IncidentBottomSheet(
        sessionId: widget.sessionId,
        latitude: pos.latitude,
        longitude: pos.longitude,
      ),
    );
  }

  Future<void> _completeMission() async {
    final state = ref.read(missionTrackingProvider(widget.missionId));
    final pos = state.currentPosition;
    if (pos == null) return;

    await stopMissionTracking();

    if (!mounted) return;

    final sessionProvider = missionSessionProvider(widget.reservationId);
    var session = ref.read(sessionProvider).session;
    if (session == null && widget.reservationId.isNotEmpty) {
      await ref
          .read(sessionProvider.notifier)
          .loadSession(widget.reservationId);
      if (!mounted) return;
      session = ref.read(sessionProvider).session;
    }
    if (session == null) return;

    context.pushReplacement(
      '/end_mission/${widget.reservationId}',
      extra: session,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(missionTrackingProvider(widget.missionId));
    final destination = LatLng(widget.latitudeArrivee, widget.longitudeArrivee);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Mission en cours'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GpsStatusIndicator(
              isActive: state.gpsActive,
              accuracy: null,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Bannière distance / arrivée ────────────────────
          if (state.villeArrivee.isNotEmpty)
            ArrivalBanner(
              distanceMetres: state.distanceMetres,
              villeArrivee: state.villeArrivee.isNotEmpty
                  ? state.villeArrivee
                  : widget.villeArrivee,
              isArrived: state.isArrived,
            ),

          // ── Carte ──────────────────────────────────────────
          Expanded(
            child: TrackingMapWidget(
              polylinePoints: state.polylinePoints,
              routePolyline: state.routePolyline,   // ✅ vraies données OSRM
              routeLoading: state.routeLoading,     // ✅ indicateur chargement
              currentPosition: state.currentPosition,
              destinationPosition: destination,
              villeArrivee: state.villeArrivee.isNotEmpty
                  ? state.villeArrivee
                  : widget.villeArrivee,
            ),
          ),

          // ── Card navigation (style Google Maps) ───────────
          BottomMissionNavBar(
            distanceKm: state.distanceMetres / 1000,
            dureeMinutes: state.dureeMinutes,
            heureArrivee: state.heureArrivee,
            villeArrivee: state.villeArrivee.isNotEmpty
                ? state.villeArrivee
                : widget.villeArrivee,
            onExit: _completeMission,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
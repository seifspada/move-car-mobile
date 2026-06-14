// lib/features/mission_tracking/presentation/providers/mission_tracking_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/usecases/update_location_usecase.dart';
import '../../domain/usecases/check_arrival_usecase.dart';
import '../../domain/usecases/complete_mission_usecase.dart';
import '../../data/repositories/mission_tracking_repository_impl.dart';
import '../../data/service/routing_service.dart';
import '../../../../core/network/graphql/graphql_client.dart';

// ── Repository & UseCases providers ──────────────────────

final missionTrackingRepositoryProvider = Provider((ref) {
  final client = ref.read(graphqlClientProvider);
  return MissionTrackingRepositoryImpl(client);
});

final updateLocationUseCaseProvider = Provider((ref) {
  return UpdateLocationUseCase(ref.read(missionTrackingRepositoryProvider));
});

final checkArrivalUseCaseProvider = Provider((ref) {
  return CheckArrivalUseCase(ref.read(missionTrackingRepositoryProvider));
});

final completeMissionUseCaseProvider = Provider((ref) {
  return CompleteMissionUseCase(ref.read(missionTrackingRepositoryProvider));
});

// ── État du tracking ──────────────────────────────────────

class MissionTrackingState {
  final List<LatLng> polylinePoints;    // historique GPS parcouru
  final List<LatLng> routePolyline;     // ✅ NOUVEAU : trajet OSRM planifié
  final LatLng? currentPosition;
  final bool isArrived;
  final int distanceMetres;
  final int dureeMinutes;             // ✅ NOUVEAU : durée estimée OSRM
  final String heureArrivee;          // ✅ NOUVEAU : heure d'arrivée calculée
  final String villeArrivee;
  final bool gpsActive;
  final bool isLoading;
  final bool routeLoading;             // ✅ NOUVEAU : chargement de la route
  final String? error;

  const MissionTrackingState({
    this.polylinePoints = const [],
    this.routePolyline = const [],
    this.currentPosition,
    this.isArrived = false,
    this.distanceMetres = 0,
    this.dureeMinutes = 0,
    this.heureArrivee = '',
    this.villeArrivee = '',
    this.gpsActive = false,
    this.isLoading = false,
    this.routeLoading = false,
    this.error,
  });

  MissionTrackingState copyWith({
    List<LatLng>? polylinePoints,
    List<LatLng>? routePolyline,
    LatLng? currentPosition,
    bool? isArrived,
    int? distanceMetres,
    int? dureeMinutes,
    String? heureArrivee,
    String? villeArrivee,
    bool? gpsActive,
    bool? isLoading,
    bool? routeLoading,
    String? error,
  }) {
    return MissionTrackingState(
      polylinePoints: polylinePoints ?? this.polylinePoints,
      routePolyline: routePolyline ?? this.routePolyline,
      currentPosition: currentPosition ?? this.currentPosition,
      isArrived: isArrived ?? this.isArrived,
      distanceMetres: distanceMetres ?? this.distanceMetres,
      dureeMinutes: dureeMinutes ?? this.dureeMinutes,
      heureArrivee: heureArrivee ?? this.heureArrivee,
      villeArrivee: villeArrivee ?? this.villeArrivee,
      gpsActive: gpsActive ?? this.gpsActive,
      isLoading: isLoading ?? this.isLoading,
      routeLoading: routeLoading ?? this.routeLoading,
      error: error,
    );
  }
}

class MissionTrackingNotifier extends StateNotifier<MissionTrackingState> {
  final UpdateLocationUseCase _updateLocation;
  final CheckArrivalUseCase _checkArrival;
  final CompleteMissionUseCase _completeMission;

  // ✅ NOUVEAU : destination mémorisée pour re-calculer la route
  LatLng? _destination;
  bool _routeFetched = false;

  MissionTrackingNotifier(
    this._updateLocation,
    this._checkArrival,
    this._completeMission,
  ) : super(const MissionTrackingState());

  // ✅ NOUVEAU : initialiser la destination depuis la page
  void setDestination(LatLng destination) {
    _destination = destination;
  }

  // ✅ NOUVEAU : calculer heure d'arrivée estimée
  String _calcHeureArrivee(int dureeMinutes) {
    final now = DateTime.now();
    final arrivee = now.add(Duration(minutes: dureeMinutes));
    final h = arrivee.hour.toString().padLeft(2, '0');
    final m = arrivee.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ✅ NOUVEAU : appel OSRM pour obtenir la vraie route
  Future<void> _fetchRoute(LatLng depart) async {
    if (_destination == null) return;
    state = state.copyWith(routeLoading: true);
    final result = await RoutingService.getRoute(depart, _destination!);
    if (result != null) {
      state = state.copyWith(
        routePolyline: result.points,
        dureeMinutes: result.dureeMinutes,
        heureArrivee: _calcHeureArrivee(result.dureeMinutes),
        routeLoading: false,
      );
    } else {
      state = state.copyWith(routeLoading: false);
    }
  }

  /// Appelé quand le background service envoie une position
  Future<void> onPositionReceived({
    required String missionId,
    required String sessionId,
    required double latitude,
    required double longitude,
    double? accuracy,
  }) async {
    final point = LatLng(latitude, longitude);

    state = state.copyWith(
      currentPosition: point,
      gpsActive: true,
      polylinePoints: [...state.polylinePoints, point],
    );

    // ✅ NOUVEAU : fetch la route OSRM la première fois seulement
    if (!_routeFetched) {
      _routeFetched = true;
      await _fetchRoute(point);
    } else {
      // ✅ NOUVEAU : mise à jour durée/heure toutes les 5 positions
      if (state.polylinePoints.length % 5 == 0) {
        await _fetchRoute(point);
      }
    }

    try {
      await _updateLocation(
        missionId: missionId,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
      );
    } catch (_) {}

    try {
      final arrival = await _checkArrival(
        sessionId: sessionId,
        latitude: latitude,
        longitude: longitude,
      );
      state = state.copyWith(
        isArrived: arrival.isArrived,
        distanceMetres: arrival.distanceMetres,
        villeArrivee: arrival.villeArrivee,
      );
    } catch (_) {}
  }

  Future<void> completeMission({
    required String missionId,
    required double latitudeFin,
    required double longitudeFin,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await _completeMission(
        missionId: missionId,
        latitudeFin: latitudeFin,
        longitudeFin: longitudeFin,
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setGpsActive(bool active) {
    state = state.copyWith(gpsActive: active);
  }
}

final missionTrackingProvider = StateNotifierProvider.autoDispose
    .family<MissionTrackingNotifier, MissionTrackingState, String>(
  (ref, missionId) => MissionTrackingNotifier(
    ref.read(updateLocationUseCaseProvider),
    ref.read(checkArrivalUseCaseProvider),
    ref.read(completeMissionUseCaseProvider),
  ),
);

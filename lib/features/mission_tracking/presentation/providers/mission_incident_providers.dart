import 'package:convoyeur_mobile/features/mission_tracking/presentation/providers/mission_tracking_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mission_incident_entity.dart';
import '../../domain/usecases/report_incident_usecase.dart';

final reportIncidentUseCaseProvider = Provider((ref) {
  final repo = ref.read(missionTrackingRepositoryProvider);
  return ReportIncidentUseCase(repo);
});

class IncidentState {
  final bool isSubmitting;
  final String? error;
  final bool isTimeout;          // ← nouveau
  final List<MissionIncidentEntity> incidents;

  const IncidentState({
    this.isSubmitting = false,
    this.error,
    this.isTimeout = false,
    this.incidents = const [],
  });

  IncidentState copyWith({
    bool? isSubmitting,
    String? error,
    bool? isTimeout,
    List<MissionIncidentEntity>? incidents,
  }) {
    return IncidentState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      isTimeout: isTimeout ?? false,
      incidents: incidents ?? this.incidents,
    );
  }
}

class IncidentNotifier extends StateNotifier<IncidentState> {
  final ReportIncidentUseCase _reportIncident;

  IncidentNotifier(this._reportIncident) : super(const IncidentState());

  Future<bool> report({
    required String sessionId,
    required String typeIncident,
    required String description,
    required double latitude,
    required double longitude,
    List<String>? photos,
    int maxRetries = 3,           // ← retry manuel
  }) async {
    state = state.copyWith(isSubmitting: true, error: null, isTimeout: false);

    int attempt = 0;

    while (attempt < maxRetries) {
      try {
        final incident = await _reportIncident(
          sessionId: sessionId,
          typeIncident: typeIncident,
          description: description,
          latitude: latitude,
          longitude: longitude,
          photos: photos,
        );

        state = state.copyWith(
          isSubmitting: false,
          incidents: [...state.incidents, incident],
        );
        return true;

      } catch (e) {
        attempt++;
        final isTimeout = e.toString().contains('TimeoutException') ||
            e.toString().contains('No stream event') ||
            e.toString().contains('Délai dépassé');

        // Si pas un timeout ou dernière tentative → on arrête
        if (!isTimeout || attempt >= maxRetries) {
          state = state.copyWith(
            isSubmitting: false,
            error: isTimeout
                ? 'Connexion trop lente. Vérifiez votre réseau et réessayez.'
                : e.toString(),
            isTimeout: isTimeout,
          );
          return false;
        }

        // Attendre avant retry (backoff exponentiel)
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    return false;
  }

  void clearError() => state = state.copyWith(error: null);
}

final incidentProvider = StateNotifierProvider.autoDispose
    .family<IncidentNotifier, IncidentState, String>(
  (ref, sessionId) => IncidentNotifier(ref.read(reportIncidentUseCaseProvider)),
);
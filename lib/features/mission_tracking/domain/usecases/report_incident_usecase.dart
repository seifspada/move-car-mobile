import '../repositories/mission_tracking_repository.dart';
import '../entities/mission_incident_entity.dart';

class ReportIncidentUseCase {
  final MissionTrackingRepository repository;
  ReportIncidentUseCase(this.repository);

  Future<MissionIncidentEntity> call({
    required String sessionId,
    required String typeIncident,
    required String description,
    required double latitude,
    required double longitude,
    List<String>? photos,
  }) {
    return repository.reportIncident(
      sessionId: sessionId,
      typeIncident: typeIncident,
      description: description,
      latitude: latitude,
      longitude: longitude,
      photos: photos,
    );
  }
}
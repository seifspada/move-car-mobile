import '../entities/mission_tracking_entity.dart';
import '../entities/mission_incident_entity.dart';

abstract class MissionTrackingRepository {
  Future<MissionTrackingEntity> updateLocation({
    required String missionId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
    required DateTime timestamp,
  });

  Future<ArrivalCheckEntity> checkArrival({
    required String sessionId,
    required double latitude,
    required double longitude,
  });

  Future<List<MissionTrackingEntity>> getTrackingHistory(String missionId);

  Future<MissionIncidentEntity> reportIncident({
    required String sessionId,
    required String typeIncident,
    required String description,
    required double latitude,
    required double longitude,
    List<String>? photos,
  });

  Future<void> completeMission({
    required String missionId,
    required double latitudeFin,
    required double longitudeFin,
  });
}

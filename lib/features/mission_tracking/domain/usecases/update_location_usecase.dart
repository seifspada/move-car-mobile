import '../repositories/mission_tracking_repository.dart';
import '../entities/mission_tracking_entity.dart';

class UpdateLocationUseCase {
  final MissionTrackingRepository repository;
  UpdateLocationUseCase(this.repository);

  Future<MissionTrackingEntity> call({
    required String missionId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? speed,
  }) {
    return repository.updateLocation(
      missionId: missionId,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      speed: speed,
      timestamp: DateTime.now(),
    );
  }
}

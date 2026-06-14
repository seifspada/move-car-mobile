import '../repositories/mission_tracking_repository.dart';
import '../entities/mission_tracking_entity.dart';

class CheckArrivalUseCase {
  final MissionTrackingRepository repository;
  CheckArrivalUseCase(this.repository);

  Future<ArrivalCheckEntity> call({
    required String sessionId,
    required double latitude,
    required double longitude,
  }) {
    return repository.checkArrival(
      sessionId: sessionId,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
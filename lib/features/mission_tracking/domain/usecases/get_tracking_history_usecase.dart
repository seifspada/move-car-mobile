import '../repositories/mission_tracking_repository.dart';
import '../entities/mission_tracking_entity.dart';

class GetTrackingHistoryUseCase {
  final MissionTrackingRepository repository;
  GetTrackingHistoryUseCase(this.repository);

  Future<List<MissionTrackingEntity>> call(String missionId) {
    return repository.getTrackingHistory(missionId);
  }
}
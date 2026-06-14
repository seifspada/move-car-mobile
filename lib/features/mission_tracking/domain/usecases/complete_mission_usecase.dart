import '../repositories/mission_tracking_repository.dart';

class CompleteMissionUseCase {
  final MissionTrackingRepository repository;
  CompleteMissionUseCase(this.repository);

  Future<void> call({
    required String missionId,
    required double latitudeFin,
    required double longitudeFin,
  }) {
    return repository.completeMission(
      missionId: missionId,
      latitudeFin: latitudeFin,
      longitudeFin: longitudeFin,
    );
  }
}
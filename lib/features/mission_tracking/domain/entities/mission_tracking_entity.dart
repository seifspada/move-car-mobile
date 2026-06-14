class MissionTrackingEntity {
  final String id;
  final String? sessionId;
  final String? missionId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;
  final bool isDeviated;
  final double? distanceFromRoute;

  const MissionTrackingEntity({
    required this.id,
    this.sessionId,
    this.missionId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
    required this.isDeviated,
    this.distanceFromRoute,
  });
}

class ArrivalCheckEntity {
  final bool isArrived;
  final int distanceMetres;
  final String villeArrivee;

  const ArrivalCheckEntity({
    required this.isArrived,
    required this.distanceMetres,
    required this.villeArrivee,
  });
}
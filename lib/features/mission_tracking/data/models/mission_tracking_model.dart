import 'package:freezed_annotation/freezed_annotation.dart';

part 'mission_tracking_model.freezed.dart';
part 'mission_tracking_model.g.dart';

@freezed
class MissionTrackingModel with _$MissionTrackingModel {
  const factory MissionTrackingModel({
    required String id,
    String? sessionId,
    String? missionId,
    required double latitude,
    required double longitude,
    double? accuracy,
    required DateTime timestamp,
    required bool isDeviated,
    double? distanceFromRoute,
  }) = _MissionTrackingModel;

  factory MissionTrackingModel.fromJson(Map<String, dynamic> json) =>
      _$MissionTrackingModelFromJson(json);
}

@freezed
class ArrivalCheckModel with _$ArrivalCheckModel {
  const factory ArrivalCheckModel({
    required bool isArrived,
    required int distanceMetres,
    required String villeArrivee,
  }) = _ArrivalCheckModel;

  factory ArrivalCheckModel.fromJson(Map<String, dynamic> json) =>
      _$ArrivalCheckModelFromJson(json);
}
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mission_incident_model.freezed.dart';
part 'mission_incident_model.g.dart';

@freezed
class MissionIncidentMediaModel with _$MissionIncidentMediaModel {
  const factory MissionIncidentMediaModel({
    required String id,
    required String incidentId,
    required String cheminFichier,
    required int tailleOctets,
    required int ordre,
    required DateTime dateCreation,
  }) = _MissionIncidentMediaModel;

  factory MissionIncidentMediaModel.fromJson(Map<String, dynamic> json) =>
      _$MissionIncidentMediaModelFromJson(json);
}

@freezed
class MissionIncidentModel with _$MissionIncidentModel {
  const factory MissionIncidentModel({
    required String id,
    required String sessionId,
    required String typeIncident,
    required String description,
    required double latitude,
    required double longitude,
    required List<MissionIncidentMediaModel> medias,
    String? resolvedBy,
    String? resolutionNotes,
    DateTime? dateResolution,
    required DateTime dateCreation,
  }) = _MissionIncidentModel;

  factory MissionIncidentModel.fromJson(Map<String, dynamic> json) =>
      _$MissionIncidentModelFromJson(json);
}
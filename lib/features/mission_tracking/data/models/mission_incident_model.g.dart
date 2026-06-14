// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_incident_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MissionIncidentMediaModelImpl _$$MissionIncidentMediaModelImplFromJson(
  Map<String, dynamic> json,
) => _$MissionIncidentMediaModelImpl(
  id: json['id'] as String,
  incidentId: json['incidentId'] as String,
  cheminFichier: json['cheminFichier'] as String,
  tailleOctets: (json['tailleOctets'] as num).toInt(),
  ordre: (json['ordre'] as num).toInt(),
  dateCreation: DateTime.parse(json['dateCreation'] as String),
);

Map<String, dynamic> _$$MissionIncidentMediaModelImplToJson(
  _$MissionIncidentMediaModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'incidentId': instance.incidentId,
  'cheminFichier': instance.cheminFichier,
  'tailleOctets': instance.tailleOctets,
  'ordre': instance.ordre,
  'dateCreation': instance.dateCreation.toIso8601String(),
};

_$MissionIncidentModelImpl _$$MissionIncidentModelImplFromJson(
  Map<String, dynamic> json,
) => _$MissionIncidentModelImpl(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String,
  typeIncident: json['typeIncident'] as String,
  description: json['description'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  medias: (json['medias'] as List<dynamic>)
      .map((e) => MissionIncidentMediaModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  resolvedBy: json['resolvedBy'] as String?,
  resolutionNotes: json['resolutionNotes'] as String?,
  dateResolution: json['dateResolution'] == null
      ? null
      : DateTime.parse(json['dateResolution'] as String),
  dateCreation: DateTime.parse(json['dateCreation'] as String),
);

Map<String, dynamic> _$$MissionIncidentModelImplToJson(
  _$MissionIncidentModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'typeIncident': instance.typeIncident,
  'description': instance.description,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'medias': instance.medias,
  'resolvedBy': instance.resolvedBy,
  'resolutionNotes': instance.resolutionNotes,
  'dateResolution': instance.dateResolution?.toIso8601String(),
  'dateCreation': instance.dateCreation.toIso8601String(),
};

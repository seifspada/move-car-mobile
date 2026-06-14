// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_tracking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MissionTrackingModelImpl _$$MissionTrackingModelImplFromJson(
  Map<String, dynamic> json,
) => _$MissionTrackingModelImpl(
  id: json['id'] as String,
  sessionId: json['sessionId'] as String?,
  missionId: json['missionId'] as String?,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  accuracy: (json['accuracy'] as num?)?.toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  isDeviated: json['isDeviated'] as bool,
  distanceFromRoute: (json['distanceFromRoute'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$MissionTrackingModelImplToJson(
  _$MissionTrackingModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'sessionId': instance.sessionId,
  'missionId': instance.missionId,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'accuracy': instance.accuracy,
  'timestamp': instance.timestamp.toIso8601String(),
  'isDeviated': instance.isDeviated,
  'distanceFromRoute': instance.distanceFromRoute,
};

_$ArrivalCheckModelImpl _$$ArrivalCheckModelImplFromJson(
  Map<String, dynamic> json,
) => _$ArrivalCheckModelImpl(
  isArrived: json['isArrived'] as bool,
  distanceMetres: (json['distanceMetres'] as num).toInt(),
  villeArrivee: json['villeArrivee'] as String,
);

Map<String, dynamic> _$$ArrivalCheckModelImplToJson(
  _$ArrivalCheckModelImpl instance,
) => <String, dynamic>{
  'isArrived': instance.isArrived,
  'distanceMetres': instance.distanceMetres,
  'villeArrivee': instance.villeArrivee,
};

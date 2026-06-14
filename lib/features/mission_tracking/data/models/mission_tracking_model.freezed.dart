// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_tracking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MissionTrackingModel _$MissionTrackingModelFromJson(Map<String, dynamic> json) {
  return _MissionTrackingModel.fromJson(json);
}

/// @nodoc
mixin _$MissionTrackingModel {
  String get id => throw _privateConstructorUsedError;
  String? get sessionId => throw _privateConstructorUsedError;
  String? get missionId => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  double? get accuracy => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get isDeviated => throw _privateConstructorUsedError;
  double? get distanceFromRoute => throw _privateConstructorUsedError;

  /// Serializes this MissionTrackingModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MissionTrackingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MissionTrackingModelCopyWith<MissionTrackingModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MissionTrackingModelCopyWith<$Res> {
  factory $MissionTrackingModelCopyWith(
    MissionTrackingModel value,
    $Res Function(MissionTrackingModel) then,
  ) = _$MissionTrackingModelCopyWithImpl<$Res, MissionTrackingModel>;
  @useResult
  $Res call({
    String id,
    String? sessionId,
    String? missionId,
    double latitude,
    double longitude,
    double? accuracy,
    DateTime timestamp,
    bool isDeviated,
    double? distanceFromRoute,
  });
}

/// @nodoc
class _$MissionTrackingModelCopyWithImpl<
  $Res,
  $Val extends MissionTrackingModel
>
    implements $MissionTrackingModelCopyWith<$Res> {
  _$MissionTrackingModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MissionTrackingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = freezed,
    Object? missionId = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracy = freezed,
    Object? timestamp = null,
    Object? isDeviated = null,
    Object? distanceFromRoute = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: freezed == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            missionId: freezed == missionId
                ? _value.missionId
                : missionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            accuracy: freezed == accuracy
                ? _value.accuracy
                : accuracy // ignore: cast_nullable_to_non_nullable
                      as double?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            isDeviated: null == isDeviated
                ? _value.isDeviated
                : isDeviated // ignore: cast_nullable_to_non_nullable
                      as bool,
            distanceFromRoute: freezed == distanceFromRoute
                ? _value.distanceFromRoute
                : distanceFromRoute // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MissionTrackingModelImplCopyWith<$Res>
    implements $MissionTrackingModelCopyWith<$Res> {
  factory _$$MissionTrackingModelImplCopyWith(
    _$MissionTrackingModelImpl value,
    $Res Function(_$MissionTrackingModelImpl) then,
  ) = __$$MissionTrackingModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? sessionId,
    String? missionId,
    double latitude,
    double longitude,
    double? accuracy,
    DateTime timestamp,
    bool isDeviated,
    double? distanceFromRoute,
  });
}

/// @nodoc
class __$$MissionTrackingModelImplCopyWithImpl<$Res>
    extends _$MissionTrackingModelCopyWithImpl<$Res, _$MissionTrackingModelImpl>
    implements _$$MissionTrackingModelImplCopyWith<$Res> {
  __$$MissionTrackingModelImplCopyWithImpl(
    _$MissionTrackingModelImpl _value,
    $Res Function(_$MissionTrackingModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MissionTrackingModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = freezed,
    Object? missionId = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? accuracy = freezed,
    Object? timestamp = null,
    Object? isDeviated = null,
    Object? distanceFromRoute = freezed,
  }) {
    return _then(
      _$MissionTrackingModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: freezed == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        missionId: freezed == missionId
            ? _value.missionId
            : missionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        accuracy: freezed == accuracy
            ? _value.accuracy
            : accuracy // ignore: cast_nullable_to_non_nullable
                  as double?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        isDeviated: null == isDeviated
            ? _value.isDeviated
            : isDeviated // ignore: cast_nullable_to_non_nullable
                  as bool,
        distanceFromRoute: freezed == distanceFromRoute
            ? _value.distanceFromRoute
            : distanceFromRoute // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MissionTrackingModelImpl implements _MissionTrackingModel {
  const _$MissionTrackingModelImpl({
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

  factory _$MissionTrackingModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MissionTrackingModelImplFromJson(json);

  @override
  final String id;
  @override
  final String? sessionId;
  @override
  final String? missionId;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final double? accuracy;
  @override
  final DateTime timestamp;
  @override
  final bool isDeviated;
  @override
  final double? distanceFromRoute;

  @override
  String toString() {
    return 'MissionTrackingModel(id: $id, sessionId: $sessionId, missionId: $missionId, latitude: $latitude, longitude: $longitude, accuracy: $accuracy, timestamp: $timestamp, isDeviated: $isDeviated, distanceFromRoute: $distanceFromRoute)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MissionTrackingModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.missionId, missionId) ||
                other.missionId == missionId) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.accuracy, accuracy) ||
                other.accuracy == accuracy) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isDeviated, isDeviated) ||
                other.isDeviated == isDeviated) &&
            (identical(other.distanceFromRoute, distanceFromRoute) ||
                other.distanceFromRoute == distanceFromRoute));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sessionId,
    missionId,
    latitude,
    longitude,
    accuracy,
    timestamp,
    isDeviated,
    distanceFromRoute,
  );

  /// Create a copy of MissionTrackingModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MissionTrackingModelImplCopyWith<_$MissionTrackingModelImpl>
  get copyWith =>
      __$$MissionTrackingModelImplCopyWithImpl<_$MissionTrackingModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MissionTrackingModelImplToJson(this);
  }
}

abstract class _MissionTrackingModel implements MissionTrackingModel {
  const factory _MissionTrackingModel({
    required final String id,
    final String? sessionId,
    final String? missionId,
    required final double latitude,
    required final double longitude,
    final double? accuracy,
    required final DateTime timestamp,
    required final bool isDeviated,
    final double? distanceFromRoute,
  }) = _$MissionTrackingModelImpl;

  factory _MissionTrackingModel.fromJson(Map<String, dynamic> json) =
      _$MissionTrackingModelImpl.fromJson;

  @override
  String get id;
  @override
  String? get sessionId;
  @override
  String? get missionId;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  double? get accuracy;
  @override
  DateTime get timestamp;
  @override
  bool get isDeviated;
  @override
  double? get distanceFromRoute;

  /// Create a copy of MissionTrackingModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MissionTrackingModelImplCopyWith<_$MissionTrackingModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

ArrivalCheckModel _$ArrivalCheckModelFromJson(Map<String, dynamic> json) {
  return _ArrivalCheckModel.fromJson(json);
}

/// @nodoc
mixin _$ArrivalCheckModel {
  bool get isArrived => throw _privateConstructorUsedError;
  int get distanceMetres => throw _privateConstructorUsedError;
  String get villeArrivee => throw _privateConstructorUsedError;

  /// Serializes this ArrivalCheckModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ArrivalCheckModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArrivalCheckModelCopyWith<ArrivalCheckModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArrivalCheckModelCopyWith<$Res> {
  factory $ArrivalCheckModelCopyWith(
    ArrivalCheckModel value,
    $Res Function(ArrivalCheckModel) then,
  ) = _$ArrivalCheckModelCopyWithImpl<$Res, ArrivalCheckModel>;
  @useResult
  $Res call({bool isArrived, int distanceMetres, String villeArrivee});
}

/// @nodoc
class _$ArrivalCheckModelCopyWithImpl<$Res, $Val extends ArrivalCheckModel>
    implements $ArrivalCheckModelCopyWith<$Res> {
  _$ArrivalCheckModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArrivalCheckModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isArrived = null,
    Object? distanceMetres = null,
    Object? villeArrivee = null,
  }) {
    return _then(
      _value.copyWith(
            isArrived: null == isArrived
                ? _value.isArrived
                : isArrived // ignore: cast_nullable_to_non_nullable
                      as bool,
            distanceMetres: null == distanceMetres
                ? _value.distanceMetres
                : distanceMetres // ignore: cast_nullable_to_non_nullable
                      as int,
            villeArrivee: null == villeArrivee
                ? _value.villeArrivee
                : villeArrivee // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ArrivalCheckModelImplCopyWith<$Res>
    implements $ArrivalCheckModelCopyWith<$Res> {
  factory _$$ArrivalCheckModelImplCopyWith(
    _$ArrivalCheckModelImpl value,
    $Res Function(_$ArrivalCheckModelImpl) then,
  ) = __$$ArrivalCheckModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isArrived, int distanceMetres, String villeArrivee});
}

/// @nodoc
class __$$ArrivalCheckModelImplCopyWithImpl<$Res>
    extends _$ArrivalCheckModelCopyWithImpl<$Res, _$ArrivalCheckModelImpl>
    implements _$$ArrivalCheckModelImplCopyWith<$Res> {
  __$$ArrivalCheckModelImplCopyWithImpl(
    _$ArrivalCheckModelImpl _value,
    $Res Function(_$ArrivalCheckModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ArrivalCheckModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isArrived = null,
    Object? distanceMetres = null,
    Object? villeArrivee = null,
  }) {
    return _then(
      _$ArrivalCheckModelImpl(
        isArrived: null == isArrived
            ? _value.isArrived
            : isArrived // ignore: cast_nullable_to_non_nullable
                  as bool,
        distanceMetres: null == distanceMetres
            ? _value.distanceMetres
            : distanceMetres // ignore: cast_nullable_to_non_nullable
                  as int,
        villeArrivee: null == villeArrivee
            ? _value.villeArrivee
            : villeArrivee // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ArrivalCheckModelImpl implements _ArrivalCheckModel {
  const _$ArrivalCheckModelImpl({
    required this.isArrived,
    required this.distanceMetres,
    required this.villeArrivee,
  });

  factory _$ArrivalCheckModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArrivalCheckModelImplFromJson(json);

  @override
  final bool isArrived;
  @override
  final int distanceMetres;
  @override
  final String villeArrivee;

  @override
  String toString() {
    return 'ArrivalCheckModel(isArrived: $isArrived, distanceMetres: $distanceMetres, villeArrivee: $villeArrivee)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArrivalCheckModelImpl &&
            (identical(other.isArrived, isArrived) ||
                other.isArrived == isArrived) &&
            (identical(other.distanceMetres, distanceMetres) ||
                other.distanceMetres == distanceMetres) &&
            (identical(other.villeArrivee, villeArrivee) ||
                other.villeArrivee == villeArrivee));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, isArrived, distanceMetres, villeArrivee);

  /// Create a copy of ArrivalCheckModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArrivalCheckModelImplCopyWith<_$ArrivalCheckModelImpl> get copyWith =>
      __$$ArrivalCheckModelImplCopyWithImpl<_$ArrivalCheckModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ArrivalCheckModelImplToJson(this);
  }
}

abstract class _ArrivalCheckModel implements ArrivalCheckModel {
  const factory _ArrivalCheckModel({
    required final bool isArrived,
    required final int distanceMetres,
    required final String villeArrivee,
  }) = _$ArrivalCheckModelImpl;

  factory _ArrivalCheckModel.fromJson(Map<String, dynamic> json) =
      _$ArrivalCheckModelImpl.fromJson;

  @override
  bool get isArrived;
  @override
  int get distanceMetres;
  @override
  String get villeArrivee;

  /// Create a copy of ArrivalCheckModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArrivalCheckModelImplCopyWith<_$ArrivalCheckModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

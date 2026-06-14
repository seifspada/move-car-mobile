// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mission_incident_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MissionIncidentMediaModel _$MissionIncidentMediaModelFromJson(
  Map<String, dynamic> json,
) {
  return _MissionIncidentMediaModel.fromJson(json);
}

/// @nodoc
mixin _$MissionIncidentMediaModel {
  String get id => throw _privateConstructorUsedError;
  String get incidentId => throw _privateConstructorUsedError;
  String get cheminFichier => throw _privateConstructorUsedError;
  int get tailleOctets => throw _privateConstructorUsedError;
  int get ordre => throw _privateConstructorUsedError;
  DateTime get dateCreation => throw _privateConstructorUsedError;

  /// Serializes this MissionIncidentMediaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MissionIncidentMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MissionIncidentMediaModelCopyWith<MissionIncidentMediaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MissionIncidentMediaModelCopyWith<$Res> {
  factory $MissionIncidentMediaModelCopyWith(
    MissionIncidentMediaModel value,
    $Res Function(MissionIncidentMediaModel) then,
  ) = _$MissionIncidentMediaModelCopyWithImpl<$Res, MissionIncidentMediaModel>;
  @useResult
  $Res call({
    String id,
    String incidentId,
    String cheminFichier,
    int tailleOctets,
    int ordre,
    DateTime dateCreation,
  });
}

/// @nodoc
class _$MissionIncidentMediaModelCopyWithImpl<
  $Res,
  $Val extends MissionIncidentMediaModel
>
    implements $MissionIncidentMediaModelCopyWith<$Res> {
  _$MissionIncidentMediaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MissionIncidentMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? incidentId = null,
    Object? cheminFichier = null,
    Object? tailleOctets = null,
    Object? ordre = null,
    Object? dateCreation = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            incidentId: null == incidentId
                ? _value.incidentId
                : incidentId // ignore: cast_nullable_to_non_nullable
                      as String,
            cheminFichier: null == cheminFichier
                ? _value.cheminFichier
                : cheminFichier // ignore: cast_nullable_to_non_nullable
                      as String,
            tailleOctets: null == tailleOctets
                ? _value.tailleOctets
                : tailleOctets // ignore: cast_nullable_to_non_nullable
                      as int,
            ordre: null == ordre
                ? _value.ordre
                : ordre // ignore: cast_nullable_to_non_nullable
                      as int,
            dateCreation: null == dateCreation
                ? _value.dateCreation
                : dateCreation // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MissionIncidentMediaModelImplCopyWith<$Res>
    implements $MissionIncidentMediaModelCopyWith<$Res> {
  factory _$$MissionIncidentMediaModelImplCopyWith(
    _$MissionIncidentMediaModelImpl value,
    $Res Function(_$MissionIncidentMediaModelImpl) then,
  ) = __$$MissionIncidentMediaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String incidentId,
    String cheminFichier,
    int tailleOctets,
    int ordre,
    DateTime dateCreation,
  });
}

/// @nodoc
class __$$MissionIncidentMediaModelImplCopyWithImpl<$Res>
    extends
        _$MissionIncidentMediaModelCopyWithImpl<
          $Res,
          _$MissionIncidentMediaModelImpl
        >
    implements _$$MissionIncidentMediaModelImplCopyWith<$Res> {
  __$$MissionIncidentMediaModelImplCopyWithImpl(
    _$MissionIncidentMediaModelImpl _value,
    $Res Function(_$MissionIncidentMediaModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MissionIncidentMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? incidentId = null,
    Object? cheminFichier = null,
    Object? tailleOctets = null,
    Object? ordre = null,
    Object? dateCreation = null,
  }) {
    return _then(
      _$MissionIncidentMediaModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        incidentId: null == incidentId
            ? _value.incidentId
            : incidentId // ignore: cast_nullable_to_non_nullable
                  as String,
        cheminFichier: null == cheminFichier
            ? _value.cheminFichier
            : cheminFichier // ignore: cast_nullable_to_non_nullable
                  as String,
        tailleOctets: null == tailleOctets
            ? _value.tailleOctets
            : tailleOctets // ignore: cast_nullable_to_non_nullable
                  as int,
        ordre: null == ordre
            ? _value.ordre
            : ordre // ignore: cast_nullable_to_non_nullable
                  as int,
        dateCreation: null == dateCreation
            ? _value.dateCreation
            : dateCreation // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MissionIncidentMediaModelImpl implements _MissionIncidentMediaModel {
  const _$MissionIncidentMediaModelImpl({
    required this.id,
    required this.incidentId,
    required this.cheminFichier,
    required this.tailleOctets,
    required this.ordre,
    required this.dateCreation,
  });

  factory _$MissionIncidentMediaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MissionIncidentMediaModelImplFromJson(json);

  @override
  final String id;
  @override
  final String incidentId;
  @override
  final String cheminFichier;
  @override
  final int tailleOctets;
  @override
  final int ordre;
  @override
  final DateTime dateCreation;

  @override
  String toString() {
    return 'MissionIncidentMediaModel(id: $id, incidentId: $incidentId, cheminFichier: $cheminFichier, tailleOctets: $tailleOctets, ordre: $ordre, dateCreation: $dateCreation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MissionIncidentMediaModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.incidentId, incidentId) ||
                other.incidentId == incidentId) &&
            (identical(other.cheminFichier, cheminFichier) ||
                other.cheminFichier == cheminFichier) &&
            (identical(other.tailleOctets, tailleOctets) ||
                other.tailleOctets == tailleOctets) &&
            (identical(other.ordre, ordre) || other.ordre == ordre) &&
            (identical(other.dateCreation, dateCreation) ||
                other.dateCreation == dateCreation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    incidentId,
    cheminFichier,
    tailleOctets,
    ordre,
    dateCreation,
  );

  /// Create a copy of MissionIncidentMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MissionIncidentMediaModelImplCopyWith<_$MissionIncidentMediaModelImpl>
  get copyWith =>
      __$$MissionIncidentMediaModelImplCopyWithImpl<
        _$MissionIncidentMediaModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MissionIncidentMediaModelImplToJson(this);
  }
}

abstract class _MissionIncidentMediaModel implements MissionIncidentMediaModel {
  const factory _MissionIncidentMediaModel({
    required final String id,
    required final String incidentId,
    required final String cheminFichier,
    required final int tailleOctets,
    required final int ordre,
    required final DateTime dateCreation,
  }) = _$MissionIncidentMediaModelImpl;

  factory _MissionIncidentMediaModel.fromJson(Map<String, dynamic> json) =
      _$MissionIncidentMediaModelImpl.fromJson;

  @override
  String get id;
  @override
  String get incidentId;
  @override
  String get cheminFichier;
  @override
  int get tailleOctets;
  @override
  int get ordre;
  @override
  DateTime get dateCreation;

  /// Create a copy of MissionIncidentMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MissionIncidentMediaModelImplCopyWith<_$MissionIncidentMediaModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

MissionIncidentModel _$MissionIncidentModelFromJson(Map<String, dynamic> json) {
  return _MissionIncidentModel.fromJson(json);
}

/// @nodoc
mixin _$MissionIncidentModel {
  String get id => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  String get typeIncident => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  List<MissionIncidentMediaModel> get medias =>
      throw _privateConstructorUsedError;
  String? get resolvedBy => throw _privateConstructorUsedError;
  String? get resolutionNotes => throw _privateConstructorUsedError;
  DateTime? get dateResolution => throw _privateConstructorUsedError;
  DateTime get dateCreation => throw _privateConstructorUsedError;

  /// Serializes this MissionIncidentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MissionIncidentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MissionIncidentModelCopyWith<MissionIncidentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MissionIncidentModelCopyWith<$Res> {
  factory $MissionIncidentModelCopyWith(
    MissionIncidentModel value,
    $Res Function(MissionIncidentModel) then,
  ) = _$MissionIncidentModelCopyWithImpl<$Res, MissionIncidentModel>;
  @useResult
  $Res call({
    String id,
    String sessionId,
    String typeIncident,
    String description,
    double latitude,
    double longitude,
    List<MissionIncidentMediaModel> medias,
    String? resolvedBy,
    String? resolutionNotes,
    DateTime? dateResolution,
    DateTime dateCreation,
  });
}

/// @nodoc
class _$MissionIncidentModelCopyWithImpl<
  $Res,
  $Val extends MissionIncidentModel
>
    implements $MissionIncidentModelCopyWith<$Res> {
  _$MissionIncidentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MissionIncidentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? typeIncident = null,
    Object? description = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? medias = null,
    Object? resolvedBy = freezed,
    Object? resolutionNotes = freezed,
    Object? dateResolution = freezed,
    Object? dateCreation = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sessionId: null == sessionId
                ? _value.sessionId
                : sessionId // ignore: cast_nullable_to_non_nullable
                      as String,
            typeIncident: null == typeIncident
                ? _value.typeIncident
                : typeIncident // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            medias: null == medias
                ? _value.medias
                : medias // ignore: cast_nullable_to_non_nullable
                      as List<MissionIncidentMediaModel>,
            resolvedBy: freezed == resolvedBy
                ? _value.resolvedBy
                : resolvedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            resolutionNotes: freezed == resolutionNotes
                ? _value.resolutionNotes
                : resolutionNotes // ignore: cast_nullable_to_non_nullable
                      as String?,
            dateResolution: freezed == dateResolution
                ? _value.dateResolution
                : dateResolution // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            dateCreation: null == dateCreation
                ? _value.dateCreation
                : dateCreation // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MissionIncidentModelImplCopyWith<$Res>
    implements $MissionIncidentModelCopyWith<$Res> {
  factory _$$MissionIncidentModelImplCopyWith(
    _$MissionIncidentModelImpl value,
    $Res Function(_$MissionIncidentModelImpl) then,
  ) = __$$MissionIncidentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String sessionId,
    String typeIncident,
    String description,
    double latitude,
    double longitude,
    List<MissionIncidentMediaModel> medias,
    String? resolvedBy,
    String? resolutionNotes,
    DateTime? dateResolution,
    DateTime dateCreation,
  });
}

/// @nodoc
class __$$MissionIncidentModelImplCopyWithImpl<$Res>
    extends _$MissionIncidentModelCopyWithImpl<$Res, _$MissionIncidentModelImpl>
    implements _$$MissionIncidentModelImplCopyWith<$Res> {
  __$$MissionIncidentModelImplCopyWithImpl(
    _$MissionIncidentModelImpl _value,
    $Res Function(_$MissionIncidentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MissionIncidentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sessionId = null,
    Object? typeIncident = null,
    Object? description = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? medias = null,
    Object? resolvedBy = freezed,
    Object? resolutionNotes = freezed,
    Object? dateResolution = freezed,
    Object? dateCreation = null,
  }) {
    return _then(
      _$MissionIncidentModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sessionId: null == sessionId
            ? _value.sessionId
            : sessionId // ignore: cast_nullable_to_non_nullable
                  as String,
        typeIncident: null == typeIncident
            ? _value.typeIncident
            : typeIncident // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        medias: null == medias
            ? _value._medias
            : medias // ignore: cast_nullable_to_non_nullable
                  as List<MissionIncidentMediaModel>,
        resolvedBy: freezed == resolvedBy
            ? _value.resolvedBy
            : resolvedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        resolutionNotes: freezed == resolutionNotes
            ? _value.resolutionNotes
            : resolutionNotes // ignore: cast_nullable_to_non_nullable
                  as String?,
        dateResolution: freezed == dateResolution
            ? _value.dateResolution
            : dateResolution // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        dateCreation: null == dateCreation
            ? _value.dateCreation
            : dateCreation // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MissionIncidentModelImpl implements _MissionIncidentModel {
  const _$MissionIncidentModelImpl({
    required this.id,
    required this.sessionId,
    required this.typeIncident,
    required this.description,
    required this.latitude,
    required this.longitude,
    required final List<MissionIncidentMediaModel> medias,
    this.resolvedBy,
    this.resolutionNotes,
    this.dateResolution,
    required this.dateCreation,
  }) : _medias = medias;

  factory _$MissionIncidentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MissionIncidentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String sessionId;
  @override
  final String typeIncident;
  @override
  final String description;
  @override
  final double latitude;
  @override
  final double longitude;
  final List<MissionIncidentMediaModel> _medias;
  @override
  List<MissionIncidentMediaModel> get medias {
    if (_medias is EqualUnmodifiableListView) return _medias;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_medias);
  }

  @override
  final String? resolvedBy;
  @override
  final String? resolutionNotes;
  @override
  final DateTime? dateResolution;
  @override
  final DateTime dateCreation;

  @override
  String toString() {
    return 'MissionIncidentModel(id: $id, sessionId: $sessionId, typeIncident: $typeIncident, description: $description, latitude: $latitude, longitude: $longitude, medias: $medias, resolvedBy: $resolvedBy, resolutionNotes: $resolutionNotes, dateResolution: $dateResolution, dateCreation: $dateCreation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MissionIncidentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.typeIncident, typeIncident) ||
                other.typeIncident == typeIncident) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            const DeepCollectionEquality().equals(other._medias, _medias) &&
            (identical(other.resolvedBy, resolvedBy) ||
                other.resolvedBy == resolvedBy) &&
            (identical(other.resolutionNotes, resolutionNotes) ||
                other.resolutionNotes == resolutionNotes) &&
            (identical(other.dateResolution, dateResolution) ||
                other.dateResolution == dateResolution) &&
            (identical(other.dateCreation, dateCreation) ||
                other.dateCreation == dateCreation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sessionId,
    typeIncident,
    description,
    latitude,
    longitude,
    const DeepCollectionEquality().hash(_medias),
    resolvedBy,
    resolutionNotes,
    dateResolution,
    dateCreation,
  );

  /// Create a copy of MissionIncidentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MissionIncidentModelImplCopyWith<_$MissionIncidentModelImpl>
  get copyWith =>
      __$$MissionIncidentModelImplCopyWithImpl<_$MissionIncidentModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MissionIncidentModelImplToJson(this);
  }
}

abstract class _MissionIncidentModel implements MissionIncidentModel {
  const factory _MissionIncidentModel({
    required final String id,
    required final String sessionId,
    required final String typeIncident,
    required final String description,
    required final double latitude,
    required final double longitude,
    required final List<MissionIncidentMediaModel> medias,
    final String? resolvedBy,
    final String? resolutionNotes,
    final DateTime? dateResolution,
    required final DateTime dateCreation,
  }) = _$MissionIncidentModelImpl;

  factory _MissionIncidentModel.fromJson(Map<String, dynamic> json) =
      _$MissionIncidentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get sessionId;
  @override
  String get typeIncident;
  @override
  String get description;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  List<MissionIncidentMediaModel> get medias;
  @override
  String? get resolvedBy;
  @override
  String? get resolutionNotes;
  @override
  DateTime? get dateResolution;
  @override
  DateTime get dateCreation;

  /// Create a copy of MissionIncidentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MissionIncidentModelImplCopyWith<_$MissionIncidentModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

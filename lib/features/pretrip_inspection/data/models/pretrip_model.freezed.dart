// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pretrip_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PreTripInspectionModel _$PreTripInspectionModelFromJson(
  Map<String, dynamic> json,
) {
  return _PreTripInspectionModel.fromJson(json);
}

/// @nodoc
mixin _$PreTripInspectionModel {
  String get id => throw _privateConstructorUsedError;
  String get reservationId => throw _privateConstructorUsedError;
  int get adherentId => throw _privateConstructorUsedError;
  StatutPreTrip get statut => throw _privateConstructorUsedError;
  EtapeInspection get etapeCourante => throw _privateConstructorUsedError;
  double? get latitudeDebut => throw _privateConstructorUsedError;
  double? get longitudeDebut => throw _privateConstructorUsedError;
  double? get latitudeFin => throw _privateConstructorUsedError;
  double? get longitudeFin => throw _privateConstructorUsedError;
  DateTime get dateDebut => throw _privateConstructorUsedError;
  DateTime? get dateValidation => throw _privateConstructorUsedError;
  String? get motifRejet => throw _privateConstructorUsedError;
  int get nombreMediasUploades => throw _privateConstructorUsedError;
  bool get peutEtreValidee => throw _privateConstructorUsedError;
  List<PreTripMediaModel> get medias => throw _privateConstructorUsedError;
  PreTripConsentModel? get consent => throw _privateConstructorUsedError;

  /// Serializes this PreTripInspectionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PreTripInspectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PreTripInspectionModelCopyWith<PreTripInspectionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreTripInspectionModelCopyWith<$Res> {
  factory $PreTripInspectionModelCopyWith(
    PreTripInspectionModel value,
    $Res Function(PreTripInspectionModel) then,
  ) = _$PreTripInspectionModelCopyWithImpl<$Res, PreTripInspectionModel>;
  @useResult
  $Res call({
    String id,
    String reservationId,
    int adherentId,
    StatutPreTrip statut,
    EtapeInspection etapeCourante,
    double? latitudeDebut,
    double? longitudeDebut,
    double? latitudeFin,
    double? longitudeFin,
    DateTime dateDebut,
    DateTime? dateValidation,
    String? motifRejet,
    int nombreMediasUploades,
    bool peutEtreValidee,
    List<PreTripMediaModel> medias,
    PreTripConsentModel? consent,
  });

  $PreTripConsentModelCopyWith<$Res>? get consent;
}

/// @nodoc
class _$PreTripInspectionModelCopyWithImpl<
  $Res,
  $Val extends PreTripInspectionModel
>
    implements $PreTripInspectionModelCopyWith<$Res> {
  _$PreTripInspectionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PreTripInspectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reservationId = null,
    Object? adherentId = null,
    Object? statut = null,
    Object? etapeCourante = null,
    Object? latitudeDebut = freezed,
    Object? longitudeDebut = freezed,
    Object? latitudeFin = freezed,
    Object? longitudeFin = freezed,
    Object? dateDebut = null,
    Object? dateValidation = freezed,
    Object? motifRejet = freezed,
    Object? nombreMediasUploades = null,
    Object? peutEtreValidee = null,
    Object? medias = null,
    Object? consent = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            reservationId: null == reservationId
                ? _value.reservationId
                : reservationId // ignore: cast_nullable_to_non_nullable
                      as String,
            adherentId: null == adherentId
                ? _value.adherentId
                : adherentId // ignore: cast_nullable_to_non_nullable
                      as int,
            statut: null == statut
                ? _value.statut
                : statut // ignore: cast_nullable_to_non_nullable
                      as StatutPreTrip,
            etapeCourante: null == etapeCourante
                ? _value.etapeCourante
                : etapeCourante // ignore: cast_nullable_to_non_nullable
                      as EtapeInspection,
            latitudeDebut: freezed == latitudeDebut
                ? _value.latitudeDebut
                : latitudeDebut // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitudeDebut: freezed == longitudeDebut
                ? _value.longitudeDebut
                : longitudeDebut // ignore: cast_nullable_to_non_nullable
                      as double?,
            latitudeFin: freezed == latitudeFin
                ? _value.latitudeFin
                : latitudeFin // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitudeFin: freezed == longitudeFin
                ? _value.longitudeFin
                : longitudeFin // ignore: cast_nullable_to_non_nullable
                      as double?,
            dateDebut: null == dateDebut
                ? _value.dateDebut
                : dateDebut // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dateValidation: freezed == dateValidation
                ? _value.dateValidation
                : dateValidation // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            motifRejet: freezed == motifRejet
                ? _value.motifRejet
                : motifRejet // ignore: cast_nullable_to_non_nullable
                      as String?,
            nombreMediasUploades: null == nombreMediasUploades
                ? _value.nombreMediasUploades
                : nombreMediasUploades // ignore: cast_nullable_to_non_nullable
                      as int,
            peutEtreValidee: null == peutEtreValidee
                ? _value.peutEtreValidee
                : peutEtreValidee // ignore: cast_nullable_to_non_nullable
                      as bool,
            medias: null == medias
                ? _value.medias
                : medias // ignore: cast_nullable_to_non_nullable
                      as List<PreTripMediaModel>,
            consent: freezed == consent
                ? _value.consent
                : consent // ignore: cast_nullable_to_non_nullable
                      as PreTripConsentModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of PreTripInspectionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PreTripConsentModelCopyWith<$Res>? get consent {
    if (_value.consent == null) {
      return null;
    }

    return $PreTripConsentModelCopyWith<$Res>(_value.consent!, (value) {
      return _then(_value.copyWith(consent: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PreTripInspectionModelImplCopyWith<$Res>
    implements $PreTripInspectionModelCopyWith<$Res> {
  factory _$$PreTripInspectionModelImplCopyWith(
    _$PreTripInspectionModelImpl value,
    $Res Function(_$PreTripInspectionModelImpl) then,
  ) = __$$PreTripInspectionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String reservationId,
    int adherentId,
    StatutPreTrip statut,
    EtapeInspection etapeCourante,
    double? latitudeDebut,
    double? longitudeDebut,
    double? latitudeFin,
    double? longitudeFin,
    DateTime dateDebut,
    DateTime? dateValidation,
    String? motifRejet,
    int nombreMediasUploades,
    bool peutEtreValidee,
    List<PreTripMediaModel> medias,
    PreTripConsentModel? consent,
  });

  @override
  $PreTripConsentModelCopyWith<$Res>? get consent;
}

/// @nodoc
class __$$PreTripInspectionModelImplCopyWithImpl<$Res>
    extends
        _$PreTripInspectionModelCopyWithImpl<$Res, _$PreTripInspectionModelImpl>
    implements _$$PreTripInspectionModelImplCopyWith<$Res> {
  __$$PreTripInspectionModelImplCopyWithImpl(
    _$PreTripInspectionModelImpl _value,
    $Res Function(_$PreTripInspectionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PreTripInspectionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reservationId = null,
    Object? adherentId = null,
    Object? statut = null,
    Object? etapeCourante = null,
    Object? latitudeDebut = freezed,
    Object? longitudeDebut = freezed,
    Object? latitudeFin = freezed,
    Object? longitudeFin = freezed,
    Object? dateDebut = null,
    Object? dateValidation = freezed,
    Object? motifRejet = freezed,
    Object? nombreMediasUploades = null,
    Object? peutEtreValidee = null,
    Object? medias = null,
    Object? consent = freezed,
  }) {
    return _then(
      _$PreTripInspectionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        reservationId: null == reservationId
            ? _value.reservationId
            : reservationId // ignore: cast_nullable_to_non_nullable
                  as String,
        adherentId: null == adherentId
            ? _value.adherentId
            : adherentId // ignore: cast_nullable_to_non_nullable
                  as int,
        statut: null == statut
            ? _value.statut
            : statut // ignore: cast_nullable_to_non_nullable
                  as StatutPreTrip,
        etapeCourante: null == etapeCourante
            ? _value.etapeCourante
            : etapeCourante // ignore: cast_nullable_to_non_nullable
                  as EtapeInspection,
        latitudeDebut: freezed == latitudeDebut
            ? _value.latitudeDebut
            : latitudeDebut // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitudeDebut: freezed == longitudeDebut
            ? _value.longitudeDebut
            : longitudeDebut // ignore: cast_nullable_to_non_nullable
                  as double?,
        latitudeFin: freezed == latitudeFin
            ? _value.latitudeFin
            : latitudeFin // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitudeFin: freezed == longitudeFin
            ? _value.longitudeFin
            : longitudeFin // ignore: cast_nullable_to_non_nullable
                  as double?,
        dateDebut: null == dateDebut
            ? _value.dateDebut
            : dateDebut // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dateValidation: freezed == dateValidation
            ? _value.dateValidation
            : dateValidation // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        motifRejet: freezed == motifRejet
            ? _value.motifRejet
            : motifRejet // ignore: cast_nullable_to_non_nullable
                  as String?,
        nombreMediasUploades: null == nombreMediasUploades
            ? _value.nombreMediasUploades
            : nombreMediasUploades // ignore: cast_nullable_to_non_nullable
                  as int,
        peutEtreValidee: null == peutEtreValidee
            ? _value.peutEtreValidee
            : peutEtreValidee // ignore: cast_nullable_to_non_nullable
                  as bool,
        medias: null == medias
            ? _value._medias
            : medias // ignore: cast_nullable_to_non_nullable
                  as List<PreTripMediaModel>,
        consent: freezed == consent
            ? _value.consent
            : consent // ignore: cast_nullable_to_non_nullable
                  as PreTripConsentModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PreTripInspectionModelImpl implements _PreTripInspectionModel {
  const _$PreTripInspectionModelImpl({
    required this.id,
    required this.reservationId,
    required this.adherentId,
    required this.statut,
    required this.etapeCourante,
    this.latitudeDebut,
    this.longitudeDebut,
    this.latitudeFin,
    this.longitudeFin,
    required this.dateDebut,
    this.dateValidation,
    this.motifRejet,
    this.nombreMediasUploades = 0,
    this.peutEtreValidee = false,
    final List<PreTripMediaModel> medias = const [],
    this.consent,
  }) : _medias = medias;

  factory _$PreTripInspectionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreTripInspectionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String reservationId;
  @override
  final int adherentId;
  @override
  final StatutPreTrip statut;
  @override
  final EtapeInspection etapeCourante;
  @override
  final double? latitudeDebut;
  @override
  final double? longitudeDebut;
  @override
  final double? latitudeFin;
  @override
  final double? longitudeFin;
  @override
  final DateTime dateDebut;
  @override
  final DateTime? dateValidation;
  @override
  final String? motifRejet;
  @override
  @JsonKey()
  final int nombreMediasUploades;
  @override
  @JsonKey()
  final bool peutEtreValidee;
  final List<PreTripMediaModel> _medias;
  @override
  @JsonKey()
  List<PreTripMediaModel> get medias {
    if (_medias is EqualUnmodifiableListView) return _medias;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_medias);
  }

  @override
  final PreTripConsentModel? consent;

  @override
  String toString() {
    return 'PreTripInspectionModel(id: $id, reservationId: $reservationId, adherentId: $adherentId, statut: $statut, etapeCourante: $etapeCourante, latitudeDebut: $latitudeDebut, longitudeDebut: $longitudeDebut, latitudeFin: $latitudeFin, longitudeFin: $longitudeFin, dateDebut: $dateDebut, dateValidation: $dateValidation, motifRejet: $motifRejet, nombreMediasUploades: $nombreMediasUploades, peutEtreValidee: $peutEtreValidee, medias: $medias, consent: $consent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreTripInspectionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reservationId, reservationId) ||
                other.reservationId == reservationId) &&
            (identical(other.adherentId, adherentId) ||
                other.adherentId == adherentId) &&
            (identical(other.statut, statut) || other.statut == statut) &&
            (identical(other.etapeCourante, etapeCourante) ||
                other.etapeCourante == etapeCourante) &&
            (identical(other.latitudeDebut, latitudeDebut) ||
                other.latitudeDebut == latitudeDebut) &&
            (identical(other.longitudeDebut, longitudeDebut) ||
                other.longitudeDebut == longitudeDebut) &&
            (identical(other.latitudeFin, latitudeFin) ||
                other.latitudeFin == latitudeFin) &&
            (identical(other.longitudeFin, longitudeFin) ||
                other.longitudeFin == longitudeFin) &&
            (identical(other.dateDebut, dateDebut) ||
                other.dateDebut == dateDebut) &&
            (identical(other.dateValidation, dateValidation) ||
                other.dateValidation == dateValidation) &&
            (identical(other.motifRejet, motifRejet) ||
                other.motifRejet == motifRejet) &&
            (identical(other.nombreMediasUploades, nombreMediasUploades) ||
                other.nombreMediasUploades == nombreMediasUploades) &&
            (identical(other.peutEtreValidee, peutEtreValidee) ||
                other.peutEtreValidee == peutEtreValidee) &&
            const DeepCollectionEquality().equals(other._medias, _medias) &&
            (identical(other.consent, consent) || other.consent == consent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    reservationId,
    adherentId,
    statut,
    etapeCourante,
    latitudeDebut,
    longitudeDebut,
    latitudeFin,
    longitudeFin,
    dateDebut,
    dateValidation,
    motifRejet,
    nombreMediasUploades,
    peutEtreValidee,
    const DeepCollectionEquality().hash(_medias),
    consent,
  );

  /// Create a copy of PreTripInspectionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreTripInspectionModelImplCopyWith<_$PreTripInspectionModelImpl>
  get copyWith =>
      __$$PreTripInspectionModelImplCopyWithImpl<_$PreTripInspectionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PreTripInspectionModelImplToJson(this);
  }
}

abstract class _PreTripInspectionModel implements PreTripInspectionModel {
  const factory _PreTripInspectionModel({
    required final String id,
    required final String reservationId,
    required final int adherentId,
    required final StatutPreTrip statut,
    required final EtapeInspection etapeCourante,
    final double? latitudeDebut,
    final double? longitudeDebut,
    final double? latitudeFin,
    final double? longitudeFin,
    required final DateTime dateDebut,
    final DateTime? dateValidation,
    final String? motifRejet,
    final int nombreMediasUploades,
    final bool peutEtreValidee,
    final List<PreTripMediaModel> medias,
    final PreTripConsentModel? consent,
  }) = _$PreTripInspectionModelImpl;

  factory _PreTripInspectionModel.fromJson(Map<String, dynamic> json) =
      _$PreTripInspectionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get reservationId;
  @override
  int get adherentId;
  @override
  StatutPreTrip get statut;
  @override
  EtapeInspection get etapeCourante;
  @override
  double? get latitudeDebut;
  @override
  double? get longitudeDebut;
  @override
  double? get latitudeFin;
  @override
  double? get longitudeFin;
  @override
  DateTime get dateDebut;
  @override
  DateTime? get dateValidation;
  @override
  String? get motifRejet;
  @override
  int get nombreMediasUploades;
  @override
  bool get peutEtreValidee;
  @override
  List<PreTripMediaModel> get medias;
  @override
  PreTripConsentModel? get consent;

  /// Create a copy of PreTripInspectionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreTripInspectionModelImplCopyWith<_$PreTripInspectionModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

PreTripMediaModel _$PreTripMediaModelFromJson(Map<String, dynamic> json) {
  return _PreTripMediaModel.fromJson(json);
}

/// @nodoc
mixin _$PreTripMediaModel {
  String get id => throw _privateConstructorUsedError;
  String get inspectionId => throw _privateConstructorUsedError;
  TypeMediaInspection get typeMedia => throw _privateConstructorUsedError;
  String get cheminFichier => throw _privateConstructorUsedError;
  String get mimeType => throw _privateConstructorUsedError;
  int get tailleFichier => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  double? get precisionGps => throw _privateConstructorUsedError;
  DateTime get timestampPhoto => throw _privateConstructorUsedError;
  bool get validatedByServer => throw _privateConstructorUsedError;
  DateTime get dateUpload => throw _privateConstructorUsedError;

  /// Serializes this PreTripMediaModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PreTripMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PreTripMediaModelCopyWith<PreTripMediaModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreTripMediaModelCopyWith<$Res> {
  factory $PreTripMediaModelCopyWith(
    PreTripMediaModel value,
    $Res Function(PreTripMediaModel) then,
  ) = _$PreTripMediaModelCopyWithImpl<$Res, PreTripMediaModel>;
  @useResult
  $Res call({
    String id,
    String inspectionId,
    TypeMediaInspection typeMedia,
    String cheminFichier,
    String mimeType,
    int tailleFichier,
    double latitude,
    double longitude,
    double? precisionGps,
    DateTime timestampPhoto,
    bool validatedByServer,
    DateTime dateUpload,
  });
}

/// @nodoc
class _$PreTripMediaModelCopyWithImpl<$Res, $Val extends PreTripMediaModel>
    implements $PreTripMediaModelCopyWith<$Res> {
  _$PreTripMediaModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PreTripMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? inspectionId = null,
    Object? typeMedia = null,
    Object? cheminFichier = null,
    Object? mimeType = null,
    Object? tailleFichier = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? precisionGps = freezed,
    Object? timestampPhoto = null,
    Object? validatedByServer = null,
    Object? dateUpload = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            inspectionId: null == inspectionId
                ? _value.inspectionId
                : inspectionId // ignore: cast_nullable_to_non_nullable
                      as String,
            typeMedia: null == typeMedia
                ? _value.typeMedia
                : typeMedia // ignore: cast_nullable_to_non_nullable
                      as TypeMediaInspection,
            cheminFichier: null == cheminFichier
                ? _value.cheminFichier
                : cheminFichier // ignore: cast_nullable_to_non_nullable
                      as String,
            mimeType: null == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String,
            tailleFichier: null == tailleFichier
                ? _value.tailleFichier
                : tailleFichier // ignore: cast_nullable_to_non_nullable
                      as int,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            precisionGps: freezed == precisionGps
                ? _value.precisionGps
                : precisionGps // ignore: cast_nullable_to_non_nullable
                      as double?,
            timestampPhoto: null == timestampPhoto
                ? _value.timestampPhoto
                : timestampPhoto // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            validatedByServer: null == validatedByServer
                ? _value.validatedByServer
                : validatedByServer // ignore: cast_nullable_to_non_nullable
                      as bool,
            dateUpload: null == dateUpload
                ? _value.dateUpload
                : dateUpload // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PreTripMediaModelImplCopyWith<$Res>
    implements $PreTripMediaModelCopyWith<$Res> {
  factory _$$PreTripMediaModelImplCopyWith(
    _$PreTripMediaModelImpl value,
    $Res Function(_$PreTripMediaModelImpl) then,
  ) = __$$PreTripMediaModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String inspectionId,
    TypeMediaInspection typeMedia,
    String cheminFichier,
    String mimeType,
    int tailleFichier,
    double latitude,
    double longitude,
    double? precisionGps,
    DateTime timestampPhoto,
    bool validatedByServer,
    DateTime dateUpload,
  });
}

/// @nodoc
class __$$PreTripMediaModelImplCopyWithImpl<$Res>
    extends _$PreTripMediaModelCopyWithImpl<$Res, _$PreTripMediaModelImpl>
    implements _$$PreTripMediaModelImplCopyWith<$Res> {
  __$$PreTripMediaModelImplCopyWithImpl(
    _$PreTripMediaModelImpl _value,
    $Res Function(_$PreTripMediaModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PreTripMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? inspectionId = null,
    Object? typeMedia = null,
    Object? cheminFichier = null,
    Object? mimeType = null,
    Object? tailleFichier = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? precisionGps = freezed,
    Object? timestampPhoto = null,
    Object? validatedByServer = null,
    Object? dateUpload = null,
  }) {
    return _then(
      _$PreTripMediaModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        inspectionId: null == inspectionId
            ? _value.inspectionId
            : inspectionId // ignore: cast_nullable_to_non_nullable
                  as String,
        typeMedia: null == typeMedia
            ? _value.typeMedia
            : typeMedia // ignore: cast_nullable_to_non_nullable
                  as TypeMediaInspection,
        cheminFichier: null == cheminFichier
            ? _value.cheminFichier
            : cheminFichier // ignore: cast_nullable_to_non_nullable
                  as String,
        mimeType: null == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String,
        tailleFichier: null == tailleFichier
            ? _value.tailleFichier
            : tailleFichier // ignore: cast_nullable_to_non_nullable
                  as int,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        precisionGps: freezed == precisionGps
            ? _value.precisionGps
            : precisionGps // ignore: cast_nullable_to_non_nullable
                  as double?,
        timestampPhoto: null == timestampPhoto
            ? _value.timestampPhoto
            : timestampPhoto // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        validatedByServer: null == validatedByServer
            ? _value.validatedByServer
            : validatedByServer // ignore: cast_nullable_to_non_nullable
                  as bool,
        dateUpload: null == dateUpload
            ? _value.dateUpload
            : dateUpload // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PreTripMediaModelImpl implements _PreTripMediaModel {
  const _$PreTripMediaModelImpl({
    required this.id,
    required this.inspectionId,
    required this.typeMedia,
    required this.cheminFichier,
    required this.mimeType,
    required this.tailleFichier,
    required this.latitude,
    required this.longitude,
    this.precisionGps,
    required this.timestampPhoto,
    required this.validatedByServer,
    required this.dateUpload,
  });

  factory _$PreTripMediaModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreTripMediaModelImplFromJson(json);

  @override
  final String id;
  @override
  final String inspectionId;
  @override
  final TypeMediaInspection typeMedia;
  @override
  final String cheminFichier;
  @override
  final String mimeType;
  @override
  final int tailleFichier;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final double? precisionGps;
  @override
  final DateTime timestampPhoto;
  @override
  final bool validatedByServer;
  @override
  final DateTime dateUpload;

  @override
  String toString() {
    return 'PreTripMediaModel(id: $id, inspectionId: $inspectionId, typeMedia: $typeMedia, cheminFichier: $cheminFichier, mimeType: $mimeType, tailleFichier: $tailleFichier, latitude: $latitude, longitude: $longitude, precisionGps: $precisionGps, timestampPhoto: $timestampPhoto, validatedByServer: $validatedByServer, dateUpload: $dateUpload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreTripMediaModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.inspectionId, inspectionId) ||
                other.inspectionId == inspectionId) &&
            (identical(other.typeMedia, typeMedia) ||
                other.typeMedia == typeMedia) &&
            (identical(other.cheminFichier, cheminFichier) ||
                other.cheminFichier == cheminFichier) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.tailleFichier, tailleFichier) ||
                other.tailleFichier == tailleFichier) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.precisionGps, precisionGps) ||
                other.precisionGps == precisionGps) &&
            (identical(other.timestampPhoto, timestampPhoto) ||
                other.timestampPhoto == timestampPhoto) &&
            (identical(other.validatedByServer, validatedByServer) ||
                other.validatedByServer == validatedByServer) &&
            (identical(other.dateUpload, dateUpload) ||
                other.dateUpload == dateUpload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    inspectionId,
    typeMedia,
    cheminFichier,
    mimeType,
    tailleFichier,
    latitude,
    longitude,
    precisionGps,
    timestampPhoto,
    validatedByServer,
    dateUpload,
  );

  /// Create a copy of PreTripMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreTripMediaModelImplCopyWith<_$PreTripMediaModelImpl> get copyWith =>
      __$$PreTripMediaModelImplCopyWithImpl<_$PreTripMediaModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PreTripMediaModelImplToJson(this);
  }
}

abstract class _PreTripMediaModel implements PreTripMediaModel {
  const factory _PreTripMediaModel({
    required final String id,
    required final String inspectionId,
    required final TypeMediaInspection typeMedia,
    required final String cheminFichier,
    required final String mimeType,
    required final int tailleFichier,
    required final double latitude,
    required final double longitude,
    final double? precisionGps,
    required final DateTime timestampPhoto,
    required final bool validatedByServer,
    required final DateTime dateUpload,
  }) = _$PreTripMediaModelImpl;

  factory _PreTripMediaModel.fromJson(Map<String, dynamic> json) =
      _$PreTripMediaModelImpl.fromJson;

  @override
  String get id;
  @override
  String get inspectionId;
  @override
  TypeMediaInspection get typeMedia;
  @override
  String get cheminFichier;
  @override
  String get mimeType;
  @override
  int get tailleFichier;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  double? get precisionGps;
  @override
  DateTime get timestampPhoto;
  @override
  bool get validatedByServer;
  @override
  DateTime get dateUpload;

  /// Create a copy of PreTripMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreTripMediaModelImplCopyWith<_$PreTripMediaModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PreTripConsentModel _$PreTripConsentModelFromJson(Map<String, dynamic> json) {
  return _PreTripConsentModel.fromJson(json);
}

/// @nodoc
mixin _$PreTripConsentModel {
  String get id => throw _privateConstructorUsedError;
  String get inspectionId => throw _privateConstructorUsedError;
  String get versionConditions => throw _privateConstructorUsedError;
  Map<String, dynamic> get clausesAcceptees =>
      throw _privateConstructorUsedError;
  DateTime get dateAcceptation => throw _privateConstructorUsedError;
  String? get ipAdresse => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;

  /// Serializes this PreTripConsentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PreTripConsentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PreTripConsentModelCopyWith<PreTripConsentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreTripConsentModelCopyWith<$Res> {
  factory $PreTripConsentModelCopyWith(
    PreTripConsentModel value,
    $Res Function(PreTripConsentModel) then,
  ) = _$PreTripConsentModelCopyWithImpl<$Res, PreTripConsentModel>;
  @useResult
  $Res call({
    String id,
    String inspectionId,
    String versionConditions,
    Map<String, dynamic> clausesAcceptees,
    DateTime dateAcceptation,
    String? ipAdresse,
    double? latitude,
    double? longitude,
  });
}

/// @nodoc
class _$PreTripConsentModelCopyWithImpl<$Res, $Val extends PreTripConsentModel>
    implements $PreTripConsentModelCopyWith<$Res> {
  _$PreTripConsentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PreTripConsentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? inspectionId = null,
    Object? versionConditions = null,
    Object? clausesAcceptees = null,
    Object? dateAcceptation = null,
    Object? ipAdresse = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            inspectionId: null == inspectionId
                ? _value.inspectionId
                : inspectionId // ignore: cast_nullable_to_non_nullable
                      as String,
            versionConditions: null == versionConditions
                ? _value.versionConditions
                : versionConditions // ignore: cast_nullable_to_non_nullable
                      as String,
            clausesAcceptees: null == clausesAcceptees
                ? _value.clausesAcceptees
                : clausesAcceptees // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            dateAcceptation: null == dateAcceptation
                ? _value.dateAcceptation
                : dateAcceptation // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ipAdresse: freezed == ipAdresse
                ? _value.ipAdresse
                : ipAdresse // ignore: cast_nullable_to_non_nullable
                      as String?,
            latitude: freezed == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double?,
            longitude: freezed == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PreTripConsentModelImplCopyWith<$Res>
    implements $PreTripConsentModelCopyWith<$Res> {
  factory _$$PreTripConsentModelImplCopyWith(
    _$PreTripConsentModelImpl value,
    $Res Function(_$PreTripConsentModelImpl) then,
  ) = __$$PreTripConsentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String inspectionId,
    String versionConditions,
    Map<String, dynamic> clausesAcceptees,
    DateTime dateAcceptation,
    String? ipAdresse,
    double? latitude,
    double? longitude,
  });
}

/// @nodoc
class __$$PreTripConsentModelImplCopyWithImpl<$Res>
    extends _$PreTripConsentModelCopyWithImpl<$Res, _$PreTripConsentModelImpl>
    implements _$$PreTripConsentModelImplCopyWith<$Res> {
  __$$PreTripConsentModelImplCopyWithImpl(
    _$PreTripConsentModelImpl _value,
    $Res Function(_$PreTripConsentModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PreTripConsentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? inspectionId = null,
    Object? versionConditions = null,
    Object? clausesAcceptees = null,
    Object? dateAcceptation = null,
    Object? ipAdresse = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
  }) {
    return _then(
      _$PreTripConsentModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        inspectionId: null == inspectionId
            ? _value.inspectionId
            : inspectionId // ignore: cast_nullable_to_non_nullable
                  as String,
        versionConditions: null == versionConditions
            ? _value.versionConditions
            : versionConditions // ignore: cast_nullable_to_non_nullable
                  as String,
        clausesAcceptees: null == clausesAcceptees
            ? _value._clausesAcceptees
            : clausesAcceptees // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        dateAcceptation: null == dateAcceptation
            ? _value.dateAcceptation
            : dateAcceptation // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ipAdresse: freezed == ipAdresse
            ? _value.ipAdresse
            : ipAdresse // ignore: cast_nullable_to_non_nullable
                  as String?,
        latitude: freezed == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double?,
        longitude: freezed == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PreTripConsentModelImpl implements _PreTripConsentModel {
  const _$PreTripConsentModelImpl({
    required this.id,
    required this.inspectionId,
    required this.versionConditions,
    required final Map<String, dynamic> clausesAcceptees,
    required this.dateAcceptation,
    this.ipAdresse,
    this.latitude,
    this.longitude,
  }) : _clausesAcceptees = clausesAcceptees;

  factory _$PreTripConsentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreTripConsentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String inspectionId;
  @override
  final String versionConditions;
  final Map<String, dynamic> _clausesAcceptees;
  @override
  Map<String, dynamic> get clausesAcceptees {
    if (_clausesAcceptees is EqualUnmodifiableMapView) return _clausesAcceptees;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_clausesAcceptees);
  }

  @override
  final DateTime dateAcceptation;
  @override
  final String? ipAdresse;
  @override
  final double? latitude;
  @override
  final double? longitude;

  @override
  String toString() {
    return 'PreTripConsentModel(id: $id, inspectionId: $inspectionId, versionConditions: $versionConditions, clausesAcceptees: $clausesAcceptees, dateAcceptation: $dateAcceptation, ipAdresse: $ipAdresse, latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreTripConsentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.inspectionId, inspectionId) ||
                other.inspectionId == inspectionId) &&
            (identical(other.versionConditions, versionConditions) ||
                other.versionConditions == versionConditions) &&
            const DeepCollectionEquality().equals(
              other._clausesAcceptees,
              _clausesAcceptees,
            ) &&
            (identical(other.dateAcceptation, dateAcceptation) ||
                other.dateAcceptation == dateAcceptation) &&
            (identical(other.ipAdresse, ipAdresse) ||
                other.ipAdresse == ipAdresse) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    inspectionId,
    versionConditions,
    const DeepCollectionEquality().hash(_clausesAcceptees),
    dateAcceptation,
    ipAdresse,
    latitude,
    longitude,
  );

  /// Create a copy of PreTripConsentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PreTripConsentModelImplCopyWith<_$PreTripConsentModelImpl> get copyWith =>
      __$$PreTripConsentModelImplCopyWithImpl<_$PreTripConsentModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PreTripConsentModelImplToJson(this);
  }
}

abstract class _PreTripConsentModel implements PreTripConsentModel {
  const factory _PreTripConsentModel({
    required final String id,
    required final String inspectionId,
    required final String versionConditions,
    required final Map<String, dynamic> clausesAcceptees,
    required final DateTime dateAcceptation,
    final String? ipAdresse,
    final double? latitude,
    final double? longitude,
  }) = _$PreTripConsentModelImpl;

  factory _PreTripConsentModel.fromJson(Map<String, dynamic> json) =
      _$PreTripConsentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get inspectionId;
  @override
  String get versionConditions;
  @override
  Map<String, dynamic> get clausesAcceptees;
  @override
  DateTime get dateAcceptation;
  @override
  String? get ipAdresse;
  @override
  double? get latitude;
  @override
  double? get longitude;

  /// Create a copy of PreTripConsentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PreTripConsentModelImplCopyWith<_$PreTripConsentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ValidationResultModel _$ValidationResultModelFromJson(
  Map<String, dynamic> json,
) {
  return _ValidationResultModel.fromJson(json);
}

/// @nodoc
mixin _$ValidationResultModel {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<String>? get reasons => throw _privateConstructorUsedError;
  String? get missionId => throw _privateConstructorUsedError;
  PreTripInspectionModel? get inspection => throw _privateConstructorUsedError;

  /// Serializes this ValidationResultModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ValidationResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ValidationResultModelCopyWith<ValidationResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidationResultModelCopyWith<$Res> {
  factory $ValidationResultModelCopyWith(
    ValidationResultModel value,
    $Res Function(ValidationResultModel) then,
  ) = _$ValidationResultModelCopyWithImpl<$Res, ValidationResultModel>;
  @useResult
  $Res call({
    bool success,
    String message,
    List<String>? reasons,
    String? missionId,
    PreTripInspectionModel? inspection,
  });

  $PreTripInspectionModelCopyWith<$Res>? get inspection;
}

/// @nodoc
class _$ValidationResultModelCopyWithImpl<
  $Res,
  $Val extends ValidationResultModel
>
    implements $ValidationResultModelCopyWith<$Res> {
  _$ValidationResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ValidationResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? reasons = freezed,
    Object? missionId = freezed,
    Object? inspection = freezed,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            reasons: freezed == reasons
                ? _value.reasons
                : reasons // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            missionId: freezed == missionId
                ? _value.missionId
                : missionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            inspection: freezed == inspection
                ? _value.inspection
                : inspection // ignore: cast_nullable_to_non_nullable
                      as PreTripInspectionModel?,
          )
          as $Val,
    );
  }

  /// Create a copy of ValidationResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PreTripInspectionModelCopyWith<$Res>? get inspection {
    if (_value.inspection == null) {
      return null;
    }

    return $PreTripInspectionModelCopyWith<$Res>(_value.inspection!, (value) {
      return _then(_value.copyWith(inspection: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ValidationResultModelImplCopyWith<$Res>
    implements $ValidationResultModelCopyWith<$Res> {
  factory _$$ValidationResultModelImplCopyWith(
    _$ValidationResultModelImpl value,
    $Res Function(_$ValidationResultModelImpl) then,
  ) = __$$ValidationResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    String message,
    List<String>? reasons,
    String? missionId,
    PreTripInspectionModel? inspection,
  });

  @override
  $PreTripInspectionModelCopyWith<$Res>? get inspection;
}

/// @nodoc
class __$$ValidationResultModelImplCopyWithImpl<$Res>
    extends
        _$ValidationResultModelCopyWithImpl<$Res, _$ValidationResultModelImpl>
    implements _$$ValidationResultModelImplCopyWith<$Res> {
  __$$ValidationResultModelImplCopyWithImpl(
    _$ValidationResultModelImpl _value,
    $Res Function(_$ValidationResultModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ValidationResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? reasons = freezed,
    Object? missionId = freezed,
    Object? inspection = freezed,
  }) {
    return _then(
      _$ValidationResultModelImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        reasons: freezed == reasons
            ? _value._reasons
            : reasons // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        missionId: freezed == missionId
            ? _value.missionId
            : missionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        inspection: freezed == inspection
            ? _value.inspection
            : inspection // ignore: cast_nullable_to_non_nullable
                  as PreTripInspectionModel?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidationResultModelImpl implements _ValidationResultModel {
  const _$ValidationResultModelImpl({
    required this.success,
    required this.message,
    final List<String>? reasons,
    this.missionId,
    this.inspection,
  }) : _reasons = reasons;

  factory _$ValidationResultModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ValidationResultModelImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  final List<String>? _reasons;
  @override
  List<String>? get reasons {
    final value = _reasons;
    if (value == null) return null;
    if (_reasons is EqualUnmodifiableListView) return _reasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? missionId;
  @override
  final PreTripInspectionModel? inspection;

  @override
  String toString() {
    return 'ValidationResultModel(success: $success, message: $message, reasons: $reasons, missionId: $missionId, inspection: $inspection)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationResultModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._reasons, _reasons) &&
            (identical(other.missionId, missionId) ||
                other.missionId == missionId) &&
            (identical(other.inspection, inspection) ||
                other.inspection == inspection));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    message,
    const DeepCollectionEquality().hash(_reasons),
    missionId,
    inspection,
  );

  /// Create a copy of ValidationResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationResultModelImplCopyWith<_$ValidationResultModelImpl>
  get copyWith =>
      __$$ValidationResultModelImplCopyWithImpl<_$ValidationResultModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidationResultModelImplToJson(this);
  }
}

abstract class _ValidationResultModel implements ValidationResultModel {
  const factory _ValidationResultModel({
    required final bool success,
    required final String message,
    final List<String>? reasons,
    final String? missionId,
    final PreTripInspectionModel? inspection,
  }) = _$ValidationResultModelImpl;

  factory _ValidationResultModel.fromJson(Map<String, dynamic> json) =
      _$ValidationResultModelImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  List<String>? get reasons;
  @override
  String? get missionId;
  @override
  PreTripInspectionModel? get inspection;

  /// Create a copy of ValidationResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationResultModelImplCopyWith<_$ValidationResultModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

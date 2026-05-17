// GENERATED CODE - DO NOT MODIFY BY HAND
// Après correction : lancez `flutter pub run build_runner build --delete-conflicting-outputs`

part of 'pretrip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PreTripInspectionModelImpl _$$PreTripInspectionModelImplFromJson(
  Map<String, dynamic> json,
) => _$PreTripInspectionModelImpl(
  id: json['id'] as String,
  reservationId: json['reservationId'] as String,
  adherentId: (json['adherentId'] as num).toInt(),
  statut: $enumDecode(_$StatutPreTripEnumMap, json['statut']),
  etapeCourante: $enumDecode(_$EtapeInspectionEnumMap, json['etapeCourante']),
  latitudeDebut: (json['latitudeDebut'] as num?)?.toDouble(),
  longitudeDebut: (json['longitudeDebut'] as num?)?.toDouble(),
  latitudeFin: (json['latitudeFin'] as num?)?.toDouble(),
  longitudeFin: (json['longitudeFin'] as num?)?.toDouble(),
  dateDebut: DateTime.parse(json['dateDebut'] as String),
  dateValidation: json['dateValidation'] == null
      ? null
      : DateTime.parse(json['dateValidation'] as String),
  motifRejet: json['motifRejet'] as String?,
  nombreMediasUploades: (json['nombreMediasUploades'] as num?)?.toInt() ?? 0,
  peutEtreValidee: json['peutEtreValidee'] as bool? ?? false,
  medias:
      (json['medias'] as List<dynamic>?)
          ?.map((e) => PreTripMediaModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  consent: json['consent'] == null
      ? null
      : PreTripConsentModel.fromJson(json['consent'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$PreTripInspectionModelImplToJson(
  _$PreTripInspectionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'reservationId': instance.reservationId,
  'adherentId': instance.adherentId,
  'statut': _$StatutPreTripEnumMap[instance.statut]!,
  'etapeCourante': _$EtapeInspectionEnumMap[instance.etapeCourante]!,
  'latitudeDebut': instance.latitudeDebut,
  'longitudeDebut': instance.longitudeDebut,
  'latitudeFin': instance.latitudeFin,
  'longitudeFin': instance.longitudeFin,
  'dateDebut': instance.dateDebut.toIso8601String(),
  'dateValidation': instance.dateValidation?.toIso8601String(),
  'motifRejet': instance.motifRejet,
  'nombreMediasUploades': instance.nombreMediasUploades,
  'peutEtreValidee': instance.peutEtreValidee,
  'medias': instance.medias,
  'consent': instance.consent,
};

// ✅ CORRIGÉ : 'completed' ajouté, valeurs alignées sur le backend
const _$StatutPreTripEnumMap = {
  StatutPreTrip.draft:       'DRAFT',
  StatutPreTrip.inProgress:  'IN_PROGRESS',
  StatutPreTrip.completed:   'COMPLETED',
  StatutPreTrip.validated:   'VALIDATED',
  StatutPreTrip.rejected:    'REJECTED',
};

const _$EtapeInspectionEnumMap = {
  EtapeInspection.exterieur:   'EXTERIEUR',
  EtapeInspection.interieur:   'INTERIEUR',
  EtapeInspection.tableauBord: 'TABLEAU_BORD',
  EtapeInspection.documents:   'DOCUMENTS',
  EtapeInspection.identite:    'IDENTITE',
  EtapeInspection.conditions:  'CONDITIONS',
  EtapeInspection.terminee:    'TERMINEE',
};

// ✅ CORRIGÉ : 12 types alignés sur TypeMediaInspection du backend
const _$TypeMediaInspectionEnumMap = {
  TypeMediaInspection.extFaceAvant:        'EXT_FACE_AVANT',
  TypeMediaInspection.extFaceArriere:      'EXT_FACE_ARRIERE',
  TypeMediaInspection.extCoteGauche:       'EXT_COTE_GAUCHE',
  TypeMediaInspection.extCoteDroit:        'EXT_COTE_DROIT',
  TypeMediaInspection.intSiegeConducteur:  'INT_SIEGE_CONDUCTEUR',
  TypeMediaInspection.intSiegePassager:    'INT_SIEGE_PASSAGER',
  TypeMediaInspection.intBanquetteArriere: 'INT_BANQUETTE_ARRIERE',
  TypeMediaInspection.intVueGlobale:       'INT_VUE_GLOBALE',
  TypeMediaInspection.tableauBord:         'TABLEAU_BORD',
  TypeMediaInspection.permisRecto:         'PERMIS_RECTO',
  TypeMediaInspection.permisVerso:         'PERMIS_VERSO',
  TypeMediaInspection.selfieVehicule:      'SELFIE_VEHICULE',
};

_$PreTripMediaModelImpl _$$PreTripMediaModelImplFromJson(
  Map<String, dynamic> json,
) => _$PreTripMediaModelImpl(
  id: json['id'] as String,
  inspectionId: json['inspectionId'] as String,
  typeMedia: $enumDecode(_$TypeMediaInspectionEnumMap, json['typeMedia']),
  cheminFichier: json['cheminFichier'] as String,
  mimeType: json['mimeType'] as String,
  tailleFichier: (json['tailleFichier'] as num).toInt(),
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  precisionGps: (json['precisionGps'] as num?)?.toDouble(),
  timestampPhoto: DateTime.parse(json['timestampPhoto'] as String),
  validatedByServer: json['validatedByServer'] as bool,
  dateUpload: DateTime.parse(json['dateUpload'] as String),
);

Map<String, dynamic> _$$PreTripMediaModelImplToJson(
  _$PreTripMediaModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'inspectionId': instance.inspectionId,
  'typeMedia': _$TypeMediaInspectionEnumMap[instance.typeMedia]!,
  'cheminFichier': instance.cheminFichier,
  'mimeType': instance.mimeType,
  'tailleFichier': instance.tailleFichier,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'precisionGps': instance.precisionGps,
  'timestampPhoto': instance.timestampPhoto.toIso8601String(),
  'validatedByServer': instance.validatedByServer,
  'dateUpload': instance.dateUpload.toIso8601String(),
};

_$PreTripConsentModelImpl _$$PreTripConsentModelImplFromJson(
  Map<String, dynamic> json,
) => _$PreTripConsentModelImpl(
  id: json['id'] as String,
  inspectionId: json['inspectionId'] as String,
  versionConditions: json['versionConditions'] as String,
  clausesAcceptees: json['clausesAcceptees'] as Map<String, dynamic>,
  dateAcceptation: DateTime.parse(json['dateAcceptation'] as String),
  ipAdresse: json['ipAdresse'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$$PreTripConsentModelImplToJson(
  _$PreTripConsentModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'inspectionId': instance.inspectionId,
  'versionConditions': instance.versionConditions,
  'clausesAcceptees': instance.clausesAcceptees,
  'dateAcceptation': instance.dateAcceptation.toIso8601String(),
  'ipAdresse': instance.ipAdresse,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};

_$ValidationResultModelImpl _$$ValidationResultModelImplFromJson(
  Map<String, dynamic> json,
) => _$ValidationResultModelImpl(
  success: json['success'] as bool,
  message: json['message'] as String,
  reasons: (json['reasons'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  missionId: json['missionId'] as String?,
  inspection: json['inspection'] == null
      ? null
      : PreTripInspectionModel.fromJson(
          json['inspection'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$$ValidationResultModelImplToJson(
  _$ValidationResultModelImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'reasons': instance.reasons,
  'missionId': instance.missionId,
  'inspection': instance.inspection,
};
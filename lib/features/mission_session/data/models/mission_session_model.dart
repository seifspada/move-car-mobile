// data/models/mission_session_model.dart

import '../../domain/entities/mission_session_entity.dart';

// ─────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────

StatutSession _parseStatut(String? v) {
  switch (v) {
    case 'EN_COURS':
      return StatutSession.EN_COURS;
    case 'TERMINEE':
      return StatutSession.TERMINEE;
    default:
      return StatutSession.EN_COURS;
  }
}

EtapeSession _parseEtape(String? v) {
  switch (v) {
    case 'POST_LIVRAISON':
      return EtapeSession.POST_LIVRAISON;
    default:
      return EtapeSession.PRE_DEPART;
  }
}

TypeMediaSession _parseTypeMedia(String? v) {
  return TypeMediaSession.values.firstWhere(
    (e) => e.name == v,
    orElse: () => TypeMediaSession.PHOTO_AVANT,
  );
}

// ─────────────────────────────────────────
// MEDIA MODEL
// ─────────────────────────────────────────

class MissionSessionMediaModel extends MissionSessionMediaEntity {
  const MissionSessionMediaModel({
    required super.id,
    required super.sessionId,
    required super.etape,
    required super.typeMedia,
    super.description,
    required super.cheminFichier,
    super.urlPublic,
    super.tailleOctets,
    super.typeContenu,
    required super.dateCreation,
    required super.dateModification,
  });

  factory MissionSessionMediaModel.fromJson(Map<String, dynamic> json) {
    return MissionSessionMediaModel(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      etape: _parseEtape(json['etape'] as String?),
      typeMedia: _parseTypeMedia(json['typeMedia'] as String?),
      description: json['description'] as String?,
      cheminFichier: json['cheminFichier'] as String? ?? '',
      urlPublic: json['urlPublic'] as String?,
      tailleOctets: json['tailleOctets'] as int?,
      typeContenu: json['typeContenu'] as String?,
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      dateModification: DateTime.parse(json['dateModification'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sessionId': sessionId,
        'etape': etape.name,
        'typeMedia': typeMedia.name,
        'description': description,
        'cheminFichier': cheminFichier,
        'urlPublic': urlPublic,
        'tailleOctets': tailleOctets,
        'typeContenu': typeContenu,
        'dateCreation': dateCreation.toIso8601String(),
        'dateModification': dateModification.toIso8601String(),
      };
}

// ─────────────────────────────────────────
// SESSION MODEL
// ─────────────────────────────────────────

class MissionSessionModel extends MissionSessionEntity {
  const MissionSessionModel({
    required super.id,
    required super.reservationId,
    required super.missionId,
    required super.consentAccepted,
    required super.dateConsentement,
    required super.latitudeDebut,
    required super.longitudeDebut,
    required super.dateDebut,
    super.kilometrageDebut,
    super.latitudeFin,
    super.longitudeFin,
    super.dateFin,
    super.kilometrageFin,
    super.commentaireFin,
    super.signatureClient,
    super.nomClientSignature,
    super.dateSignatureClient,
    required super.statut,
    required super.medias,
    required super.dateCreation,
    required super.dateModification,
  });

  factory MissionSessionModel.fromJson(Map<String, dynamic> json) {
    final rawMedias = json['medias'] as List<dynamic>? ?? [];
    return MissionSessionModel(
      id: json['id'] as String,
      reservationId: json['reservationId'] as String,
      missionId: json['missionId'] as String,
      consentAccepted: json['consentAccepted'] as bool? ?? false,
      dateConsentement: DateTime.parse(json['dateConsentement'] as String),
      latitudeDebut: (json['latitudeDebut'] as num).toDouble(),
      longitudeDebut: (json['longitudeDebut'] as num).toDouble(),
      dateDebut: DateTime.parse(json['dateDebut'] as String),
      kilometrageDebut: json['kilometrageDebut'] as int?,
      latitudeFin: (json['latitudeFin'] as num?)?.toDouble(),
      longitudeFin: (json['longitudeFin'] as num?)?.toDouble(),
      dateFin: json['dateFin'] != null ? DateTime.parse(json['dateFin'] as String) : null,
      kilometrageFin: json['kilometrageFin'] as int?,
      commentaireFin: json['commentaireFin'] as String?,
      signatureClient: json['signatureClient'] as String?,
      nomClientSignature: json['nomClientSignature'] as String?,
      dateSignatureClient: json['dateSignatureClient'] != null
          ? DateTime.parse(json['dateSignatureClient'] as String)
          : null,
      statut: _parseStatut(json['statut'] as String?),
      medias: rawMedias
          .map((m) => MissionSessionMediaModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      dateCreation: DateTime.parse(json['dateCreation'] as String),
      dateModification: DateTime.parse(json['dateModification'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reservationId': reservationId,
        'missionId': missionId,
        'consentAccepted': consentAccepted,
        'dateConsentement': dateConsentement.toIso8601String(),
        'latitudeDebut': latitudeDebut,
        'longitudeDebut': longitudeDebut,
        'dateDebut': dateDebut.toIso8601String(),
        'kilometrageDebut': kilometrageDebut,
        'latitudeFin': latitudeFin,
        'longitudeFin': longitudeFin,
        'dateFin': dateFin?.toIso8601String(),
        'kilometrageFin': kilometrageFin,
        'commentaireFin': commentaireFin,
        'statut': statut.name,
        'medias': (medias as List<MissionSessionMediaModel>)
            .map((m) => m.toJson())
            .toList(),
        'dateCreation': dateCreation.toIso8601String(),
        'dateModification': dateModification.toIso8601String(),
      };
}

// ─────────────────────────────────────────
// PHOTO VALIDATION RESULT MODEL
// ─────────────────────────────────────────

class PhotoValidationResultModel {
  final bool valide;
  final List<String> manquantes;

  const PhotoValidationResultModel({
    required this.valide,
    required this.manquantes,
  });

  factory PhotoValidationResultModel.fromJson(Map<String, dynamic> json) {
    return PhotoValidationResultModel(
      valide: json['valide'] as bool? ?? false,
      manquantes: (json['manquantes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

// ─────────────────────────────────────────
// INPUT MODELS (for GraphQL mutations)
// ─────────────────────────────────────────

class MediaUploadInputModel {
  final TypeMediaSession typeMedia;
  final String base64Data;
  final String? description;
  final String? typeContenu;

  const MediaUploadInputModel({
    required this.typeMedia,
    required this.base64Data,
    this.description,
    this.typeContenu,
  });

  Map<String, dynamic> toJson() => {
        'typeMedia': typeMedia.name,
        'base64Data': base64Data,
        if (description != null) 'description': description,
        if (typeContenu != null) 'typeContenu': typeContenu,
      };
}

class StartMissionSessionInputModel {
  final String reservationId;
  final bool consentAccepted;
  final double latitudeDebut;
  final double longitudeDebut;
  final int? kilometrageDebut;
  final List<MediaUploadInputModel>? photosPre;

  const StartMissionSessionInputModel({
    required this.reservationId,
    required this.consentAccepted,
    required this.latitudeDebut,
    required this.longitudeDebut,
    this.kilometrageDebut,
    this.photosPre,
  });

  Map<String, dynamic> toJson() => {
        'reservationId': reservationId,
        'consentAccepted': consentAccepted,
        'latitudeDebut': latitudeDebut,
        'longitudeDebut': longitudeDebut,
        if (kilometrageDebut != null) 'kilometrageDebut': kilometrageDebut,
        if (photosPre != null) 'photosPre': photosPre!.map((p) => p.toJson()).toList(),
      };
}

class EndMissionSessionInputModel {
  final String sessionId;
  final double latitudeFin;
  final double longitudeFin;
  final int? kilometrageFin;
  final String? commentaireFin;
  final List<MediaUploadInputModel>? photosPost;

  const EndMissionSessionInputModel({
    required this.sessionId,
    required this.latitudeFin,
    required this.longitudeFin,
    this.kilometrageFin,
    this.commentaireFin,
    this.photosPost,
  });

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'latitudeFin': latitudeFin,
        'longitudeFin': longitudeFin,
        if (kilometrageFin != null) 'kilometrageFin': kilometrageFin,
        if (commentaireFin != null) 'commentaireFin': commentaireFin,
        if (photosPost != null) 'photosPost': photosPost!.map((p) => p.toJson()).toList(),
      };
}
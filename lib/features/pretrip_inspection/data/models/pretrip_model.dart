import 'package:freezed_annotation/freezed_annotation.dart';

part 'pretrip_model.freezed.dart';
part 'pretrip_model.g.dart';

// ─────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────

enum StatutPreTrip {
  @JsonValue('DRAFT') draft,
  @JsonValue('IN_PROGRESS') inProgress,
  @JsonValue('COMPLETED') completed,
  @JsonValue('VALIDATED') validated,
  @JsonValue('REJECTED') rejected,
}

enum EtapeInspection {
  @JsonValue('EXTERIEUR') exterieur,
  @JsonValue('INTERIEUR') interieur,
  @JsonValue('TABLEAU_BORD') tableauBord,
  @JsonValue('DOCUMENTS') documents,
  @JsonValue('IDENTITE') identite,
  @JsonValue('CONDITIONS') conditions,
  @JsonValue('TERMINEE') terminee,
}

/// ✅ CORRIGÉ : valeurs alignées sur le backend NestJS
enum TypeMediaInspection {
  // Étape 1 : Extérieur (4)
  @JsonValue('EXT_FACE_AVANT') extFaceAvant,
  @JsonValue('EXT_FACE_ARRIERE') extFaceArriere,
  @JsonValue('EXT_COTE_GAUCHE') extCoteGauche,
  @JsonValue('EXT_COTE_DROIT') extCoteDroit,

  // Étape 2 : Intérieur (4)
  @JsonValue('INT_SIEGE_CONDUCTEUR') intSiegeConducteur,
  @JsonValue('INT_SIEGE_PASSAGER') intSiegePassager,
  @JsonValue('INT_BANQUETTE_ARRIERE') intBanquetteArriere,
  @JsonValue('INT_VUE_GLOBALE') intVueGlobale,

  // Étape 3 : Tableau de bord (1)
  @JsonValue('TABLEAU_BORD') tableauBord,

  // Étape 4 : Documents (2)
  @JsonValue('PERMIS_RECTO') permisRecto,
  @JsonValue('PERMIS_VERSO') permisVerso,

  // Étape 5 : Identité (1)
  @JsonValue('SELFIE_VEHICULE') selfieVehicule,
}

extension TypeMediaInspectionX on TypeMediaInspection {
  /// Valeur JSON/backend (pour l'URL REST d'upload)
  String get jsonValue {
    switch (this) {
      case TypeMediaInspection.extFaceAvant:        return 'EXT_FACE_AVANT';
      case TypeMediaInspection.extFaceArriere:      return 'EXT_FACE_ARRIERE';
      case TypeMediaInspection.extCoteGauche:       return 'EXT_COTE_GAUCHE';
      case TypeMediaInspection.extCoteDroit:        return 'EXT_COTE_DROIT';
      case TypeMediaInspection.intSiegeConducteur:  return 'INT_SIEGE_CONDUCTEUR';
      case TypeMediaInspection.intSiegePassager:    return 'INT_SIEGE_PASSAGER';
      case TypeMediaInspection.intBanquetteArriere: return 'INT_BANQUETTE_ARRIERE';
      case TypeMediaInspection.intVueGlobale:       return 'INT_VUE_GLOBALE';
      case TypeMediaInspection.tableauBord:         return 'TABLEAU_BORD';
      case TypeMediaInspection.permisRecto:         return 'PERMIS_RECTO';
      case TypeMediaInspection.permisVerso:         return 'PERMIS_VERSO';
      case TypeMediaInspection.selfieVehicule:      return 'SELFIE_VEHICULE';
    }
  }

  String get label {
    switch (this) {
      case TypeMediaInspection.extFaceAvant:        return 'Face avant';
      case TypeMediaInspection.extFaceArriere:      return 'Face arrière';
      case TypeMediaInspection.extCoteGauche:       return 'Côté gauche';
      case TypeMediaInspection.extCoteDroit:        return 'Côté droit';
      case TypeMediaInspection.intSiegeConducteur:  return 'Siège conducteur';
      case TypeMediaInspection.intSiegePassager:    return 'Siège passager';
      case TypeMediaInspection.intBanquetteArriere: return 'Banquette arrière';
      case TypeMediaInspection.intVueGlobale:       return 'Vue globale';
      case TypeMediaInspection.tableauBord:         return 'Tableau de bord';
      case TypeMediaInspection.permisRecto:         return 'Permis recto';
      case TypeMediaInspection.permisVerso:         return 'Permis verso';
      case TypeMediaInspection.selfieVehicule:      return 'Selfie avec véhicule';
    }
  }

  String get icon {
    switch (this) {
      case TypeMediaInspection.extFaceAvant:
      case TypeMediaInspection.extFaceArriere:
      case TypeMediaInspection.extCoteGauche:
      case TypeMediaInspection.extCoteDroit:
        return '🚗';
      case TypeMediaInspection.intSiegeConducteur:
      case TypeMediaInspection.intSiegePassager:
      case TypeMediaInspection.intBanquetteArriere:
      case TypeMediaInspection.intVueGlobale:
        return '🪑';
      case TypeMediaInspection.tableauBord:
        return '🎛️';
      case TypeMediaInspection.permisRecto:
      case TypeMediaInspection.permisVerso:
        return '🪪';
      case TypeMediaInspection.selfieVehicule:
        return '🤳';
    }
  }

  EtapeInspection get step {
    switch (this) {
      case TypeMediaInspection.extFaceAvant:
      case TypeMediaInspection.extFaceArriere:
      case TypeMediaInspection.extCoteGauche:
      case TypeMediaInspection.extCoteDroit:
        return EtapeInspection.exterieur;
      case TypeMediaInspection.intSiegeConducteur:
      case TypeMediaInspection.intSiegePassager:
      case TypeMediaInspection.intBanquetteArriere:
      case TypeMediaInspection.intVueGlobale:
        return EtapeInspection.interieur;
      case TypeMediaInspection.tableauBord:
        return EtapeInspection.tableauBord;
      case TypeMediaInspection.permisRecto:
      case TypeMediaInspection.permisVerso:
        return EtapeInspection.documents;
      case TypeMediaInspection.selfieVehicule:
        return EtapeInspection.identite;
    }
  }
}

extension EtapeInspectionX on EtapeInspection {
  String get label {
    switch (this) {
      case EtapeInspection.exterieur:   return 'Extérieur';
      case EtapeInspection.interieur:   return 'Intérieur';
      case EtapeInspection.tableauBord: return 'Tableau de bord';
      case EtapeInspection.documents:   return 'Documents';
      case EtapeInspection.identite:    return 'Identité';
      case EtapeInspection.conditions:  return 'Conditions';
      case EtapeInspection.terminee:    return 'Terminée';
    }
  }

  int get stepIndex {
    switch (this) {
      case EtapeInspection.exterieur:   return 0;
      case EtapeInspection.interieur:   return 1;
      case EtapeInspection.tableauBord: return 2;
      case EtapeInspection.documents:   return 3;
      case EtapeInspection.identite:    return 4;
      case EtapeInspection.conditions:  return 5;
      case EtapeInspection.terminee:    return 6;
    }
  }
}

// ─────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────

@freezed
class PreTripInspectionModel with _$PreTripInspectionModel {
  const factory PreTripInspectionModel({
    required String id,
    required String reservationId,
    required int adherentId,
    required StatutPreTrip statut,
    required EtapeInspection etapeCourante,
    double? latitudeDebut,
    double? longitudeDebut,
    double? latitudeFin,
    double? longitudeFin,
    required DateTime dateDebut,
    DateTime? dateValidation,
    String? motifRejet,
    @Default(0) int nombreMediasUploades,
    @Default(false) bool peutEtreValidee,
    @Default([]) List<PreTripMediaModel> medias,
    PreTripConsentModel? consent,
  }) = _PreTripInspectionModel;

  factory PreTripInspectionModel.fromJson(Map<String, dynamic> json) =>
      _$PreTripInspectionModelFromJson(json);
}

@freezed
class PreTripMediaModel with _$PreTripMediaModel {
  const factory PreTripMediaModel({
    required String id,
    required String inspectionId,
    required TypeMediaInspection typeMedia,
    required String cheminFichier,
    required String mimeType,
    required int tailleFichier,
    required double latitude,
    required double longitude,
    double? precisionGps,
    required DateTime timestampPhoto,
    required bool validatedByServer,
    required DateTime dateUpload,
  }) = _PreTripMediaModel;

  factory PreTripMediaModel.fromJson(Map<String, dynamic> json) =>
      _$PreTripMediaModelFromJson(json);
}

@freezed
class PreTripConsentModel with _$PreTripConsentModel {
  const factory PreTripConsentModel({
    required String id,
    required String inspectionId,
    required String versionConditions,
    required Map<String, dynamic> clausesAcceptees,
    required DateTime dateAcceptation,
    String? ipAdresse,
    double? latitude,
    double? longitude,
  }) = _PreTripConsentModel;

  factory PreTripConsentModel.fromJson(Map<String, dynamic> json) =>
      _$PreTripConsentModelFromJson(json);
}

@freezed
class ValidationResultModel with _$ValidationResultModel {
  const factory ValidationResultModel({
    required bool success,
    required String message,
    List<String>? reasons,
    String? missionId,
    PreTripInspectionModel? inspection,
  }) = _ValidationResultModel;

  factory ValidationResultModel.fromJson(Map<String, dynamic> json) =>
      _$ValidationResultModelFromJson(json);
}
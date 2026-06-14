// domain/entities/mission_session_entity.dart

import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────

enum StatutSession { EN_COURS, TERMINEE }

enum EtapeSession { PRE_DEPART, POST_LIVRAISON }

enum TypeMediaSession {
  // Pré-départ
  PHOTO_AVANT,
  PHOTO_ARRIERE,
  PHOTO_GAUCHE,
  PHOTO_DROIT,
  PHOTO_INTERIEUR,
  PHOTO_TABLEAU_BORD,
  PHOTO_CARBURANT,
  DEGATS_PRE_MISSION,
  // Documents
  PERMIS_RECTO_CONDUCTEUR,
  PERMIS_VERSO_CONDUCTEUR,
  // Post-livraison
  PHOTO_AVANT_FINAL,
  PHOTO_ARRIERE_FINAL,
  PHOTO_GAUCHE_FINAL,
  PHOTO_DROIT_FINAL,
  PHOTO_INTERIEUR_FINAL,
  PHOTO_TABLEAU_BORD_FINAL,
  CARBURANT_FINAL,
  DEGATS_POST_MISSION,
  PREUVE_LIVRAISON,
  SIGNATURE_CLIENT,
}

extension TypeMediaSessionLabel on TypeMediaSession {
  String get label {
    switch (this) {
      case TypeMediaSession.PHOTO_AVANT:
        return 'Photo avant';
      case TypeMediaSession.PHOTO_ARRIERE:
        return 'Photo arrière';
      case TypeMediaSession.PHOTO_GAUCHE:
        return 'Côté gauche';
      case TypeMediaSession.PHOTO_DROIT:
        return 'Côté droit';
      case TypeMediaSession.PHOTO_INTERIEUR:
        return 'Intérieur';
      case TypeMediaSession.PHOTO_TABLEAU_BORD:
        return 'Tableau de bord';
      case TypeMediaSession.PHOTO_CARBURANT:
        return 'Carburant';
      case TypeMediaSession.DEGATS_PRE_MISSION:
        return 'Dégâts pré-mission';
      case TypeMediaSession.PERMIS_RECTO_CONDUCTEUR:
        return 'Permis recto';
      case TypeMediaSession.PERMIS_VERSO_CONDUCTEUR:
        return 'Permis verso';
      case TypeMediaSession.PHOTO_AVANT_FINAL:
        return 'Photo avant (final)';
      case TypeMediaSession.PHOTO_ARRIERE_FINAL:
        return 'Photo arrière (final)';
      case TypeMediaSession.PHOTO_GAUCHE_FINAL:
        return 'Côté gauche (final)';
      case TypeMediaSession.PHOTO_DROIT_FINAL:
        return 'Côté droit (final)';
      case TypeMediaSession.PHOTO_INTERIEUR_FINAL:
        return 'Intérieur (final)';
      case TypeMediaSession.PHOTO_TABLEAU_BORD_FINAL:
        return 'Tableau de bord (final)';
      case TypeMediaSession.CARBURANT_FINAL:
        return 'Carburant (final)';
      case TypeMediaSession.DEGATS_POST_MISSION:
        return 'Dégâts post-mission';
      case TypeMediaSession.PREUVE_LIVRAISON:
        return 'Preuve de livraison';
      case TypeMediaSession.SIGNATURE_CLIENT:
        return 'Signature client';
    }
  }

  String get icon {
    switch (this) {
      case TypeMediaSession.PHOTO_AVANT:
      case TypeMediaSession.PHOTO_AVANT_FINAL:
        return '🚗';
      case TypeMediaSession.PHOTO_ARRIERE:
      case TypeMediaSession.PHOTO_ARRIERE_FINAL:
        return '🔙';
      case TypeMediaSession.PHOTO_GAUCHE:
      case TypeMediaSession.PHOTO_GAUCHE_FINAL:
        return '◀️';
      case TypeMediaSession.PHOTO_DROIT:
      case TypeMediaSession.PHOTO_DROIT_FINAL:
        return '▶️';
      case TypeMediaSession.PHOTO_INTERIEUR:
      case TypeMediaSession.PHOTO_INTERIEUR_FINAL:
        return '🪑';
      case TypeMediaSession.PHOTO_TABLEAU_BORD:
      case TypeMediaSession.PHOTO_TABLEAU_BORD_FINAL:
        return '📊';
      case TypeMediaSession.PERMIS_RECTO_CONDUCTEUR:
      case TypeMediaSession.PERMIS_VERSO_CONDUCTEUR:
        return '🪪';
      case TypeMediaSession.PREUVE_LIVRAISON:
        return '✅';
      case TypeMediaSession.SIGNATURE_CLIENT:
        return '✍️';
      default:
        return '📷';
    }
  }
}

// ─────────────────────────────────────────
// REQUIRED PHOTOS CONSTANTS
// ─────────────────────────────────────────

const List<TypeMediaSession> kPhotosRequisePreDepart = [
  TypeMediaSession.PHOTO_AVANT,
  TypeMediaSession.PHOTO_ARRIERE,
  TypeMediaSession.PHOTO_GAUCHE,
  TypeMediaSession.PHOTO_DROIT,
  TypeMediaSession.PHOTO_INTERIEUR,
  TypeMediaSession.PHOTO_TABLEAU_BORD,
  TypeMediaSession.PERMIS_RECTO_CONDUCTEUR,
  TypeMediaSession.PERMIS_VERSO_CONDUCTEUR,
];

const List<TypeMediaSession> kPhotosRequisePostLivraison = [
  TypeMediaSession.PHOTO_AVANT_FINAL,
  TypeMediaSession.PHOTO_ARRIERE_FINAL,
  TypeMediaSession.PHOTO_GAUCHE_FINAL,
  TypeMediaSession.PHOTO_DROIT_FINAL,
  TypeMediaSession.PHOTO_INTERIEUR_FINAL,
  TypeMediaSession.PHOTO_TABLEAU_BORD_FINAL,
  TypeMediaSession.PREUVE_LIVRAISON,
];

// ─────────────────────────────────────────
// ENTITIES
// ─────────────────────────────────────────

class MissionSessionMediaEntity extends Equatable {
  final String id;
  final String sessionId;
  final EtapeSession etape;
  final TypeMediaSession typeMedia;
  final String? description;
  final String cheminFichier;
  final String? urlPublic;
  final int? tailleOctets;
  final String? typeContenu;
  final DateTime dateCreation;
  final DateTime dateModification;

  const MissionSessionMediaEntity({
    required this.id,
    required this.sessionId,
    required this.etape,
    required this.typeMedia,
    this.description,
    required this.cheminFichier,
    this.urlPublic,
    this.tailleOctets,
    this.typeContenu,
    required this.dateCreation,
    required this.dateModification,
  });

  @override
  List<Object?> get props => [id, sessionId, etape, typeMedia];
}

class MissionSessionEntity extends Equatable {
  final String id;
  final String reservationId;
  final String missionId;
  final bool consentAccepted;
  final DateTime dateConsentement;
  final double latitudeDebut;
  final double longitudeDebut;
  final DateTime dateDebut;
  final int? kilometrageDebut;
  final double? latitudeFin;
  final double? longitudeFin;
  final DateTime? dateFin;
  final int? kilometrageFin;
  final String? commentaireFin;
  final String? signatureClient;
  final String? nomClientSignature;
  final DateTime? dateSignatureClient;
  final StatutSession statut;
  final List<MissionSessionMediaEntity> medias;
  final DateTime dateCreation;
  final DateTime dateModification;

  const MissionSessionEntity({
    required this.id,
    required this.reservationId,
    required this.missionId,
    required this.consentAccepted,
    required this.dateConsentement,
    required this.latitudeDebut,
    required this.longitudeDebut,
    required this.dateDebut,
    this.kilometrageDebut,
    this.latitudeFin,
    this.longitudeFin,
    this.dateFin,
    this.kilometrageFin,
    this.commentaireFin,
    this.signatureClient,
    this.nomClientSignature,
    this.dateSignatureClient,
    required this.statut,
    required this.medias,
    required this.dateCreation,
    required this.dateModification,
  });

  bool get isEnCours => statut == StatutSession.EN_COURS;
  bool get isTerminee => statut == StatutSession.TERMINEE;

  List<MissionSessionMediaEntity> get mediasPreDepart =>
      medias.where((m) => m.etape == EtapeSession.PRE_DEPART).toList();

  List<MissionSessionMediaEntity> get mediasPostLivraison =>
      medias.where((m) => m.etape == EtapeSession.POST_LIVRAISON).toList();

  @override
  List<Object?> get props => [id, statut, dateModification];
}
// data/graphql/mission_session_queries.dart

class MissionSessionQueries {
  // ─────────────────────────────────────────
  // FRAGMENTS
  // ─────────────────────────────────────────

  static const String mediaFragment = '''
    fragment MediaFields on MissionSessionMedia {
      id
      sessionId
      etape
      typeMedia
      description
      cheminFichier
      urlPublic
      tailleOctets
      typeContenu
      dateCreation
      dateModification
    }
  ''';

  static const String sessionFragment = '''
    fragment SessionFields on MissionSession {
      id
      reservationId
      missionId
      consentAccepted
      dateConsentement
      latitudeDebut
      longitudeDebut
      dateDebut
      kilometrageDebut
      latitudeFin
      longitudeFin
      dateFin
      kilometrageFin
      commentaireFin
      signatureClient
      nomClientSignature
      dateSignatureClient
      statut
      dateCreation
      dateModification
    }
  ''';

  // ─────────────────────────────────────────
  // QUERIES
  // ─────────────────────────────────────────

  /// FIX : L'ancien champ "getMissionSession" n'existe PAS dans le schéma.
  /// Il provoquait : "Cannot query field 'getMissionSession' on type 'Query'."
  /// On utilise maintenant "getMyMissionSessions" (valide) et on filtre
  /// par reservationId côté client dans le repository.
  static const String getMyMissionSessions = '''
    query GetMyMissionSessions {
      getMyMissionSessions {
        id
        reservationId
        missionId
        consentAccepted
        dateConsentement
        latitudeDebut
        longitudeDebut
        dateDebut
        kilometrageDebut
        latitudeFin
        longitudeFin
        dateFin
        kilometrageFin
        commentaireFin
        statut
        dateCreation
        dateModification
      }
    }
  ''';

  static const String getMissionSessionPhotos = '''
    query GetMissionSessionPhotos(\$sessionId: String!, \$etape: EtapeSession) {
      getMissionSessionPhotos(sessionId: \$sessionId, etape: \$etape) {
        id
        sessionId
        etape
        typeMedia
        description
        cheminFichier
        urlPublic
        tailleOctets
        typeContenu
        dateCreation
        dateModification
      }
    }
  ''';

  static const String validatePreMissionPhotos = '''
    query ValidatePreMissionPhotos(\$sessionId: String!) {
      validatePreMissionPhotos(sessionId: \$sessionId) {
        valide
        manquantes
      }
    }
  ''';

  static const String validatePostMissionPhotos = '''
    query ValidatePostMissionPhotos(\$sessionId: String!) {
      validatePostMissionPhotos(sessionId: \$sessionId) {
        valide
        manquantes
      }
    }
  ''';

  // ─────────────────────────────────────────
  // MUTATIONS
  // ─────────────────────────────────────────

  static const String startMissionSession = '''
    mutation StartMissionSession(\$input: StartMissionSessionInput!) {
      startMissionSession(input: \$input) {
        id
        reservationId
        missionId
        consentAccepted
        dateConsentement
        latitudeDebut
        longitudeDebut
        dateDebut
        kilometrageDebut
        statut
        dateCreation
        dateModification
      }
    }
  ''';

  static const String endMissionSession = '''
    mutation EndMissionSession(\$input: EndMissionSessionInput!) {
      endMissionSession(input: \$input) {
        id
        reservationId
        missionId
        consentAccepted
        dateConsentement
        latitudeDebut
        longitudeDebut
        dateDebut
        kilometrageDebut
        latitudeFin
        longitudeFin
        dateFin
        kilometrageFin
        commentaireFin
        statut
        dateCreation
        dateModification
      }
    }
  ''';

  static const String uploadMissionPhotos = '''
    mutation UploadMissionPhotos(\$input: UploadMissionPhotosInput!) {
      uploadMissionPhotos(input: \$input) {
        id
        sessionId
        etape
        typeMedia
        description
        cheminFichier
        urlPublic
        tailleOctets
        typeContenu
        dateCreation
        dateModification
      }
    }
  ''';
}

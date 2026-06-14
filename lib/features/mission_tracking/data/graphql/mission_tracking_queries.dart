class MissionTrackingQueries {

  // ─── MUTATIONS ────────────────────────────────────────────

  static const String updateLocation = r'''
    mutation UpdateMissionLocation($input: UpdateLocationInput!) {
      updateMissionLocation(input: $input) {
        id
        sessionId
        latitude
        longitude
        accuracy
        timestamp
        isDeviated
        distanceFromRoute
      }
    }
  ''';

  static const String completeMission = r'''
    mutation CompleteMission($input: CompleteMissionInput!) {
      completeMission(input: $input) {
        id
        missionId
        latitudeFin
        longitudeFin
        totalLocations
        validLocations
        invalidLocations
        maxDeviation
        dureeTrajet
        completed
        dateCompletion
        invalidationReason
      }
    }
  ''';

  static const String reportIncident = r'''
    mutation ReportMissionIncident($input: ReportIncidentInput!) {
      reportMissionIncident(input: $input) {
        id
        sessionId
        typeIncident
        description
        latitude
        longitude
        dateCreation
        medias {
          id
          cheminFichier
          tailleOctets
          ordre
          dateCreation
        }
      }
    }
  ''';

  static const String resolveIncident = r'''
    mutation ResolveMissionIncident($input: ResolveIncidentInput!) {
      resolveMissionIncident(input: $input) {
        id
        sessionId
        typeIncident
        description
        resolvedBy
        resolutionNotes
        dateResolution
        medias {
          id
          cheminFichier
          ordre
        }
      }
    }
  ''';

  // ─── QUERIES ──────────────────────────────────────────────

  static const String checkArrival = r'''
    query CheckMissionArrival(
      $sessionId: ID!
      $latitude: Float!
      $longitude: Float!
    ) {
      checkMissionArrival(
        sessionId: $sessionId
        latitude: $latitude
        longitude: $longitude
      ) {
        isArrived
        distanceMetres
        villeArrivee
      }
    }
  ''';

  static const String getTrackingHistory = r'''
    query GetMissionTrackingHistory($missionId: ID!) {
      getMissionTrackingHistory(missionId: $missionId) {
        id
        sessionId
        latitude
        longitude
        accuracy
        timestamp
        isDeviated
        distanceFromRoute
      }
    }
  ''';

  static const String getMissionCompletion = r'''
    query GetMissionCompletion($missionId: ID!) {
      getMissionCompletion(missionId: $missionId) {
        id
        missionId
        latitudeFin
        longitudeFin
        totalLocations
        validLocations
        invalidLocations
        maxDeviation
        dureeTrajet
        completed
        dateCompletion
        invalidationReason
      }
    }
  ''';

  static const String getMissionIncidents = r'''
    query GetMissionIncidents($sessionId: ID!) {
      getMissionIncidents(sessionId: $sessionId) {
        id
        sessionId
        typeIncident
        description
        latitude
        longitude
        resolvedBy
        resolutionNotes
        dateResolution
        dateCreation
        medias {
          id
          cheminFichier
          tailleOctets
          ordre
          dateCreation
        }
      }
    }
  ''';
}
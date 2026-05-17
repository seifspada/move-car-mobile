// lib/features/pretrip_inspection/data/graphql/pretrip_queries.dart

class PreTripQueries {
  // ─────────────────────────────────────────
  // MUTATIONS
  // ─────────────────────────────────────────

  static const String startInspection = r'''
    mutation StartInspection($input: StartInspectionInput!) {
      startInspection(input: $input) {
        id
        reservationId
        adherentId
        statut
        etapeCourante
        latitudeDebut
        longitudeDebut
        dateDebut
        nombreMediasUploades
        peutEtreValidee
      }
    }
  ''';

  static const String submitConsent = r'''
    mutation SubmitConsent($input: SubmitConsentInput!) {
      submitConsent(input: $input) {
        id
        reservationId
        adherentId
        statut
        etapeCourante
        dateDebut
        nombreMediasUploades
        peutEtreValidee
        consent {
          id
          versionConditions
          dateAcceptation
        }
      }
    }
  ''';

  static const String validateAndStartMission = r'''
    mutation ValidateAndStartMission($input: ValidateInspectionInput!) {
      validateAndStartMission(input: $input) {
        id
        reservationId
        adherentId
        statut
        etapeCourante
        dateDebut
        dateValidation
        motifRejet
        nombreMediasUploades
        peutEtreValidee
        medias {
          id
          typeMedia
          cheminFichier
          timestampPhoto
          validatedByServer
        }
      }
    }
  ''';

  // ─────────────────────────────────────────
  // QUERIES
  // ─────────────────────────────────────────

  static const String getInspectionByReservation = r'''
    query GetInspectionByReservation($reservationId: ID!) {
      getInspectionByReservation(reservationId: $reservationId) {
        id
        reservationId
        adherentId
        statut
        etapeCourante
        latitudeDebut
        longitudeDebut
        latitudeFin
        longitudeFin
        dateDebut
        dateValidation
        motifRejet
        nombreMediasUploades
        peutEtreValidee
        medias {
          id
          typeMedia
          cheminFichier
          mimeType
          tailleFichier
          latitude
          longitude
          timestampPhoto
          validatedByServer
          dateUpload
        }
        consent {
          id
          versionConditions
          dateAcceptation
          # ✅ clausesAcceptees supprimé (n'existe pas sur PreTripConsent)
        }
      }
    }
  ''';

  static const String getInspectionDetails = r'''
    query GetInspectionDetails($inspectionId: ID!) {
      getInspectionDetails(inspectionId: $inspectionId) {
        id
        reservationId
        adherentId
        statut
        etapeCourante
        latitudeDebut
        longitudeDebut
        latitudeFin
        longitudeFin
        dateDebut
        dateValidation
        motifRejet
        nombreMediasUploades
        peutEtreValidee
        medias {
          id
          typeMedia
          cheminFichier
          mimeType
          tailleFichier
          latitude
          longitude
          timestampPhoto
          validatedByServer
          dateUpload
        }
        consent {
          id
          versionConditions
          dateAcceptation
          # ✅ clausesAcceptees supprimé (n'existe pas sur PreTripConsent)
        }
      }
    }
  ''';

  static const String listInspections = r'''
    query ListInspections($filter: InspectionFilterInput) {
      listInspections(filter: $filter) {
        id
        reservationId
        adherentId
        statut
        etapeCourante
        dateDebut
        dateValidation
        nombreMediasUploades
        peutEtreValidee
      }
    }
  ''';
}
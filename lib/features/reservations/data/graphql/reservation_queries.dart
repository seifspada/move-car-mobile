// lib/features/reservations/data/graphql/reservation_queries.dart

// ── Queries ────────────────────────────────────────────────

const String getMyReservations = '''
  query GetMyReservations {
    myReservations {
      id
      missionId
      numeroReservation
      statut
      statutPrecedent
      dateDepart
      heureDepart
      dateArrivee
      heureArrivee
      dureeEstimee
      montantTotal
      fraisPeage
      distanceKm
      motifRefus
      motifAnnulation
      annulePar
      dateCreation
      dateAcceptationAgent
      dateConfirmationAdherent
      dateAnnulation
      adherent {
        id
        nom
        prenom
        telephone
        statut
        user {
          name
          email
          photo
        }
      }
      mission {
        id
        statut
        adresseDepart {
          villeNom
        }
        adresseArrivee {
          villeNom
        }
      }
    }
  }
''';

const String getAllReservations = '''
  query GetAllReservations {
    allReservations {
      id
      missionId
      numeroReservation
      statut
      statutPrecedent
      dateDepart
      heureDepart
      dateArrivee
      heureArrivee
      dureeEstimee
      montantTotal
      fraisPeage
      distanceKm
      motifRefus
      motifAnnulation
      annulePar
      dateCreation
      dateAcceptationAgent
      dateConfirmationAdherent
      dateAnnulation
      adherent {
        id
        nom
        prenom
        telephone
        statut
        user {
          name
          email
          photo
        }
      }
      mission {
        id
        statut
        adresseDepart {
          villeNom
        }
        adresseArrivee {
          villeNom
        }
      }
    }
  }
''';

const String getReservationById = '''
  query GetReservationById(\$id: String!) {
    reservationById(id: \$id) {
      id
      missionId
      numeroReservation
      statut
      statutPrecedent
      dateDepart
      heureDepart
      dateArrivee
      heureArrivee
      dureeEstimee
      montantTotal
      fraisPeage
      distanceKm
      motifRefus
      motifAnnulation
      annulePar
      dateCreation
      dateAcceptationAgent
      dateConfirmationAdherent
      dateAnnulation
      adherent {
        id
        nom
        prenom
        telephone
        statut
        user {
          name
          email
          photo
        }
      }
      mission {
        id
        statut
        adresseDepart {
          villeNom
        }
        adresseArrivee {
          villeNom
        }
      }
    }
  }
''';

const String getReservationsByMission = '''
  query GetReservationsByMission(\$missionId: String!) {
    reservationsByMission(missionId: \$missionId) {
      id
      missionId
      numeroReservation
      statut
      statutPrecedent
      dateDepart
      heureDepart
      dateArrivee
      heureArrivee
      dureeEstimee
      montantTotal
      fraisPeage
      distanceKm
      motifRefus
      motifAnnulation
      annulePar
      dateCreation
      dateAcceptationAgent
      dateConfirmationAdherent
      dateAnnulation
      adherent {
        id
        nom
        prenom
        telephone
        statut
        user {
          name
          email
          photo
        }
      }
      mission {
        id
        statut
        adresseDepart {
          villeNom
        }
        adresseArrivee {
          villeNom
        }
      }
    }
  }
''';

// ── Mutations — Adhérent ───────────────────────────────────

const String cancelReservation = '''
  mutation CancelReservation(\$id: String!, \$motifAnnulation: String) {
    cancelReservation(id: \$id, motifAnnulation: \$motifAnnulation) {
      id
      missionId
      numeroReservation
      statut
      dateAnnulation
      motifAnnulation
      annulePar
    }
  }
''';

const String confirmReservationByAdherent = '''
  mutation ConfirmReservationByAdherent(\$id: String!) {
    confirmReservationByAdherent(id: \$id) {
      id
      missionId
      numeroReservation
      statut
      dateConfirmationAdherent
    }
  }
''';

const String requestCancellation = '''
  mutation RequestCancellation(\$id: String!, \$motifAnnulation: String!) {
    requestCancellation(id: \$id, motifAnnulation: \$motifAnnulation) {
      id
      missionId
      numeroReservation
      statut
      statutPrecedent
      motifAnnulation
    }
  }
''';

const String cancelPendingReservation = '''
  mutation CancelPendingReservation(\$id: String!) {
    cancelPendingReservation(id: \$id) {
      id
      statut
      numeroReservation
      missionId
      dateAnnulation
      motifAnnulation
      annulePar
    }
  }
''';

// ── Mutations — Agent ──────────────────────────────────────

const String acceptReservation = '''
  mutation AcceptReservation(\$id: String!) {
    acceptReservation(id: \$id) {
      id
      missionId
      numeroReservation
      statut
      dateAcceptationAgent
    }
  }
''';

const String refuseReservation = '''
  mutation RefuseReservation(\$id: String!, \$motifRefus: String!) {
    refuseReservation(id: \$id, motifRefus: \$motifRefus) {
      id
      missionId
      numeroReservation
      statut
      motifRefus
    }
  }
''';

const String acceptCancellationRequest = '''
  mutation AcceptCancellationRequest(\$id: String!) {
    acceptCancellationRequest(id: \$id) {
      id
      missionId
      numeroReservation
      statut
      dateAnnulation
      annulePar
    }
  }
''';

const String refuseCancellationRequest = '''
  mutation RefuseCancellationRequest(\$id: String!, \$motifRefus: String!) {
    refuseCancellationRequest(id: \$id, motifRefus: \$motifRefus) {
      id
      missionId
      numeroReservation
      statut
      statutPrecedent
      motifRefus
    }
  }
''';
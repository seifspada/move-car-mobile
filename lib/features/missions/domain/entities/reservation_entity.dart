// lib/features/missions/domain/entities/reservation_entity.dart

enum StatutReservation {
  enAttente,
  acceptedByAgent,
  confirmedByAdherent,
  annulationDemandee,
  enCours,
  terminee,
  annulee,
  refusee,
}

enum ReservationErrorCode {
  reservationAlreadyExists,
  missionNotFound,
  missionNotAvailable,
  adherentNotFound,
  adherentNotAuthorized,
  invalidDepartureDate,
  graphqlError,
  noResponse,
}

extension ReservationErrorCodeX on ReservationErrorCode {
  static ReservationErrorCode? fromString(String? code) {
    switch (code) {
      case 'RESERVATION_ALREADY_EXISTS':
        return ReservationErrorCode.reservationAlreadyExists;
      case 'MISSION_NOT_FOUND':
        return ReservationErrorCode.missionNotFound;
      case 'MISSION_NOT_AVAILABLE':
        return ReservationErrorCode.missionNotAvailable;
      case 'ADHERENT_NOT_FOUND':
        return ReservationErrorCode.adherentNotFound;
      case 'ADHERENT_NOT_AUTHORIZED':
        return ReservationErrorCode.adherentNotAuthorized;
      case 'INVALID_DEPARTURE_DATE':
        return ReservationErrorCode.invalidDepartureDate;
      case 'GRAPHQL_ERROR':
        return ReservationErrorCode.graphqlError;
      case 'NO_RESPONSE':
        return ReservationErrorCode.noResponse;
      default:
        return null;
    }
  }
}

class ReservationEntity {
  final String id;
  final String missionId;
  final String numeroReservation;
  final String statut;
  final String? statutPrecedent;

  final String dateDepart;
  final String heureDepart;
  final String? dateArrivee;
  final String? heureArrivee;
  final int? dureeEstimee;

  final double? montantTotal;
  final double? fraisPeage;
  final double? distanceKm;

  final String? motifRefus;
  final String? motifAnnulation;
  final String? annulePar;

  final String? dateCreation;
  final String? dateValidation;
  final String? dateAcceptationAgent;
  final String? dateConfirmationAdherent;
  final String? dateAnnulation;

  const ReservationEntity({
    required this.id,
    required this.missionId,
    required this.numeroReservation,
    required this.statut,
    this.statutPrecedent,
    required this.dateDepart,
    required this.heureDepart,
    this.dateArrivee,
    this.heureArrivee,
    this.dureeEstimee,
    this.montantTotal,
    this.fraisPeage,
    this.distanceKm,
    this.motifRefus,
    this.motifAnnulation,
    this.annulePar,
    this.dateCreation,
    this.dateValidation,
    this.dateAcceptationAgent,
    this.dateConfirmationAdherent,
    this.dateAnnulation,
  });
}

class ReservationResponseEntity {
  final bool success;
  final String message;
  final String? code;
  final ReservationEntity? reservation;

  const ReservationResponseEntity({
    required this.success,
    required this.message,
    this.code,
    this.reservation,
  });

  ReservationErrorCode? get errorCode =>
      ReservationErrorCodeX.fromString(code);
}

class CreateReservationInput {
  final String missionId;
  final String dateDepart; // YYYY-MM-DD
  final String heureDepart; // HH:mm

  const CreateReservationInput({
    required this.missionId,
    required this.dateDepart,
    required this.heureDepart,
  });

  Map<String, dynamic> toJson() => {
        'missionId': missionId,
        'dateDepart': dateDepart,
        'heureDepart': heureDepart,
      };
}
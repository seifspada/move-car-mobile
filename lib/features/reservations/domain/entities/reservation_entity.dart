// lib/features/reservations/domain/entities/reservation_entity.dart

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
  final String? dateAcceptationAgent;
  final String? dateConfirmationAdherent;
  final String? dateAnnulation;

  final MissionSimple? mission;

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
    this.dateAcceptationAgent,
    this.dateConfirmationAdherent,
    this.dateAnnulation,
    this.mission,
  });
}

class MissionSimple {
  final String? villeDepart;
  final String? villeArrivee;

  const MissionSimple({this.villeDepart, this.villeArrivee});
}
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
  final MissionSessionSimple? missionSession; // ✅

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
    this.missionSession, // ✅
  });
}

class MissionSimple {
  final String? villeDepart;
  final String? villeArrivee;
  final double? latitudeArrivee;
  final double? longitudeArrivee;

  const MissionSimple({
    this.villeDepart,
    this.villeArrivee,
    this.latitudeArrivee,
    this.longitudeArrivee,
  });
}

// ✅ nouveau
class MissionSessionSimple {
  final String id;
  final String statut;
  final String? dateDebut;
  final String? dateFin;

  const MissionSessionSimple({
    required this.id,
    required this.statut,
    this.dateDebut,
    this.dateFin,
  });
}
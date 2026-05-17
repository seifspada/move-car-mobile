// lib/features/reservations/data/models/reservation_model.dart

import '../../domain/entities/reservation_entity.dart';

class ReservationModel extends ReservationEntity {
  const ReservationModel({
    required super.id,
    required super.missionId,
    required super.numeroReservation,
    required super.statut,
    super.statutPrecedent,
    required super.dateDepart,
    required super.heureDepart,
    super.dateArrivee,
    super.heureArrivee,
    super.dureeEstimee,
    super.montantTotal,
    super.fraisPeage,
    super.distanceKm,
    super.motifRefus,
    super.motifAnnulation,
    super.annulePar,
    super.dateCreation,
    super.dateAcceptationAgent,
    super.dateConfirmationAdherent,
    super.dateAnnulation,
    super.mission,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    // Parse mission
    MissionSimple? mission;
    if (json['mission'] != null) {
      final m = json['mission'] as Map<String, dynamic>;
      mission = MissionSimple(
        villeDepart:  m['adresseDepart']?['villeNom'] as String?,
        villeArrivee: m['adresseArrivee']?['villeNom'] as String?,
      );
    }

    // Parse montants (peuvent être String ou num selon le backend)
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return ReservationModel(
      id:                         json['id'] as String,
      missionId:                  json['missionId'] as String,
      numeroReservation:          json['numeroReservation'] as String,
      statut:                     json['statut'] as String,
      statutPrecedent:            json['statutPrecedent'] as String?,
      dateDepart:                 json['dateDepart'] as String,
      heureDepart:                json['heureDepart'] as String,
      dateArrivee:                json['dateArrivee'] as String?,
      heureArrivee:               json['heureArrivee'] as String?,
      dureeEstimee:               parseInt(json['dureeEstimee']),
      montantTotal:               parseDouble(json['montantTotal']),
      fraisPeage:                 parseDouble(json['fraisPeage']),
      distanceKm:                 parseDouble(json['distanceKm']),
      motifRefus:                 json['motifRefus'] as String?,
      motifAnnulation:            json['motifAnnulation'] as String?,
      annulePar:                  json['annulePar'] as String?,
      dateCreation:               json['dateCreation'] as String?,
      dateAcceptationAgent:       json['dateAcceptationAgent'] as String?,
      dateConfirmationAdherent:   json['dateConfirmationAdherent'] as String?,
      dateAnnulation:             json['dateAnnulation'] as String?,
      mission:                    mission,
    );
  }
}
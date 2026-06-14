// lib/features/missions/data/models/reservation_model.dart

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
    super.dateValidation,
    super.dateAcceptationAgent,
    super.dateConfirmationAdherent,
    super.dateAnnulation,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String,
      missionId: json['missionId'] as String,
      numeroReservation: json['numeroReservation'] as String,
      statut: json['statut'] as String,
      statutPrecedent: json['statutPrecedent'] as String?,
      dateDepart: json['dateDepart'] as String,
      heureDepart: json['heureDepart'] as String,
      dateArrivee: json['dateArrivee'] as String?,
      heureArrivee: json['heureArrivee'] as String?,
      dureeEstimee: json['dureeEstimee'] as int?,
      montantTotal: _toDouble(json['montantTotal']),
      fraisPeage: _toDouble(json['fraisPeage']),
      distanceKm: _toDouble(json['distanceKm']),
      motifRefus: json['motifRefus'] as String?,
      motifAnnulation: json['motifAnnulation'] as String?,
      annulePar: json['annulePar'] as String?,
      dateCreation: json['dateCreation'] as String?,
      dateValidation: json['dateValidation'] as String?,
      dateAcceptationAgent: json['dateAcceptationAgent'] as String?,
      dateConfirmationAdherent: json['dateConfirmationAdherent'] as String?,
      dateAnnulation: json['dateAnnulation'] as String?,
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

class ReservationResponseModel extends ReservationResponseEntity {
  const ReservationResponseModel({
    required super.success,
    required super.message,
    super.code,
    super.reservation,
  });

  factory ReservationResponseModel.fromJson(Map<String, dynamic> json) {
    return ReservationResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String,
      code: json['code'] as String?,
      reservation: json['reservation'] != null
          ? ReservationModel.fromJson(
              json['reservation'] as Map<String, dynamic>)
          : null,
    );
  }
}
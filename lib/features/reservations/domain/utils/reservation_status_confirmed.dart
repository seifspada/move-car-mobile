// lib/features/reservations/domain/utils/reservation_status_confirmed.dart

import 'package:convoyeur_mobile/features/reservations/domain/entities/reservation_entity.dart'; // ✅ corrigé

extension ReservationStatusX on ReservationEntity {
  /// Date/heure de départ combinée (dateDepart + heureDepart), ou null
  /// si le parsing échoue.
  DateTime? get departDate {
    try {
      final datePart =
          DateTime.parse(dateDepart).toIso8601String().split('T')[0];
      return DateTime.parse('${datePart}T$heureDepart:00');
    } catch (_) {
      return null;
    }
  }

  /// True si la réservation est confirmée par l'adhérent ET que
  /// l'heure de départ est passée → le bouton "Launch Mission"
  /// doit être affiché.
  bool get isMissionReady {
    final d = departDate;
    if (d == null) return false;
    return statut == 'CONFIRMED_BY_ADHERENT' && DateTime.now().isAfter(d);
  }

  /// Mission actuellement en cours d'exécution.
  bool get isEnCours => statut == 'EN_COURS';

  /// Mission terminée.
  bool get isTerminee => statut == 'TERMINEE';
}
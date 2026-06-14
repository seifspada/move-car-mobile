class MissionIncidentMediaEntity {
  final String id;
  final String cheminFichier;
  final int tailleOctets;
  final int ordre;

  const MissionIncidentMediaEntity({
    required this.id,
    required this.cheminFichier,
    required this.tailleOctets,
    required this.ordre,
  });
}

class MissionIncidentEntity {
  final String id;
  final String sessionId;
  final String typeIncident;
  final String description;
  final double latitude;
  final double longitude;
  final List<MissionIncidentMediaEntity> medias;
  final String? resolvedBy;
  final String? resolutionNotes;
  final DateTime? dateResolution;
  final DateTime dateCreation;

  const MissionIncidentEntity({
    required this.id,
    required this.sessionId,
    required this.typeIncident,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.medias,
    this.resolvedBy,
    this.resolutionNotes,
    this.dateResolution,
    required this.dateCreation,
  });
}
// lib/features/missions/domain/entities/mission_entity.dart

import 'package:equatable/equatable.dart';

// ==========================================
// 🎯 MISSION ENTITY (Principal)
// ==========================================

class MissionEntity extends Equatable {
  final String id;
  final String statut;
  final String typeVehicule;
  final String typeCarburant;
  final String villeDepart;
  final String villeArrivee;
  final double distanceKm;
  final double fraisPeage;
  final double montantTotal;
  final DateTime dateDebut;
  final DateTime? dateDepartMax;

  const MissionEntity({
    required this.id,
    required this.statut,
    required this.typeVehicule,
    required this.typeCarburant,
    required this.villeDepart,
    required this.villeArrivee,
    required this.distanceKm,
    required this.fraisPeage,
    required this.montantTotal,
    required this.dateDebut,
    this.dateDepartMax,
  });

  @override
  List<Object?> get props => [
    id,
    statut,
    typeVehicule,
    typeCarburant,
    villeDepart,
    villeArrivee,
    distanceKm,
    fraisPeage,
    montantTotal,
    dateDebut,
    dateDepartMax,
  ];

  // ✅ Getters pour formatage
  String get formattedPrice => '${montantTotal.toStringAsFixed(2)}€';
  String get formattedTollFee => '${fraisPeage.toStringAsFixed(2)}€';
  String get formattedDistance => '${distanceKm.toStringAsFixed(0)} km';

  String get formattedDateRange {
    final start = dateDebut.toString().split(' ')[0];
    if (dateDepartMax != null) {
      final end = dateDepartMax!.toString().split(' ')[0];
      return '$start - $end';
    }
    return start;
  }

  // ✅ Méthode copy
  MissionEntity copyWith({
    String? id,
    String? statut,
    String? typeVehicule,
    String? typeCarburant,
    String? villeDepart,
    String? villeArrivee,
    double? distanceKm,
    double? fraisPeage,
    double? montantTotal,
    DateTime? dateDebut,
    DateTime? dateDepartMax,
  }) {
    return MissionEntity(
      id: id ?? this.id,
      statut: statut ?? this.statut,
      typeVehicule: typeVehicule ?? this.typeVehicule,
      typeCarburant: typeCarburant ?? this.typeCarburant,
      villeDepart: villeDepart ?? this.villeDepart,
      villeArrivee: villeArrivee ?? this.villeArrivee,
      distanceKm: distanceKm ?? this.distanceKm,
      fraisPeage: fraisPeage ?? this.fraisPeage,
      montantTotal: montantTotal ?? this.montantTotal,
      dateDebut: dateDebut ?? this.dateDebut,
      dateDepartMax: dateDepartMax ?? this.dateDepartMax,
    );
  }

  @override
  String toString() => 'MissionEntity(id: $id, $villeDepart → $villeArrivee, $formattedPrice)';
}

// ==========================================
// 📊 MISSIONS PAGINATED RESPONSE ENTITY
// ==========================================

class MissionsPaginatedResponseEntity extends Equatable {
  final List<MissionEntity> missions;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const MissionsPaginatedResponseEntity({
    required this.missions,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [missions, total, page, pageSize, totalPages];

  // ✅ Getters utiles
  bool get isEmpty => missions.isEmpty;
  bool get isNotEmpty => missions.isNotEmpty;
  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;

  @override
  String toString() => 'MissionsPaginatedResponseEntity(total: $total, page: $page/$totalPages)';
}

// ==========================================
// 🏙️ SELECTED CITY ENTITY
// ==========================================

class SelectedCityEntity extends Equatable {
  final String name;
  final double lat;
  final double lon;

  const SelectedCityEntity({
    required this.name,
    required this.lat,
    required this.lon,
  });

  @override
  List<Object?> get props => [name, lat, lon];

  // ✅ Validation
  bool get isValid => name.isNotEmpty && lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;

  // ✅ Copy
  SelectedCityEntity copyWith({
    String? name,
    double? lat,
    double? lon,
  }) {
    return SelectedCityEntity(
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
    );
  }

  @override
  String toString() => 'SelectedCityEntity($name: $lat, $lon)';
}

// ==========================================
// 🔔 MISSION ALERT ENTITY
// ==========================================

class MissionAlertEntity extends Equatable {
  final String type; // 'GEOGRAPHIQUE' ou 'TRAJET'
  final String? villeNom;
  final double? latitude;
  final double? longitude;
  final double? rayon;
  // Pour TRAJET
  final String? villeDepartNom;
  final double? latitudeDepart;
  final double? longitudeDepart;
  final String? villeArriveeNom;
  final double? latitudeArrivee;
  final double? longitudeArrivee;
  final String? dateDepart;
  final String? dateRetour;

  const MissionAlertEntity({
    required this.type,
    this.villeNom,
    this.latitude,
    this.longitude,
    this.rayon,
    this.villeDepartNom,
    this.latitudeDepart,
    this.longitudeDepart,
    this.villeArriveeNom,
    this.latitudeArrivee,
    this.longitudeArrivee,
    this.dateDepart,
    this.dateRetour,
  });

  @override
  List<Object?> get props => [
    type,
    villeNom,
    latitude,
    longitude,
    rayon,
    villeDepartNom,
    latitudeDepart,
    longitudeDepart,
    villeArriveeNom,
    latitudeArrivee,
    longitudeArrivee,
    dateDepart,
    dateRetour,
  ];

  // ✅ Factories pour les deux types
  factory MissionAlertEntity.geographique({
    required String villeNom,
    required double latitude,
    required double longitude,
    required double rayon,
  }) {
    return MissionAlertEntity(
      type: 'GEOGRAPHIQUE',
      villeNom: villeNom,
      latitude: latitude,
      longitude: longitude,
      rayon: rayon,
    );
  }

  factory MissionAlertEntity.trajet({
    required String villeDepartNom,
    required double latitudeDepart,
    required double longitudeDepart,
    required String villeArriveeNom,
    required double latitudeArrivee,
    required double longitudeArrivee,
    required double rayon,
    String? dateDepart,
    String? dateRetour,
  }) {
    return MissionAlertEntity(
      type: 'TRAJET',
      villeDepartNom: villeDepartNom,
      latitudeDepart: latitudeDepart,
      longitudeDepart: longitudeDepart,
      villeArriveeNom: villeArriveeNom,
      latitudeArrivee: latitudeArrivee,
      longitudeArrivee: longitudeArrivee,
      rayon: rayon,
      dateDepart: dateDepart,
      dateRetour: dateRetour,
    );
  }

  // ✅ Conversion vers Map (pour API)
  Map<String, dynamic> toJson() {
    if (type == 'GEOGRAPHIQUE') {
      return {
        'type': 'GEOGRAPHIQUE',
        'villeNom': villeNom,
        'latitude': latitude,
        'longitude': longitude,
        'rayon': rayon,
      };
    } else {
      return {
        'type': 'TRAJET',
        'villeDepartNom': villeDepartNom,
        'latitudeDepart': latitudeDepart,
        'longitudeDepart': longitudeDepart,
        'villeArriveeNom': villeArriveeNom,
        'latitudeArrivee': latitudeArrivee,
        'longitudeArrivee': longitudeArrivee,
        'rayon': rayon,
        if (dateDepart != null) 'dateDepart': dateDepart,
        if (dateRetour != null) 'dateRetour': dateRetour,
      };
    }
  }

  @override
  String toString() => 'MissionAlertEntity(type: $type, rayon: $rayon)';
}

// ==========================================
// 🔍 SEARCH FILTER ENTITY
// ==========================================

class SearchFilterEntity extends Equatable {
  final SelectedCityEntity? villeDepart;
  final SelectedCityEntity? villeArrivee;
  final double rayon;
  final DateTime? dateDepart;
  final DateTime? dateRetour;

  const SearchFilterEntity({
    this.villeDepart,
    this.villeArrivee,
    required this.rayon,
    this.dateDepart,
    this.dateRetour,
  });

  @override
  List<Object?> get props => [
    villeDepart,
    villeArrivee,
    rayon,
    dateDepart,
    dateRetour,
  ];

  // ✅ Validation
  bool get isValidTrajet => villeDepart != null && villeArrivee != null;
  bool get isValidPosition => villeDepart != null;

  // ✅ Copy
  SearchFilterEntity copyWith({
    SelectedCityEntity? villeDepart,
    SelectedCityEntity? villeArrivee,
    double? rayon,
    DateTime? dateDepart,
    DateTime? dateRetour,
  }) {
    return SearchFilterEntity(
      villeDepart: villeDepart ?? this.villeDepart,
      villeArrivee: villeArrivee ?? this.villeArrivee,
      rayon: rayon ?? this.rayon,
      dateDepart: dateDepart ?? this.dateDepart,
      dateRetour: dateRetour ?? this.dateRetour,
    );
  }

  @override
  String toString() => 'SearchFilterEntity(rayon: $rayon)';
}

// ==========================================
// 📍 MAP POINT ENTITY
// ==========================================

class MapPointEntity extends Equatable {
  final double lat;
  final double lon;
  final double radiusMeters;
  final String color;
  final String label;

  const MapPointEntity({
    required this.lat,
    required this.lon,
    required this.radiusMeters,
    required this.color,
    required this.label,
  });

  @override
  List<Object?> get props => [lat, lon, radiusMeters, color, label];

  @override
  String toString() => 'MapPointEntity($label: $lat, $lon)';
}

// ==========================================
// 🏘️ COMMUNE ENTITY
// ==========================================

class CommuneEntity extends Equatable {
  final String nom;
  final double? latitude;
  final double? longitude;
  final List<String>? codesPostaux;

  const CommuneEntity({
    required this.nom,
    this.latitude,
    this.longitude,
    this.codesPostaux,
  });

  @override
  List<Object?> get props => [nom, latitude, longitude, codesPostaux];

  // ✅ Validation
  bool get isValid => nom.isNotEmpty && latitude != null && longitude != null;

  // ✅ Conversion vers SelectedCityEntity
  SelectedCityEntity? toSelectedCity() {
    if (isValid) {
      return SelectedCityEntity(
        name: nom,
        lat: latitude!,
        lon: longitude!,
      );
    }
    return null;
  }

  @override
  String toString() => 'CommuneEntity($nom)';
}

// ==========================================
// 📋 SEARCH POSITION FILTER ENTITY
// ==========================================

class SearchPositionFilterEntity extends Equatable {
  final String villeNom;
  final double latitude;
  final double longitude;
  final double rayon;

  const SearchPositionFilterEntity({
    required this.villeNom,
    required this.latitude,
    required this.longitude,
    required this.rayon,
  });

  @override
  List<Object?> get props => [villeNom, latitude, longitude, rayon];

  Map<String, dynamic> toJson() => {
    'villeNom': villeNom,
    'latitude': latitude,
    'longitude': longitude,
    'rayon': rayon,
  };

  @override
  String toString() => 'SearchPositionFilterEntity($villeNom, rayon: $rayon)';
}

// ==========================================
// 🛣️ SEARCH TRAJET FILTER ENTITY
// ==========================================

class SearchTrajetFilterEntity extends Equatable {
  final String villeDepartNom;
  final double latitudeDepart;
  final double longitudeDepart;
  final String villeArriveeNom;
  final double latitudeArrivee;
  final double longitudeArrivee;
  final double rayon;
  final String? dateDepart;
  final String? dateDepartMax;

  const SearchTrajetFilterEntity({
    required this.villeDepartNom,
    required this.latitudeDepart,
    required this.longitudeDepart,
    required this.villeArriveeNom,
    required this.latitudeArrivee,
    required this.longitudeArrivee,
    required this.rayon,
    this.dateDepart,
    this.dateDepartMax,
  });

  @override
  List<Object?> get props => [
    villeDepartNom,
    latitudeDepart,
    longitudeDepart,
    villeArriveeNom,
    latitudeArrivee,
    longitudeArrivee,
    rayon,
    dateDepart,
    dateDepartMax,
  ];

  Map<String, dynamic> toJson() => {
    'villeDepartNom': villeDepartNom,
    'latitudeDepart': latitudeDepart,
    'longitudeDepart': longitudeDepart,
    'villeArriveeNom': villeArriveeNom,
    'latitudeArrivee': latitudeArrivee,
    'longitudeArrivee': longitudeArrivee,
    'rayon': rayon,
    if (dateDepart != null) 'dateDepart': dateDepart,
    if (dateDepartMax != null) 'dateDepartMax': dateDepartMax,
  };

  @override
  String toString() =>
    'SearchTrajetFilterEntity($villeDepartNom → $villeArriveeNom, rayon: $rayon)';
}
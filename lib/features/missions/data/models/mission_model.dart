// lib/features/missions/data/models/mission_model.dart

import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

// ==========================================
// 🎯 MISSION MODEL
// ==========================================

class MissionModel {
  final String id;
  final String statut;
  final String typeVehicule;
  final String typeCarburant;
  final String villeDepart;
  final String villeArrivee;
  final double distanceKm;
  final double fraisPeage;
  final double montantTotal;
  final DateTime? dateDebut;
  final DateTime? dateDepartMax;

  MissionModel({
    required this.id,
    required this.statut,
    required this.typeVehicule,
    required this.typeCarburant,
    required this.villeDepart,
    required this.villeArrivee,
    required this.distanceKm,
    required this.fraisPeage,
    required this.montantTotal,
    this.dateDebut,
    this.dateDepartMax,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id:            json['id']            as String? ?? '',
      statut:        json['statut']        as String? ?? 'EN_ATTENTE',
      typeVehicule:  json['typeVehicule']  as String? ?? 'VOITURE',
      typeCarburant: json['typeCarburant'] as String? ?? 'ESSENCE',
      villeDepart:   json['villeDepart']   as String? ?? 'N/A',
      villeArrivee:  json['villeArrivee']  as String? ?? 'N/A',
      distanceKm:    (json['distanceKm']   as num?)?.toDouble() ?? 0.0,
      fraisPeage:    (json['fraisPeage']   as num?)?.toDouble() ?? 0.0,
      montantTotal:  (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      dateDebut: json['dateDebut'] != null
          ? DateTime.tryParse(json['dateDebut'] as String)
          : null,
      dateDepartMax: json['dateDepartMax'] != null
          ? DateTime.tryParse(json['dateDepartMax'] as String)
          : null,
    );
  }

  String get formattedPrice    => '${montantTotal.toStringAsFixed(2)}€';
  String get formattedTollFee  => '${fraisPeage.toStringAsFixed(2)}€';
  String get formattedDistance => '${distanceKm.toStringAsFixed(0)} km';

  String get formattedDateRange {
    if (dateDebut == null) return 'N/A';
    try {
      final formatter = DateFormat('d MMM', 'fr_FR');
      final startDate = formatter.format(dateDebut!);
      if (dateDepartMax != null) {
        return '$startDate - ${formatter.format(dateDepartMax!)}';
      }
      return startDate;
    } catch (_) {
      final formatter = DateFormat('dd/MM/yyyy');
      final startDate = formatter.format(dateDebut!);
      if (dateDepartMax != null) {
        return '$startDate - ${formatter.format(dateDepartMax!)}';
      }
      return startDate;
    }
  }
}

// ==========================================
// 📊 MISSIONS PAGINATED RESPONSE
// ==========================================

class MissionsPaginatedResponse {
  final List<MissionModel> missions;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  MissionsPaginatedResponse({
    required this.missions,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory MissionsPaginatedResponse.fromJson(Map<String, dynamic> json) {
    return MissionsPaginatedResponse(
      missions: (json['missions'] as List<dynamic>)
          .map((m) => MissionModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      total:      json['total']      as int,
      page:       json['page']       as int,
      pageSize:   json['pageSize']   as int,
      totalPages: json['totalPages'] as int,
    );
  }
}

// ==========================================
// 🏙️ SELECTED CITY MODEL
// ==========================================

class SelectedCityModel {
  final String name;
  final double lat;
  final double lon;

  SelectedCityModel({
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory SelectedCityModel.fromJson(Map<String, dynamic> json) {
    return SelectedCityModel(
      name: json['name'] as String,
      lat:  (json['lat'] as num).toDouble(),
      lon:  (json['lon'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'lat':  lat,
    'lon':  lon,
  };
}

// ==========================================
// 🔍 SEARCH POSITION FILTER
// ==========================================

class SearchPositionFilter {
  final String villeNom;
  final double latitude;
  final double longitude;
  final double rayon;

  SearchPositionFilter({
    required this.villeNom,
    required this.latitude,
    required this.longitude,
    required this.rayon,
  });

  Map<String, dynamic> toJson() => {
    'villeNom':  villeNom,
    'latitude':  latitude,
    'longitude': longitude,
    'rayon':     rayon,
  };
}

// ==========================================
// 🛣️ SEARCH TRAJET FILTER
// ==========================================

class SearchTrajetFilter {
  final String villeDepartNom;
  final double latitudeDepart;
  final double longitudeDepart;
  final String villeArriveeNom;
  final double latitudeArrivee;
  final double longitudeArrivee;
  final double rayon;
  final String? dateDepart;
  final String? dateDepartMax;

  SearchTrajetFilter({
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

  Map<String, dynamic> toJson() => {
    'villeDepartNom':  villeDepartNom,
    'latitudeDepart':  latitudeDepart,
    'longitudeDepart': longitudeDepart,
    'villeArriveeNom':  villeArriveeNom,
    'latitudeArrivee':  latitudeArrivee,
    'longitudeArrivee': longitudeArrivee,
    'rayon': rayon,
    if (dateDepart    != null) 'dateDepart':    dateDepart,
    if (dateDepartMax != null) 'dateDepartMax': dateDepartMax,
  };
}

// ==========================================
// 🔔 MISSION ALERT
// ==========================================

class MissionAlert {
  final String type;
  final bool emailActif;
  final bool pushActif;
  final String? fcmToken;

  // GEOGRAPHIQUE
  final String? villeNom;
  final double? latitude;
  final double? longitude;
  final double? rayon;

  // TRAJET
  final String? villeDepartNom;
  final double? latitudeDepart;
  final double? longitudeDepart;
  final String? villeArriveeNom;
  final double? latitudeArrivee;
  final double? longitudeArrivee;
  final String? dateDepart;
  final String? dateRetour;

  MissionAlert.geographique({
    required String villeNom,
    required double latitude,
    required double longitude,
    required double rayon,
    bool? pushActif,
    bool? emailActif,
    this.fcmToken,
    String? dateDepart,   // ✅ ajout
    String? dateRetour,   // ✅ ajout
  })  : type             = 'GEOGRAPHIQUE',
        emailActif       = emailActif ?? (kIsWeb ? true : false),
        pushActif        = pushActif  ?? (kIsWeb ? false : true),
        villeNom         = villeNom,
        latitude         = latitude,
        longitude        = longitude,
        rayon            = rayon,
        villeDepartNom   = null,
        latitudeDepart   = null,
        longitudeDepart  = null,
        villeArriveeNom  = null,
        latitudeArrivee  = null,
        longitudeArrivee = null,
        dateDepart       = dateDepart,   // ✅
        dateRetour       = dateRetour;   // ✅

  MissionAlert.trajet({
    required String villeDepartNom,
    required double latitudeDepart,
    required double longitudeDepart,
    required String villeArriveeNom,
    required double latitudeArrivee,
    required double longitudeArrivee,
    required double rayon,
    String? dateDepart,
    String? dateRetour,
    bool? pushActif,
    bool? emailActif,
    this.fcmToken,
  })  : type             = 'TRAJET',
        emailActif       = emailActif ?? (kIsWeb ? true : false),
        pushActif        = pushActif  ?? (kIsWeb ? false : true),
        villeNom         = null,
        latitude         = null,
        longitude        = null,
        rayon            = rayon,
        villeDepartNom   = villeDepartNom,
        latitudeDepart   = latitudeDepart,
        longitudeDepart  = longitudeDepart,
        villeArriveeNom  = villeArriveeNom,
        latitudeArrivee  = latitudeArrivee,
        longitudeArrivee = longitudeArrivee,
        dateDepart       = dateDepart,
        dateRetour       = dateRetour;

  Map<String, dynamic> toJson() {
    final base = {
      'emailActif': emailActif,
      'pushActif':  pushActif,
      'rayon':      rayon,
      if (fcmToken   != null) 'fcmToken':   fcmToken,
      if (dateDepart != null) 'dateDepart': dateDepart,  // ✅ ajout
      if (dateRetour != null) 'dateRetour': dateRetour,  // ✅ ajout
    };

    if (type == 'GEOGRAPHIQUE') {
      return {
        ...base,
        'villeNom':  villeNom,
        'latitude':  latitude,
        'longitude': longitude,
      };
    } else {
      return {
        ...base,
        'villeDepartNom':  villeDepartNom,
        'latitudeDepart':  latitudeDepart,
        'longitudeDepart': longitudeDepart,
        'villeArriveeNom':  villeArriveeNom,
        'latitudeArrivee':  latitudeArrivee,
        'longitudeArrivee': longitudeArrivee,
      };
    }
  }
}

// ==========================================
// 📋 ALERTE MODEL (pour le panneau notifications)
// ==========================================

class AlerteModel {
  final String id;
  final String type;       // 'GEOGRAPHIQUE' | 'TRAJET'
  final bool actif;
  final bool emailActif;
  final bool pushActif;
  final double? rayon;

  // GEOGRAPHIQUE
  final String? villeNom;
  final double? latitude;
  final double? longitude;

  // TRAJET
  final String? villeDepartNom;
  final double? latitudeDepart;
  final double? longitudeDepart;
  final String? villeArriveeNom;
  final double? latitudeArrivee;
  final double? longitudeArrivee;

  final String? dateDepart;
  final String? dateDepartMax;
  final String? dateCreation;

  AlerteModel({
    required this.id,
    required this.type,
    required this.actif,
    required this.emailActif,
    required this.pushActif,
    this.rayon,
    this.villeNom,
    this.latitude,
    this.longitude,
    this.villeDepartNom,
    this.latitudeDepart,
    this.longitudeDepart,
    this.villeArriveeNom,
    this.latitudeArrivee,
    this.longitudeArrivee,
    this.dateDepart,
    this.dateDepartMax,
    this.dateCreation,
  });

  factory AlerteModel.fromJson(Map<String, dynamic> json) {
    return AlerteModel(
      id:               json['id']               as String? ?? '',
      type:             json['type']             as String? ?? 'GEOGRAPHIQUE',
      actif:            json['actif']            as bool?   ?? true,
      emailActif:       json['emailActif']       as bool?   ?? false,
      pushActif:        json['pushActif']        as bool?   ?? false,
      rayon:            (json['rayon'] as num?)?.toDouble(),
      villeNom:         json['villeNom']         as String?,
      latitude:         (json['latitude'] as num?)?.toDouble(),
      longitude:        (json['longitude'] as num?)?.toDouble(),
      villeDepartNom:   json['villeDepartNom']   as String?,
      latitudeDepart:   (json['latitudeDepart'] as num?)?.toDouble(),
      longitudeDepart:  (json['longitudeDepart'] as num?)?.toDouble(),
      villeArriveeNom:  json['villeArriveeNom']  as String?,
      latitudeArrivee:  (json['latitudeArrivee'] as num?)?.toDouble(),
      longitudeArrivee: (json['longitudeArrivee'] as num?)?.toDouble(),
      dateDepart:       json['dateDepart']       as String?,
      dateDepartMax:    json['dateDepartMax']    as String?,
      dateCreation:     json['dateCreation']     as String?,
    );
  }

  /// Label court pour affichage
  String get displayTitle {
    if (type == 'TRAJET') {
      return '${villeDepartNom ?? '?'} → ${villeArriveeNom ?? '?'}';
    }
    return villeNom ?? 'Position';
  }

  /// Sous-titre
  String get displaySubtitle {
    final r = rayon != null ? '${rayon!.toInt()} km' : '';
    if (type == 'TRAJET') {
      return 'Alerte trajet • $r';
    }
    return 'Alerte géographique • $r';
  }

  /// Date formatée
  String get formattedDate {
    if (dateCreation == null) return '';
    try {
      final dt = DateTime.parse(dateCreation!);
      return '${dt.day.toString().padLeft(2, '0')}/'
             '${dt.month.toString().padLeft(2, '0')}/'
             '${dt.year}';
    } catch (_) {
      return dateCreation ?? '';
    }
  }
}

// ==========================================
// 📍 COMMUNE MODEL
// ==========================================

class CommuneModel {
  final String nom;
  final double? latitude;
  final double? longitude;
  final List<String>? codesPostaux;

  CommuneModel({
    required this.nom,
    this.latitude,
    this.longitude,
    this.codesPostaux,
  });

  factory CommuneModel.fromJson(Map<String, dynamic> json) {
    final centre = json['centre'] as Map<String, dynamic>?;
    List<double>? coordinates;

    if (centre != null && centre['coordinates'] is List) {
      final coords = centre['coordinates'] as List<dynamic>;
      if (coords.length >= 2) {
        coordinates = [
          (coords[1] as num).toDouble(),
          (coords[0] as num).toDouble(),
        ];
      }
    }

    return CommuneModel(
      nom:          json['nom'] as String,
      latitude:     coordinates?[0],
      longitude:    coordinates?[1],
      codesPostaux: json['codesPostaux'] != null
          ? List<String>.from(json['codesPostaux'] as List<dynamic>)
          : null,
    );
  }
}

// ==========================================
// 📍 MAP POINT MODEL
// ==========================================

class MapPointModel {
  final double lat;
  final double lon;
  final double radiusMeters;
  final String color;
  final String label;

  MapPointModel({
    required this.lat,
    required this.lon,
    required this.radiusMeters,
    required this.color,
    required this.label,
  });
}

// ==========================================
// 🎯 ENUMS
// ==========================================

enum SearchMode {
  text,
  position,
  trajet,
}
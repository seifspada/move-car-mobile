// lib/features/missions/data/models/mission_model.dart

import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/mission_entity.dart';

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
  final bool isFavori; // ✅ Ajouté

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
    this.isFavori = false, // ✅ false par défaut
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id:            _stringFromJson(json['id']),
      statut:        _stringFromJson(json['statut'], 'EN_ATTENTE'),
      typeVehicule:  _stringFromJson(json['typeVehicule'], 'VOITURE'),
      typeCarburant: _stringFromJson(json['typeCarburant'], 'ESSENCE'),
      villeDepart:   _stringFromJson(json['villeDepart'], 'N/A'),
      villeArrivee:  _stringFromJson(json['villeArrivee'], 'N/A'),
      distanceKm:    (json['distanceKm']   as num?)?.toDouble() ?? 0.0,
      fraisPeage:    (json['fraisPeage']   as num?)?.toDouble() ?? 0.0,
      montantTotal:  (json['montantTotal'] as num?)?.toDouble() ?? 0.0,
      isFavori:      json['isFavori']      as bool? ?? false, // ✅
      dateDebut: json['dateDebut'] != null
          ? DateTime.tryParse(_stringFromJson(json['dateDebut']))
          : null,
      dateDepartMax: json['dateDepartMax'] != null
          ? DateTime.tryParse(_stringFromJson(json['dateDepartMax']))
          : null,
    );
  }

  // ✅ copyWith pour rollback optimiste si besoin
  MissionModel copyWith({
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
    bool? isFavori,
  }) {
    return MissionModel(
      id:            id            ?? this.id,
      statut:        statut        ?? this.statut,
      typeVehicule:  typeVehicule  ?? this.typeVehicule,
      typeCarburant: typeCarburant ?? this.typeCarburant,
      villeDepart:   villeDepart   ?? this.villeDepart,
      villeArrivee:  villeArrivee  ?? this.villeArrivee,
      distanceKm:    distanceKm    ?? this.distanceKm,
      fraisPeage:    fraisPeage    ?? this.fraisPeage,
      montantTotal:  montantTotal  ?? this.montantTotal,
      dateDebut:     dateDebut     ?? this.dateDebut,
      dateDepartMax: dateDepartMax ?? this.dateDepartMax,
      isFavori:      isFavori      ?? this.isFavori,
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
      name: _stringFromJson(json['name']),
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
    String? dateDepart,
    String? dateRetour,
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
        dateDepart       = dateDepart,
        dateRetour       = dateRetour;

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
      if (dateDepart != null) 'dateDepart': dateDepart,
      if (dateRetour != null) 'dateRetour': dateRetour,
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
// 📋 ALERTE MODEL
// ==========================================

class AlerteModel {
  final String id;
  final String type;
  final bool actif;
  final bool emailActif;
  final bool pushActif;
  final double? rayon;

  final String? villeNom;
  final double? latitude;
  final double? longitude;

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
      id:               _stringFromJson(json['id']),
      type:             _stringFromJson(json['type'], 'GEOGRAPHIQUE'),
      actif:            json['actif']            as bool?   ?? true,
      emailActif:       json['emailActif']       as bool?   ?? false,
      pushActif:        json['pushActif']        as bool?   ?? false,
      rayon:            (json['rayon'] as num?)?.toDouble(),
      villeNom:         json['villeNom'] != null ? _stringFromJson(json['villeNom']) : null,
      latitude:         (json['latitude'] as num?)?.toDouble(),
      longitude:        (json['longitude'] as num?)?.toDouble(),
      villeDepartNom:   json['villeDepartNom'] != null ? _stringFromJson(json['villeDepartNom']) : null,
      latitudeDepart:   (json['latitudeDepart'] as num?)?.toDouble(),
      longitudeDepart:  (json['longitudeDepart'] as num?)?.toDouble(),
      villeArriveeNom:  json['villeArriveeNom'] != null ? _stringFromJson(json['villeArriveeNom']) : null,
      latitudeArrivee:  (json['latitudeArrivee'] as num?)?.toDouble(),
      longitudeArrivee: (json['longitudeArrivee'] as num?)?.toDouble(),
      dateDepart:       json['dateDepart'] != null ? _stringFromJson(json['dateDepart']) : null,
      dateDepartMax:    json['dateDepartMax'] != null ? _stringFromJson(json['dateDepartMax']) : null,
      dateCreation:     json['dateCreation'] != null ? _stringFromJson(json['dateCreation']) : null,
    );
  }

  String get displayTitle {
    if (type == 'TRAJET') {
      return '${villeDepartNom ?? '?'} → ${villeArriveeNom ?? '?'}';
    }
    return villeNom ?? 'Position';
  }

  String get displaySubtitle {
    final r = rayon != null ? '${rayon!.toInt()} km' : '';
    if (type == 'TRAJET') return 'Alerte trajet • $r';
    return 'Alerte géographique • $r';
  }

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
      nom:          _stringFromJson(json['nom']),
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

enum SearchMode { text, position, trajet }

// ==========================================
// 📦 MODELS DETAIL
// ==========================================

class PartenaireModel extends Partenaire {
  const PartenaireModel({
    required super.id,
    required super.nom,
    required super.prenom,
    required super.entiteGroupe,
    super.entiteAgence,
    required super.email,
    required super.telephone,
    super.logo,
  });

  factory PartenaireModel.fromJson(Map<String, dynamic> j) => PartenaireModel(
        id: _intFromJson(j['id']),
        nom: _stringFromJson(j['nom']),
        prenom: _stringFromJson(j['prenom']),
        entiteGroupe: _stringFromJson(j['entiteGroupe'], 'Partenaire'),
        entiteAgence:
            j['entiteAgence'] != null ? _stringFromJson(j['entiteAgence']) : null,
        email: _stringFromJson(j['email']),
        telephone: _stringFromJson(j['telephone']),
        logo: j['logo'] != null ? _stringFromJson(j['logo']) : null,
      );
}

int _intFromJson(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

String _stringFromJson(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

class AdresseModel extends Adresse {
  const AdresseModel({
    required super.villeNom,
    required super.adresseComplete,
    required super.typeLieu,
    super.nomLieu,
    super.latitude,
    super.longitude,
  });

  factory AdresseModel.fromJson(Map<String, dynamic> j) => AdresseModel(
        villeNom: _stringFromJson(j['villeNom'], 'Ville inconnue'),
        adresseComplete: _stringFromJson(j['adresseComplete']),
        typeLieu: _stringFromJson(j['typeLieu']),
        nomLieu: j['nomLieu'] != null ? _stringFromJson(j['nomLieu']) : null,
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
      );
}

class VehiculeModel extends Vehicule {
  const VehiculeModel({
    required super.marqueModele,
    required super.immatriculation,
    required super.typeVehicule,
    required super.typeCarburant,
    required super.nombrePlaces,
    super.boiteVitesse,
  });

  factory VehiculeModel.fromJson(Map<String, dynamic> j) => VehiculeModel(
        marqueModele: _stringFromJson(j['marqueModele'], 'Vehicule'),
        immatriculation: _stringFromJson(j['immatriculation']),
        typeVehicule: _stringFromJson(j['typeVehicule']),
        typeCarburant: _stringFromJson(j['typeCarburant']),
        nombrePlaces: _intFromJson(j['nombrePlaces']),
        boiteVitesse:
            j['boiteVitesse'] != null ? _stringFromJson(j['boiteVitesse']) : null,
      );
}

class DisponibiliteModel extends Disponibilite {
  const DisponibiliteModel({
    required super.dateDebut,
    required super.dateFin,
    super.dateDepartMax,
  });

  factory DisponibiliteModel.fromJson(Map<String, dynamic> j) =>
      DisponibiliteModel(
        dateDebut: _stringFromJson(j['dateDebut']),
        dateFin: _stringFromJson(j['dateFin']),
        dateDepartMax: j['dateDepartMax'] != null
            ? _stringFromJson(j['dateDepartMax'])
            : null,
      );
}

class CalculModel extends Calcul {
  const CalculModel({
    required super.distanceKm,
    required super.montantTotal,
    required super.fraisPeage,
  });

  factory CalculModel.fromJson(Map<String, dynamic> j) => CalculModel(
        distanceKm: (j['distanceKm'] as num?)?.toDouble() ?? 0,
        montantTotal: (j['montantTotal'] as num?)?.toDouble() ?? 0,
        fraisPeage: (j['fraisPeage'] as num?)?.toDouble() ?? 0,
      );
}

// data/models/mission_model.dart

class AgentModel extends Agent {
  const AgentModel({
    required super.id,
    required super.nom,
    required super.prenom,
    required super.email,
    super.telephone,
    super.photo,
  });

  factory AgentModel.fromJson(Map<String, dynamic> j) => AgentModel(
    id:         _stringFromJson(j['id']),
    nom:        _stringFromJson(j['nom']),
    prenom:     _stringFromJson(j['prenom']),
    email:      _stringFromJson(j['email']),
    telephone:  j['telephone'] != null ? _stringFromJson(j['telephone']) : null,
    photo:      j['photo'] != null ? _stringFromJson(j['photo']) : null,
  );
}

class NotificationModel extends Notification {
  const NotificationModel({
    required super.id,
    required super.typeNotification,
    required super.actif,
    required super.nomContact,
    required super.telephoneContact,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) =>
      NotificationModel(
        id:                 _stringFromJson(j['id']),
        typeNotification:   _stringFromJson(j['typeNotification']),
        actif:              j['actif']              as bool? ?? false,
        nomContact:         _stringFromJson(j['nomContact']),
        telephoneContact:   _stringFromJson(j['telephoneContact']),
      );
}

class ContratModel extends Contrat {
  const ContratModel({
    required super.prixParKm,
    required super.depassementKilometrage,
    required super.retardSansAvertissement,
    required super.restitutionAutreEndroit,
  });

  factory ContratModel.fromJson(Map<String, dynamic> j) => ContratModel(
    prixParKm:                  (j['prixParKm']                  as num?)?.toDouble() ?? 0,
    depassementKilometrage:     (j['depassementKilometrage']     as num?)?.toDouble() ?? 0,
    retardSansAvertissement:    (j['retardSansAvertissement']    as num?)?.toDouble() ?? 0,
    restitutionAutreEndroit:    (j['restitutionAutreEndroit']    as num?)?.toDouble() ?? 0,
  );
}

class MissionDetailModel extends MissionDetail {
  @override
  final PartenaireModel? partenaire;
  @override
  final AgentModel? agent;
  @override
  final VehiculeModel? vehicule;
  @override
  final AdresseModel? adresseDepart;
  @override
  final AdresseModel? adresseArrivee;
  @override
  final ContratModel? contrat;

  const MissionDetailModel({
    this.partenaire,
    this.agent,
    this.vehicule,
    this.adresseDepart,
    this.adresseArrivee,
    this.contrat,
    required super.id,
    required super.statut,
    super.commentaire,
    required super.dateCreation,
    super.disponibilite,
    super.calculs,
    super.notifications,
    required super.isFavori,
  });

  factory MissionDetailModel.fromJson(Map<String, dynamic> j) =>
      MissionDetailModel(
        id:           _stringFromJson(j['id']),
        statut:       _stringFromJson(j['statut']),
        commentaire:  j['commentaire'] != null ? _stringFromJson(j['commentaire']) : null,
        dateCreation: _stringFromJson(j['dateCreation']),
        isFavori:     j['isFavori']     as bool? ?? false,
        partenaire: j['partenaire'] != null
            ? PartenaireModel.fromJson(j['partenaire'] as Map<String, dynamic>)
            : null,
        agent: j['agent'] != null
            ? AgentModel.fromJson(j['agent'] as Map<String, dynamic>)
            : null,
        vehicule: j['vehicule'] != null
            ? VehiculeModel.fromJson(j['vehicule'] as Map<String, dynamic>)
            : null,
        adresseDepart: j['adresseDepart'] != null
            ? AdresseModel.fromJson(j['adresseDepart'] as Map<String, dynamic>)
            : null,
        adresseArrivee: j['adresseArrivee'] != null
            ? AdresseModel.fromJson(j['adresseArrivee'] as Map<String, dynamic>)
            : null,
        disponibilite: j['disponibilite'] != null
            ? DisponibiliteModel.fromJson(j['disponibilite'] as Map<String, dynamic>)
            : null,
        calculs: j['calculs'] != null
            ? CalculModel.fromJson(j['calculs'] as Map<String, dynamic>)
            : null,
        notifications: (j['notifications'] as List<dynamic>? ?? [])
            .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
            .toList(),
        contrat: j['contrat'] != null
            ? ContratModel.fromJson(j['contrat'] as Map<String, dynamic>)
            : null,
      );
}

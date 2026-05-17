// lib/core/config/mission_icons.dart

import 'package:flutter/material.dart';
import 'package:convoyeur_mobile/app/theme/app_colors.dart';

/// Configuration pour les types de véhicules
/// ✅ Correspondance avec les fichiers RÉELS dans assets/icons/vehicule/
Map<String, dynamic> getVehicleConfig(String typeVehicule) {
  const configs = <String, Map<String, String>>{
    'CITADINE':  {'icon': 'assets/icons/vehicule/voiture-compacte.png',   'label': 'Citadine'},
    'BERLINE':   {'icon': 'assets/icons/vehicule/berline-de-luxe.png',    'label': 'Berline'},
    'COMPACTE':  {'icon': 'assets/icons/vehicule/voiture-compacte.png',   'label': 'Compacte'},
    'SUV':       {'icon': 'assets/icons/vehicule/voiture-suv.png',        'label': 'SUV'},
    'CABRIOLET': {'icon': 'assets/icons/vehicule/cabriolet.png',          'label': 'Cabriolet'},
    'MONOSPACE': {'icon': 'assets/icons/vehicule/monospace.png',          'label': 'Monospace'},
    'LUXE':      {'icon': 'assets/icons/vehicule/lux.png',                'label': 'Luxe'},
    'VU_3M3':    {'icon': 'assets/icons/vehicule/camionette.png',         'label': 'VU 3m³'},
    'VU_6M3':    {'icon': 'assets/icons/vehicule/camionette.png',         'label': 'VU 6m³'},
    'VU_9M3':    {'icon': 'assets/icons/vehicule/camionette.png',         'label': 'VU 9m³'},
    'VU_12M3':   {'icon': 'assets/icons/vehicule/camionette.png',         'label': 'VU 12m³'},
    'VU_15M3':   {'icon': 'assets/icons/vehicule/camionette.png',         'label': 'VU 15m³'},
    'VU_20M3':   {'icon': 'assets/icons/vehicule/camionette.png',         'label': 'VU 20m³'},
    'VU_25M3':   {'icon': 'assets/icons/vehicule/camionette.png',         'label': 'VU 25m³'},
    'VU_30M3':   {'icon': 'assets/icons/vehicule/camionette.png',         'label': 'VU 30m³'},
  };

  return configs[typeVehicule.toUpperCase()] ?? {
    'icon':  'assets/icons/vehicule/carE.png',  // Fallback
    'label': typeVehicule,
  };
}

/// Configuration pour les types de carburants
Map<String, dynamic> getFuelConfig(String typeCarburant) {
  const configs = <String, Map<String, String>>{
    'ESSENCE':    {'image': 'assets/icons/fuel/essance.png',  'label': 'Essence'},
    'DIESEL':     {'image': 'assets/icons/fuel/diesel.png',   'label': 'Diesel'},
    'ELECTRIQUE': {'image': 'assets/icons/fuel/electric.png', 'label': 'Électrique'},
    'HYBRIDE':    {'image': 'assets/icons/fuel/essance.png',  'label': 'Hybride'},
    'GPL':        {'image': 'assets/icons/fuel/essance.png',  'label': 'GPL'},
  };

  return configs[typeCarburant.toUpperCase()] ?? {
    'image': 'assets/icons/fuel/essance.png',
    'label': typeCarburant,
  };
}

/// Couleur pour les statuts de mission
Color getMissionStatusColor(String statut) {
  switch (statut.toUpperCase()) {
    case 'EN_COURS':   return AppColors.primary;
    case 'CONFIRMEE':  return AppColors.success;
    case 'COMPLETEE':  return AppColors.textHint;
    case 'ANNULEE':    return AppColors.error;
    case 'EN_ATTENTE': return AppColors.primaryLight;
    case 'RESERVEE':   return AppColors.primaryDark;
    default:           return AppColors.textHint;
  }
}
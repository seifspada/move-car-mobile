// lib/core/utils/geolocator_service.dart
//
// Service de géolocalisation multiplateforme.
// - Mobile (Android/iOS) : utilise le package geolocator + geocoding
// - Web                  : utilise dart:html via import conditionnel

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// ✅ Import conditionnel — dart:html uniquement sur web
import 'web_geolocation.dart'
    if (dart.library.html) 'web_geolocation_web.dart';

class GeolocatorService {
  // ── Demander la permission (appelé explicitement par l'UI) ────
  static Future<bool> requestLocationPermission() async {
    if (kIsWeb) return true;

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('GeolocatorService: GPS désactivé sur le téléphone');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('GeolocatorService: Permission refusée');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('GeolocatorService: Permission refusée définitivement');
        await Geolocator.openAppSettings();
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('GeolocatorService.requestLocationPermission erreur: $e');
      return false;
    }
  }

  // ── Obtenir la position courante ──────────────────────────────
  static Future<({double latitude, double longitude})?> getCurrentPosition() async {
    if (kIsWeb) {
      return getWebGeolocation();
    }
    return _getMobilePosition();
  }

  // ── Obtenir l'adresse depuis des coordonnées GPS ──────────────
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    // Web : geocoding non disponible nativement → retourne les coords
    if (kIsWeb) {
      return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return null;

      final place = placemarks.first;

      // Construire une adresse lisible
      final parts = <String>[
        if (place.street != null && place.street!.isNotEmpty)
          place.street!,
        if (place.locality != null && place.locality!.isNotEmpty)
          place.locality!,
        if (place.postalCode != null && place.postalCode!.isNotEmpty)
          place.postalCode!,
        if (place.country != null && place.country!.isNotEmpty)
          place.country!,
      ];

      if (parts.isEmpty) return null;
      return parts.join(', ');
    } catch (e) {
      debugPrint('GeolocatorService.getAddressFromCoordinates erreur: $e');
      // Fallback : retourne les coordonnées brutes
      return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
    }
  }

  // ── Mobile (Android / iOS) ────────────────────────────────────
  static Future<({double latitude, double longitude})?> _getMobilePosition() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('GeolocatorService: permission manquante pour getCurrentPosition');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return (
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      debugPrint('GeolocatorService._getMobilePosition erreur: $e');
      return null;
    }
  }

  // ── Stream de position (pour tracking temps réel) ─────────────
  static Stream<({double latitude, double longitude})> positionStream() {
    if (kIsWeb) {
      return const Stream.empty();
    }

    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map((pos) => (latitude: pos.latitude, longitude: pos.longitude));
  }

  // ── Calculer la distance entre deux points (en mètres) ────────
  static double distanceBetween(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
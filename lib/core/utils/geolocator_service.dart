// lib/core/utils/geolocator_service.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'platform_utils.dart';
import 'web_geolocation.dart' if (dart.library.html) 'web_geolocation.dart';

/// Service de geolocalisation adapte a la plateforme.
class GeolocatorService {
  /// Position par defaut pour le web (Tunis, Tunisie).
  static const double defaultLatitude = 36.8065;
  static const double defaultLongitude = 10.1955;

  /// Verifie et active les permissions GPS.
  static Future<bool> requestLocationPermission() async {
    if (PlatformUtils.isWeb) {
      try {
        return await _requestWebLocationPermission();
      } catch (e) {
        debugPrint('Erreur permission GPS web: $e');
        return false;
      }
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      return permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever;
    } catch (e) {
      debugPrint('Erreur permission GPS: $e');
      return false;
    }
  }

  /// Demande la permission de localisation via l'API Web Geolocation.
  static Future<bool> _requestWebLocationPermission() async {
    try {
      if (!kIsWeb) {
        return false;
      }

      return await WebGeolocation.requestPermission();
    } catch (e) {
      debugPrint('Erreur lors de la demande de permission web: $e');
      return false;
    }
  }

  /// Recupere la position actuelle.
  static Future<({double latitude, double longitude})?> getCurrentPosition() async {
    if (PlatformUtils.isWeb) {
      return await _getWebPosition();
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 30),
      );
      return (latitude: position.latitude, longitude: position.longitude);
    } catch (e) {
      debugPrint('Erreur recuperation GPS: $e');
      return null;
    }
  }

  /// Recupere la position via l'API Web Geolocation.
  static Future<({double latitude, double longitude})?> _getWebPosition() async {
    if (!kIsWeb) {
      return null;
    }

    try {
      debugPrint('Recuperation de la position en web...');

      final position = await WebGeolocation.getPosition();
      if (position != null) {
        debugPrint(
          'Position web obtenue: (${position.latitude}, ${position.longitude})',
        );
        return position;
      }

      return null;
    } catch (e) {
      debugPrint('Erreur lors de la recuperation de position web: $e');
      return null;
    }
  }

  /// Convertit les coordonnees en adresse via Nominatim (OpenStreetMap).
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url =
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {'User-Agent': 'ConvoyeurMobileApp/1.0'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>?;

        if (address != null) {
          final road = address['road'] as String?;
          final city = address['city'] as String? ?? address['town'] as String?;
          final postalCode = address['postcode'] as String?;

          final parts = <String>[];
          if (road != null) parts.add(road);
          if (postalCode != null) parts.add(postalCode);
          if (city != null) parts.add(city);

          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }

        return data['address']?['village'] as String? ??
            data['address']?['neighbourhood'] as String? ??
            data['name'] as String? ??
            'Position obtenue';
      }
      return null;
    } catch (e) {
      debugPrint('Erreur geocodage: $e');
      return null;
    }
  }
}

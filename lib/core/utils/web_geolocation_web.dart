// lib/core/utils/web_geolocation_web.dart
//
// Implémentation WEB uniquement — utilise dart:html.
// Ne jamais importer directement ; passe par web_geolocation.dart

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<({double latitude, double longitude})?> getWebGeolocation() async {
  try {
    final geolocation = html.window.navigator.geolocation;
    final position = await geolocation.getCurrentPosition(
      enableHighAccuracy: true,
    );
    return (
      latitude: position.coords!.latitude!.toDouble(),
      longitude: position.coords!.longitude!.toDouble(),
    );
  } catch (e) {
    return null;
  }
}
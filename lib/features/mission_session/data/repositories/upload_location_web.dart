import 'dart:html' as html;

class UploadLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;

  const UploadLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
  });
}

Future<UploadLocation?> getUploadLocation() async {
  try {
    final position = await html.window.navigator.geolocation
        .getCurrentPosition(
          enableHighAccuracy: true,
          maximumAge: const Duration(seconds: 30),
          timeout: const Duration(seconds: 6),
        )
        .timeout(const Duration(seconds: 7));
    final coords = position.coords;
    return UploadLocation(
      latitude: coords!.latitude!.toDouble(),
      longitude: coords.longitude!.toDouble(),
      accuracy: coords.accuracy?.toDouble(),
    );
  } catch (_) {
    return null;
  }
}

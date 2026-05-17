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

Future<UploadLocation?> getUploadLocation() async => null;

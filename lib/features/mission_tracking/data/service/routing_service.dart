import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceKm;
  final int dureeMinutes;

  RouteResult({
    required this.points,
    required this.distanceKm,
    required this.dureeMinutes,
  });
}

class RoutingService {
  static final Dio _dio = Dio();

  static Future<RouteResult?> getRoute(
    LatLng depart,
    LatLng arrivee,
  ) async {
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${depart.longitude},${depart.latitude};'
          '${arrivee.longitude},${arrivee.latitude}'
          '?overview=full&geometries=geojson';

      final response = await _dio.get(url);
      final data = response.data;

      if (data['routes'] == null || data['routes'].isEmpty) return null;

      final route = data['routes'][0];
      final coords = route['geometry']['coordinates'] as List;
      final points = coords
          .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
          .toList();

      final distanceKm = route['distance'] / 1000.0;
      final dureeMinutes = (route['duration'] / 60).round();

      return RouteResult(
        points: points,
        distanceKm: distanceKm,
        dureeMinutes: dureeMinutes,
      );
    } catch (e) {
      debugPrint('RoutingService error: $e');
      return null;
    }
  }
}
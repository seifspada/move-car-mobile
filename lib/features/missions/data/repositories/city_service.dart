// lib/features/missions/data/repositories/city_service.dart

import 'package:convoyeur_mobile/features/missions/data/models/mission_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CityService {
  static const String _baseUrl = 'https://geo.api.gouv.fr';

  /// Recherche des communes françaises
  Future<List<CommuneModel>> searchCommunes(String query, {int limit = 5}) async {
    if (query.length < 2) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/communes?'
          'nom=${Uri.encodeComponent(query)}&'
          'fields=nom,centre,codesPostaux&'
          'format=json&'
          'limit=$limit',
        ),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => CommuneModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      print('⚠️ Erreur API: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ Erreur lors de la recherche de communes: $e');
      return [];
    }
  }
}

// ✅ Provider Riverpod
final cityServiceProvider = Provider<CityService>((ref) => CityService());

/// Provider pour chercher les communes avec debounce
final searchCommunesProvider = FutureProvider.family<List<CommuneModel>, String>(
  (ref, query) async {
    if (query.isEmpty || query.length < 2) {
      return [];
    }

    final service = ref.watch(cityServiceProvider);
    return service.searchCommunes(query);
  },
);

/// Provider pour les communes avec cache
final cachedCommunesProvider =
    FutureProvider.family<List<CommuneModel>, String>((ref, query) async {
  return ref.watch(searchCommunesProvider(query).future);
});
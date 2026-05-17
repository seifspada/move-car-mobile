// lib/features/missions/presentation/providers/mission_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/mission_model.dart';
import '../../data/repositories/graphql_service.dart';
import '../../data/repositories/city_service.dart';
import '../../../../core/network/graphql/graphql_client.dart';

// ==========================================
// 📌 STATE PROVIDERS
// ==========================================

final searchModeProvider = StateProvider<SearchMode>((ref) => SearchMode.text);
final searchQueryProvider = StateProvider<String>((ref) => '');
final currentPageProvider = StateProvider<int>((ref) => 1);
final selectedPositionCityProvider = StateProvider<SelectedCityModel?>((ref) => null);
final positionRadiusProvider = StateProvider<double>((ref) => 10.0);
final selectedTrajetDepartProvider = StateProvider<SelectedCityModel?>((ref) => null);
final selectedTrajetArriveeProvider = StateProvider<SelectedCityModel?>((ref) => null);
final trajetRadiusProvider = StateProvider<double>((ref) => 50.0);
final trajetDateDepartProvider = StateProvider<DateTime?>((ref) => null);
final trajetDateRetourProvider = StateProvider<DateTime?>((ref) => null);
final trajetAlertActiveProvider = StateProvider<bool>((ref) => false);
final positionAlertActiveProvider = StateProvider<bool>((ref) => false);

// ==========================================
// 🌐 SERVICE PROVIDERS
// ==========================================

final graphQLServiceProvider = Provider<GraphQLService>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return GraphQLService(client);
});

final cityServiceProvider = Provider<CityService>((ref) {
  return CityService();
});

// ==========================================
// 📡 FUTURE PROVIDERS
// ==========================================

final missionsDefaultProvider = FutureProvider<MissionsPaginatedResponse>((ref) async {
  final service = ref.watch(graphQLServiceProvider);
  try {
    final missions = await service.getMissionsForCards();
    return MissionsPaginatedResponse(
      missions: missions,
      total: missions.length,
      page: 1,
      pageSize: 20,
      totalPages: 1,
    );
  } catch (e) {
    throw Exception('Erreur lors du chargement des missions: $e');
  }
});

final searchMissionsProvider = FutureProvider.family<MissionsPaginatedResponse, int>(
  (ref, page) async {
    final service = ref.watch(graphQLServiceProvider);
    final query = ref.watch(searchQueryProvider);

    try {
      if (query.isEmpty) {
        return MissionsPaginatedResponse(
          missions: [],
          total: 0,
          page: page,
          pageSize: 20,
          totalPages: 0,
        );
      }

      return await service.searchMissions(
        search: query,
        page: page,
        pageSize: 20,
      );
    } catch (e) {
      throw Exception('Erreur recherche texte: $e');
    }
  },
);

final searchByPositionProvider = FutureProvider.family<MissionsPaginatedResponse, int>(
  (ref, page) async {
    final service = ref.watch(graphQLServiceProvider);
    final city = ref.watch(selectedPositionCityProvider);
    final radius = ref.watch(positionRadiusProvider);

    try {
      if (city == null) {
        return MissionsPaginatedResponse(
          missions: [],
          total: 0,
          page: page,
          pageSize: 20,
          totalPages: 0,
        );
      }

      return await service.searchMissionsByPosition(
        filters: SearchPositionFilter(
          villeNom: city.name,
          latitude: city.lat,
          longitude: city.lon,
          rayon: radius,
        ),
        page: page,
        pageSize: 20,
      );
    } catch (e) {
      throw Exception('Erreur recherche position: $e');
    }
  },
);

final searchByTrajetProvider = FutureProvider.family<MissionsPaginatedResponse, int>(
  (ref, page) async {
    final service = ref.watch(graphQLServiceProvider);
    final depart = ref.watch(selectedTrajetDepartProvider);
    final arrivee = ref.watch(selectedTrajetArriveeProvider);
    final radius = ref.watch(trajetRadiusProvider);
    final dateDepart = ref.watch(trajetDateDepartProvider);
    final dateRetour = ref.watch(trajetDateRetourProvider);

    try {
      if (depart == null || arrivee == null) {
        return MissionsPaginatedResponse(
          missions: [],
          total: 0,
          page: page,
          pageSize: 20,
          totalPages: 0,
        );
      }

      return await service.searchMissionsByTrajet(
        filters: SearchTrajetFilter(
          villeDepartNom: depart.name,
          latitudeDepart: depart.lat,
          longitudeDepart: depart.lon,
          villeArriveeNom: arrivee.name,
          latitudeArrivee: arrivee.lat,
          longitudeArrivee: arrivee.lon,
          rayon: radius,
          dateDepart: dateDepart?.toIso8601String(),
          dateDepartMax: dateRetour?.toIso8601String(),
        ),
        page: page,
        pageSize: 20,
      );
    } catch (e) {
      throw Exception('Erreur recherche trajet: $e');
    }
  },
);

// ==========================================
// 🎨 COMPUTED PROVIDERS
// ==========================================

final displayedMissionsProvider = FutureProvider<MissionsPaginatedResponse>((ref) async {
  final mode = ref.watch(searchModeProvider);
  final page = ref.watch(currentPageProvider);

  try {
    switch (mode) {
      case SearchMode.text:
        final query = ref.watch(searchQueryProvider);
        if (query.isEmpty) {
          return ref.watch(missionsDefaultProvider).when(
            data: (data) => data,
            loading: () => throw Exception('Chargement...'),
            error: (e, st) => throw Exception('Erreur: $e'),
          );
        }
        return ref.watch(searchMissionsProvider(page)).when(
          data: (data) => data,
          loading: () => throw Exception('Chargement...'),
          error: (e, st) => throw Exception('Erreur: $e'),
        );

      case SearchMode.position:
        return ref.watch(searchByPositionProvider(page)).when(
          data: (data) => data,
          loading: () => throw Exception('Chargement...'),
          error: (e, st) => throw Exception('Erreur: $e'),
        );

      case SearchMode.trajet:
        return ref.watch(searchByTrajetProvider(page)).when(
          data: (data) => data,
          loading: () => throw Exception('Chargement...'),
          error: (e, st) => throw Exception('Erreur: $e'),
        );
    }
  } catch (e) {
    throw Exception('Erreur affichage missions: $e');
  }
});

final isSearchActiveProvider = Provider<bool>((ref) {
  final mode = ref.watch(searchModeProvider);
  final query = ref.watch(searchQueryProvider);
  final positionCity = ref.watch(selectedPositionCityProvider);
  final trajetDepart = ref.watch(selectedTrajetDepartProvider);
  final trajetArrivee = ref.watch(selectedTrajetArriveeProvider);

  return (mode == SearchMode.text && query.isNotEmpty) ||
      (mode == SearchMode.position && positionCity != null) ||
      (mode == SearchMode.trajet && trajetDepart != null && trajetArrivee != null);
});

// ==========================================
// 🔧 ACTION PROVIDERS
// ==========================================

final clearSearchProvider = Provider.family<void Function(), WidgetRef>(
  (ref, widgetRef) {
    return () {
      widgetRef.read(searchModeProvider.notifier).state = SearchMode.text;
      widgetRef.read(searchQueryProvider.notifier).state = '';
      widgetRef.read(currentPageProvider.notifier).state = 1;
      widgetRef.read(selectedPositionCityProvider.notifier).state = null;
      widgetRef.read(positionRadiusProvider.notifier).state = 10.0;
      widgetRef.read(selectedTrajetDepartProvider.notifier).state = null;
      widgetRef.read(selectedTrajetArriveeProvider.notifier).state = null;
      widgetRef.read(trajetRadiusProvider.notifier).state = 50.0;
      widgetRef.read(trajetDateDepartProvider.notifier).state = null;
      widgetRef.read(trajetDateRetourProvider.notifier).state = null;
      widgetRef.read(trajetAlertActiveProvider.notifier).state = false;
      widgetRef.read(positionAlertActiveProvider.notifier).state = false;
    };
  },
);

// ✅ Provider création alerte — utilise directement l'alerte avec fcmToken
final createAlertProvider = FutureProvider.family<void, MissionAlert>(
  (ref, alert) async {
    final service = ref.watch(graphQLServiceProvider);
    try {
      await service.createMissionAlert(alert);
    } catch (e) {
      throw Exception('Erreur création alerte: $e');
    }
  },
);

// ✅ Provider récupération de mes alertes (notifications)
final myAlertesProvider = FutureProvider<List<AlerteModel>>((ref) async {
  final service = ref.watch(graphQLServiceProvider);
  try {
    final raw = await service.getMyAlertes();
    return raw
        .map((e) => AlerteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (e) {
    throw Exception('Erreur chargement alertes: $e');
  }
});
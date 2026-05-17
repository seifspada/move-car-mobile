// lib/features/missions/data/repositories/graphql_service.dart

import 'package:convoyeur_mobile/features/missions/data/graphql/mission_queries.dart';
import 'package:convoyeur_mobile/features/missions/data/models/mission_model.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  final GraphQLClient client;

  GraphQLService(this.client);

  // ==========================================
  // 🔍 RECHERCHE PAR TEXTE
  // ==========================================
  Future<MissionsPaginatedResponse> searchMissions({
    required String? search,
    required int page,
    required int pageSize,
  }) async {
    try {
      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(SEARCH_MISSIONS),
          variables: {
            'search': search,
            'page': page,
            'pageSize': pageSize,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception('Erreur GraphQL: ${result.exception}');
      }

      final data = result.data?['searchMissions'] as Map<String, dynamic>;
      return MissionsPaginatedResponse.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('❌ Erreur searchMissions: $e');
      rethrow;
    }
  }

  // ==========================================
  // 📍 RECHERCHE PAR POSITION
  // ==========================================
  Future<MissionsPaginatedResponse> searchMissionsByPosition({
    required SearchPositionFilter filters,
    required int page,
    required int pageSize,
  }) async {
    try {
      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(SEARCH_MISSIONS_BY_POSITION),
          variables: {
            'filters': {
              'villeNom': filters.villeNom,
              'latitude': filters.latitude,
              'longitude': filters.longitude,
              'rayon': filters.rayon.toInt(), // ✅ double → int
            },
            'page': page,
            'pageSize': pageSize,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception('Erreur GraphQL: ${result.exception}');
      }

      final data = result.data?['searchMissionsByPosition'] as Map<String, dynamic>;
      return MissionsPaginatedResponse.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('❌ Erreur searchMissionsByPosition: $e');
      rethrow;
    }
  }

  // ==========================================
  // 🛣️ RECHERCHE PAR TRAJET
  // ==========================================
  Future<MissionsPaginatedResponse> searchMissionsByTrajet({
    required SearchTrajetFilter filters,
    required int page,
    required int pageSize,
  }) async {
    try {
      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(SEARCH_MISSIONS_BY_TRAJET),
          variables: {
            'filters': {
              'villeDepartNom': filters.villeDepartNom,
              'latitudeDepart': filters.latitudeDepart,
              'longitudeDepart': filters.longitudeDepart,
              'villeArriveeNom': filters.villeArriveeNom,
              'latitudeArrivee': filters.latitudeArrivee,
              'longitudeArrivee': filters.longitudeArrivee,
              'rayon': filters.rayon.toInt(), // ✅ double → int
              if (filters.dateDepart != null) 'dateDepart': filters.dateDepart,
              if (filters.dateDepartMax != null) 'dateDepartMax': filters.dateDepartMax,
            },
            'page': page,
            'pageSize': pageSize,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception('Erreur GraphQL: ${result.exception}');
      }

      final data = result.data?['searchMissionsByTrajet'] as Map<String, dynamic>;
      return MissionsPaginatedResponse.fromJson(data);
    } catch (e) {
      if (kDebugMode) print('❌ Erreur searchMissionsByTrajet: $e');
      rethrow;
    }
  }

  // ==========================================
  // 🏠 MISSIONS PAR DÉFAUT (CARDS)
  // ==========================================
  Future<List<MissionModel>> getMissionsForCards() async {
    try {
      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(GET_MISSIONS_FOR_CARDS),
          fetchPolicy: FetchPolicy.cacheAndNetwork,
        ),
      );

      if (result.hasException) {
        throw Exception('Erreur GraphQL: ${result.exception}');
      }

      final missions = (result.data?['missionsForCards'] as List<dynamic>?)
              ?.map((m) => MissionModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [];

      return missions;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur getMissionsForCards: $e');
      rethrow;
    }
  }

  // ==========================================
  // 📍 CRÉER ALERTE GÉOGRAPHIQUE
  // ==========================================
  Future<void> createAlerteGeographique({
    required String villeNom,
    required double latitude,
    required double longitude,
    required double rayon,
    required bool emailActif,
    required bool pushActif,
    String? fcmToken,
    String? dateDepart,
  }) async {
    try {
      if (kDebugMode) print('📍 Création alerte géographique: $villeNom');

      final Map<String, dynamic> input = {
        'villeNom': villeNom,
        'latitude': latitude,
        'longitude': longitude,
        'rayon': rayon.toInt(), // ✅ double → int
        'emailActif': emailActif,
        'pushActif': pushActif,
        if (fcmToken != null) 'fcmToken': fcmToken,
        if (dateDepart != null) 'dateDepart': dateDepart,
      };

      final QueryResult result = await client.mutate(
        MutationOptions(
          document: gql(CREATE_ALERTE_GEOGRAPHIQUE),
          variables: {'input': input},
        ),
      );

      if (result.hasException) {
        throw Exception('Erreur création alerte: ${result.exception}');
      }

      if (kDebugMode) print('✅ Alerte géographique créée');
    } catch (e) {
      if (kDebugMode) print('❌ Erreur createAlerteGeographique: $e');
      rethrow;
    }
  }

  // ==========================================
  // 🚗 CRÉER ALERTE TRAJET
  // ==========================================
  Future<void> createAlerteTrajet({
    required String villeDepartNom,
    required double latitudeDepart,
    required double longitudeDepart,
    required String villeArriveeNom,
    required double latitudeArrivee,
    required double longitudeArrivee,
    required double rayon,
    required bool emailActif,
    required bool pushActif,
    String? fcmToken,
    String? dateDepart,
    String? dateDepartMax,
  }) async {
    try {
      if (kDebugMode) print('🚗 Création alerte trajet: $villeDepartNom → $villeArriveeNom');

      final Map<String, dynamic> input = {
        'villeDepartNom': villeDepartNom,
        'latitudeDepart': latitudeDepart,
        'longitudeDepart': longitudeDepart,
        'villeArriveeNom': villeArriveeNom,
        'latitudeArrivee': latitudeArrivee,
        'longitudeArrivee': longitudeArrivee,
        'rayon': rayon.toInt(), // ✅ double → int
        'emailActif': emailActif,
        'pushActif': pushActif,
        if (fcmToken != null) 'fcmToken': fcmToken,
        if (dateDepart != null) 'dateDepart': dateDepart,
        if (dateDepartMax != null) 'dateDepartMax': dateDepartMax,
      };

      final QueryResult result = await client.mutate(
        MutationOptions(
          document: gql(CREATE_ALERTE_TRAJET),
          variables: {'input': input},
        ),
      );

      if (result.hasException) {
        throw Exception('Erreur création alerte: ${result.exception}');
      }

      if (kDebugMode) print('✅ Alerte trajet créée');
    } catch (e) {
      if (kDebugMode) print('❌ Erreur createAlerteTrajet: $e');
      rethrow;
    }
  }

  // ==========================================
  // 🔄 METTRE À JOUR FCM TOKEN
  // ==========================================
  Future<bool> updateFcmToken(String fcmToken) async {
    try {
      if (kDebugMode) print('🔄 Mise à jour FCM token...');

      final QueryResult result = await client.mutate(
        MutationOptions(
          document: gql(UPDATE_FCM_TOKEN),
          variables: {'fcmToken': fcmToken},
        ),
      );

      if (result.hasException) {
        if (kDebugMode) print('❌ Erreur: ${result.exception}');
        return false;
      }

      final success = result.data?['updateFcmToken'] as bool? ?? false;
      if (kDebugMode) print(success ? '✅ Token FCM mis à jour' : '⚠️ Échec mise à jour token');
      return success;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur updateFcmToken: $e');
      return false;
    }
  }

  // ==========================================
  // 📋 RÉCUPÉRER MES ALERTES
  // ==========================================
  Future<List<dynamic>> getMyAlertes() async {
    try {
      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(GET_MY_ALERTES),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception('Erreur récupération alertes: ${result.exception}');
      }

      return result.data?['getMyAlertes'] as List<dynamic>? ?? [];
    } catch (e) {
      if (kDebugMode) print('❌ Erreur getMyAlertes: $e');
      rethrow;
    }
  }

  // ==========================================
  // 📋 RÉCUPÉRER MES ALERTES AVEC TOKENS
  // ==========================================
  Future<List<dynamic>> getMyAlertesByUserWithTokens() async {
    try {
      final QueryResult result = await client.query(
        QueryOptions(
          document: gql(GET_MY_ALERTES_WITH_TOKENS),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception('Erreur récupération alertes: ${result.exception}');
      }

      return result.data?['getMyAlertesByUserWithTokens'] as List<dynamic>? ?? [];
    } catch (e) {
      if (kDebugMode) print('❌ Erreur getMyAlertesByUserWithTokens: $e');
      rethrow;
    }
  }

  // ==========================================
  // 🔴 DÉSACTIVER UNE ALERTE
  // ==========================================
  Future<bool> desactiverAlerte(String alerteId) async {
    try {
      final QueryResult result = await client.mutate(
        MutationOptions(
          document: gql(DESACTIVER_ALERTE),
          variables: {'id': alerteId},
        ),
      );

      if (result.hasException) return false;
      if (kDebugMode) print('✅ Alerte désactivée');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur desactiverAlerte: $e');
      return false;
    }
  }

  // ==========================================
  // ✅ ACTIVER UNE ALERTE
  // ==========================================
  Future<bool> activerAlerte(String alerteId) async {
    try {
      final QueryResult result = await client.mutate(
        MutationOptions(
          document: gql(ACTIVER_ALERTE),
          variables: {'id': alerteId},
        ),
      );

      if (result.hasException) return false;
      if (kDebugMode) print('✅ Alerte activée');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur activerAlerte: $e');
      return false;
    }
  }

  // ==========================================
  // 🗑️ SUPPRIMER UNE ALERTE
  // ==========================================
  Future<bool> supprimerAlerte(String alerteId) async {
    try {
      final QueryResult result = await client.mutate(
        MutationOptions(
          document: gql(SUPPRIMER_ALERTE),
          variables: {'id': alerteId},
        ),
      );

      if (result.hasException) return false;
      if (kDebugMode) print('✅ Alerte supprimée');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur supprimerAlerte: $e');
      return false;
    }
  }

  // ==========================================
  // 📏 MODIFIER LE RAYON
  // ==========================================
  Future<bool> modifierRayon(String alerteId, int rayon) async {
    try {
      final QueryResult result = await client.mutate(
        MutationOptions(
          document: gql(MODIFIER_RAYON),
          variables: {'id': alerteId, 'rayon': rayon},
        ),
      );

      if (result.hasException) return false;
      if (kDebugMode) print('✅ Rayon modifié: $rayon km');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erreur modifierRayon: $e');
      return false;
    }
  }

  // ==========================================
  // 🔔 CRÉER ALERTE DEPUIS MissionAlert
  // ==========================================
  Future<void> createMissionAlert(MissionAlert alert) async {
    try {
      if (kDebugMode) {
        print('📱 FCM Token: ${alert.fcmToken}');
        print('📱 pushActif: ${alert.pushActif}');
        print('🌐 emailActif: ${alert.emailActif}');
      }

      if (alert.type == 'GEOGRAPHIQUE') {
        await createAlerteGeographique(
          villeNom: alert.villeNom!,
          latitude: alert.latitude!,
          longitude: alert.longitude!,
          rayon: alert.rayon!,
          emailActif: alert.emailActif,
          pushActif: alert.pushActif,
          fcmToken: alert.fcmToken,
          dateDepart: alert.dateDepart,
        );
      } else {
        await createAlerteTrajet(
          villeDepartNom: alert.villeDepartNom!,
          latitudeDepart: alert.latitudeDepart!,
          longitudeDepart: alert.longitudeDepart!,
          villeArriveeNom: alert.villeArriveeNom!,
          latitudeArrivee: alert.latitudeArrivee!,
          longitudeArrivee: alert.longitudeArrivee!,
          rayon: alert.rayon!,
          emailActif: alert.emailActif,
          pushActif: alert.pushActif,
          fcmToken: alert.fcmToken,
          dateDepart: alert.dateDepart,
          dateDepartMax: alert.dateRetour,
        );
      }

      if (kDebugMode) print('✅ Alerte créée avec succès');
    } catch (e) {
      if (kDebugMode) print('❌ Erreur createMissionAlert: $e');
      rethrow;
    }
  }
}
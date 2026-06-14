import 'package:graphql_flutter/graphql_flutter.dart';
import '../../domain/repositories/mission_tracking_repository.dart';
import '../../domain/entities/mission_tracking_entity.dart';
import '../../domain/entities/mission_incident_entity.dart';
import '../graphql/mission_tracking_queries.dart';
import '../models/mission_tracking_model.dart';
import '../models/mission_incident_model.dart';

class MissionTrackingRepositoryImpl implements MissionTrackingRepository {
  final GraphQLClient client;
  MissionTrackingRepositoryImpl(this.client);

  // ── helper centralisé ──────────────────────────────────
  void _handleErrors(QueryResult result, String operation) {
    if (!result.hasException) return;

    final gqlErrors = result.exception?.graphqlErrors ?? [];
    if (gqlErrors.isNotEmpty) {
      throw Exception(gqlErrors.first.message);
    }

    final linkErr = result.exception?.linkException?.toString() ?? '';

    // Message lisible au lieu de l'erreur brute
    if (linkErr.contains('TimeoutException') ||
        linkErr.contains('No stream event')) {
      throw Exception(
        'Délai dépassé lors de "$operation". '
        'Vérifiez votre connexion et réessayez.',
      );
    }

    throw Exception('Erreur réseau lors de "$operation": $linkErr');
  }

  @override
  Future<MissionTrackingEntity> updateLocation({
    required String missionId,
    required double latitude,
    required double longitude,
    double? accuracy,
    required DateTime timestamp,
  }) async {
    final result = await client.mutate(MutationOptions(
      document: gql(MissionTrackingQueries.updateLocation),
      variables: {
        'input': {
          'missionId': missionId,
          'latitude': latitude,
          'longitude': longitude,
          if (accuracy != null) 'accuracy': accuracy,
          'timestamp': timestamp.toIso8601String(),
        }
      },
    ));

    _handleErrors(result, 'updateMissionLocation');
    return _trackingToEntity(
      MissionTrackingModel.fromJson(result.data!['updateMissionLocation']),
    );
  }

  @override
  Future<ArrivalCheckEntity> checkArrival({
    required String sessionId,
    required double latitude,
    required double longitude,
  }) async {
    final result = await client.query(QueryOptions(
      document: gql(MissionTrackingQueries.checkArrival),
      variables: {
        'sessionId': sessionId,
        'latitude': latitude,
        'longitude': longitude,
      },
      fetchPolicy: FetchPolicy.networkOnly,
    ));

    _handleErrors(result, 'checkMissionArrival');
    final model = ArrivalCheckModel.fromJson(
      result.data!['checkMissionArrival'],
    );
    return ArrivalCheckEntity(
      isArrived: model.isArrived,
      distanceMetres: model.distanceMetres,
      villeArrivee: model.villeArrivee,
    );
  }

  @override
  Future<List<MissionTrackingEntity>> getTrackingHistory(
    String missionId,
  ) async {
    final result = await client.query(QueryOptions(
      document: gql(MissionTrackingQueries.getTrackingHistory),
      variables: {'missionId': missionId},
      fetchPolicy: FetchPolicy.networkOnly,
    ));

    _handleErrors(result, 'getMissionTrackingHistory');
    final list = result.data!['getMissionTrackingHistory'] as List;
    return list
        .map((e) => _trackingToEntity(MissionTrackingModel.fromJson(e)))
        .toList();
  }

  @override
  Future<MissionIncidentEntity> reportIncident({
    required String sessionId,
    required String typeIncident,
    required String description,
    required double latitude,
    required double longitude,
    List<String>? photos,
  }) async {
    final result = await client.mutate(MutationOptions(
      document: gql(MissionTrackingQueries.reportIncident),
      variables: {
        'input': {
          'sessionId': sessionId,
          'typeIncident': typeIncident,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          if (photos != null) 'photos': photos,
        }
      },
    ));

    _handleErrors(result, 'reportMissionIncident');
    return _incidentToEntity(
      MissionIncidentModel.fromJson(result.data!['reportMissionIncident']),
    );
  }

  @override
  Future<void> completeMission({
    required String missionId,
    required double latitudeFin,
    required double longitudeFin,
  }) async {
    final result = await client.mutate(MutationOptions(
      document: gql(MissionTrackingQueries.completeMission),
      variables: {
        'input': {
          'missionId': missionId,
          'latitudeFin': latitudeFin,
          'longitudeFin': longitudeFin,
        }
      },
    ));

    _handleErrors(result, 'completeMission');
  }

  // ── helpers ──────────────────────────────────────────────

  MissionTrackingEntity _trackingToEntity(MissionTrackingModel m) =>
      MissionTrackingEntity(
        id: m.id,
        sessionId: m.sessionId,
        missionId: m.missionId,
        latitude: m.latitude,
        longitude: m.longitude,
        accuracy: m.accuracy,
        timestamp: m.timestamp,
        isDeviated: m.isDeviated,
        distanceFromRoute: m.distanceFromRoute,
      );

  MissionIncidentEntity _incidentToEntity(MissionIncidentModel m) =>
      MissionIncidentEntity(
        id: m.id,
        sessionId: m.sessionId,
        typeIncident: m.typeIncident,
        description: m.description,
        latitude: m.latitude,
        longitude: m.longitude,
        medias: m.medias
            .map((med) => MissionIncidentMediaEntity(
                  id: med.id,
                  cheminFichier: med.cheminFichier,
                  tailleOctets: med.tailleOctets,
                  ordre: med.ordre,
                ))
            .toList(),
        resolvedBy: m.resolvedBy,
        resolutionNotes: m.resolutionNotes,
        dateResolution: m.dateResolution,
        dateCreation: m.dateCreation,
      );
}
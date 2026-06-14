// data/repositories/mission_session_repository_impl.dart

import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql/mission_session_queries.dart';
import '../models/mission_session_model.dart';
import '../../domain/entities/mission_session_entity.dart';

class MissionSessionException implements Exception {
  final String message;
  const MissionSessionException(this.message);

  @override
  String toString() => message;
}

class MissionSessionRepository {
  final GraphQLClient client;

  const MissionSessionRepository({required this.client});

  // ─────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────

  void _handleErrors(QueryResult result, String operation) {
    if (result.hasException) {
      final gqlErrors = result.exception?.graphqlErrors ?? [];
      if (gqlErrors.isNotEmpty) {
        throw MissionSessionException(gqlErrors.first.message);
      }
      final linkError = result.exception?.linkException?.toString() ?? '';
      throw MissionSessionException(
        'Erreur réseau lors de $operation: $linkError',
      );
    }
  }

  // ─────────────────────────────────────────
  // GET SESSION BY RESERVATION
  // ─────────────────────────────────────────

  Future<MissionSessionEntity?> getSessionByReservation(
    String reservationId,
  ) async {
    final result = await client.query(
      QueryOptions(
        document: gql(MissionSessionQueries.getMissionSession),
        variables: {'reservationId': reservationId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    _handleErrors(result, 'getMissionSession');

    final data = result.data?['getMissionSession'];
    if (data == null) return null;

    return MissionSessionModel.fromJson(data as Map<String, dynamic>);
  }

  // ─────────────────────────────────────────
  // GET SESSION PHOTOS
  // ─────────────────────────────────────────

  Future<List<MissionSessionMediaEntity>> getSessionPhotos(
    String sessionId, {
    EtapeSession? etape,
  }) async {
    final result = await client.query(
      QueryOptions(
        document: gql(MissionSessionQueries.getMissionSessionPhotos),
        variables: {
          'sessionId': sessionId,
          if (etape != null) 'etape': etape.name,
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    _handleErrors(result, 'getMissionSessionPhotos');

    final data = result.data?['getMissionSessionPhotos'] as List<dynamic>? ?? [];
    return data
        .map((m) => MissionSessionMediaModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────
  // VALIDATE PHOTOS
  // ─────────────────────────────────────────

  Future<PhotoValidationResultModel> validatePrePhotos(String sessionId) async {
    final result = await client.query(
      QueryOptions(
        document: gql(MissionSessionQueries.validatePreMissionPhotos),
        variables: {'sessionId': sessionId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    _handleErrors(result, 'validatePreMissionPhotos');

    final data = result.data?['validatePreMissionPhotos'] as Map<String, dynamic>? ?? {};
    return PhotoValidationResultModel.fromJson(data);
  }

  Future<PhotoValidationResultModel> validatePostPhotos(String sessionId) async {
    final result = await client.query(
      QueryOptions(
        document: gql(MissionSessionQueries.validatePostMissionPhotos),
        variables: {'sessionId': sessionId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    _handleErrors(result, 'validatePostMissionPhotos');

    final data = result.data?['validatePostMissionPhotos'] as Map<String, dynamic>? ?? {};
    return PhotoValidationResultModel.fromJson(data);
  }

  // ─────────────────────────────────────────
  // START SESSION
  // ─────────────────────────────────────────
Future<MissionSessionEntity> startSession(
  StartMissionSessionInputModel input,
) async {
  final result = await client.mutate(
    MutationOptions(
      document: gql(MissionSessionQueries.startMissionSession),
      variables: {'input': input.toJson()},
      // ✅ Ajout fetchPolicy
      fetchPolicy: FetchPolicy.networkOnly,
    ),
  );

  _handleErrors(result, 'startMissionSession');

  final data = result.data?['startMissionSession'] as Map<String, dynamic>?;
  if (data == null) {
    throw const MissionSessionException(
      'Réponse invalide du serveur lors du démarrage de session.',
    );
  }
  return MissionSessionModel.fromJson(data);
}

Future<MissionSessionEntity> endSession(
  EndMissionSessionInputModel input,
) async {
  final result = await client.mutate(
    MutationOptions(
      document: gql(MissionSessionQueries.endMissionSession),
      variables: {'input': input.toJson()},
      // ✅ Ajout fetchPolicy
      fetchPolicy: FetchPolicy.networkOnly,
    ),
  );

  _handleErrors(result, 'endMissionSession');

  final data = result.data?['endMissionSession'] as Map<String, dynamic>?;
  if (data == null) {
    throw const MissionSessionException(
      'Réponse invalide du serveur lors de la fin de session.',
    );
  }
  return MissionSessionModel.fromJson(data);
}
  // ─────────────────────────────────────────
  // UPLOAD PHOTOS
  // ─────────────────────────────────────────

  Future<List<MissionSessionMediaEntity>> uploadPhotos({
    required String sessionId,
    required EtapeSession etape,
    required List<MediaUploadInputModel> medias,
  }) async {
    final result = await client.mutate(
      MutationOptions(
        document: gql(MissionSessionQueries.uploadMissionPhotos),
        variables: {
          'input': {
            'sessionId': sessionId,
            'etape': etape.name,
            'medias': medias.map((m) => m.toJson()).toList(),
          },
        },
      ),
    );

    _handleErrors(result, 'uploadMissionPhotos');

    final data = result.data?['uploadMissionPhotos'] as List<dynamic>? ?? [];
    return data
        .map((m) => MissionSessionMediaModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }
}
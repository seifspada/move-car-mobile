// lib/features/missions/data/repositories/reservation_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/network/graphql/graphql_client.dart';
import '../../domain/entities/reservation_entity.dart';
import '../graphql/mission_queries.dart';
import '../models/reservation_model.dart';

class ReservationRepository {
  final GraphQLClient _client;

  ReservationRepository(this._client);

  Future<ReservationResponseEntity> createReservation(
    CreateReservationInput input,
  ) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(createReservationMutation),
          variables: {'input': input.toJson()},
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        final msg = result.exception?.graphqlErrors.isNotEmpty == true
            ? result.exception!.graphqlErrors.first.message
            : result.exception?.linkException?.toString() ??
                'Erreur de connexion';
        return ReservationResponseModel(
          success: false,
          message: msg,
          code: 'GRAPHQL_ERROR',
        );
      }

      final data =
          result.data?['createReservation'] as Map<String, dynamic>?;

      if (data == null) {
        return const ReservationResponseModel(
          success: false,
          message: 'Aucune réponse reçue du serveur',
          code: 'NO_RESPONSE',
        );
      }

      return ReservationResponseModel.fromJson(data);
    } catch (e) {
      return ReservationResponseModel(
        success: false,
        message: e.toString(),
        code: 'GRAPHQL_ERROR',
      );
    }
  }
}

// ✅ Provider Riverpod — injecte GraphQLClient automatiquement
final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return ReservationRepository(client);
});
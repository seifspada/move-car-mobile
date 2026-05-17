// lib/features/reservations/data/repositories/reservation_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:gql/language.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/graphql/graphql_client.dart';
import '../graphql/reservation_queries.dart' as gql;
import '../models/reservation_model.dart';
import '../../domain/entities/reservation_entity.dart';

// ✅ FIX — ref.watch() pour suivre le client recréé après login
final reservationRepositoryProvider = Provider<ReservationRepositoryImpl>(
  (ref) => ReservationRepositoryImpl(ref.watch(graphqlClientProvider)),
);

class ReservationRepositoryImpl {
  final GraphQLClient _client;

  ReservationRepositoryImpl(this._client);

  // ─────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────

  Future<Either<Failure, T>> _query<T>({
    required String document,
    Map<String, dynamic>? variables,
    required T Function(Map<String, dynamic> data) parser,
  }) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: parseString(document),
          variables: variables ?? {},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        final linkErr    = result.exception?.linkException;
        final graphqlErr = result.exception?.graphqlErrors;
        debugPrint('❌ GraphQL exception:');
        if (linkErr != null)    debugPrint('   linkException: $linkErr');
        if (graphqlErr != null) debugPrint('   graphqlErrors: $graphqlErr');
        final msg = (graphqlErr != null && graphqlErr.isNotEmpty)
            ? graphqlErr.first.message
            : linkErr?.toString() ?? result.exception.toString();
        return Left(ServerFailure(message: msg));
      }

      if (result.data == null) {
        return Left(ServerFailure(message: 'No data returned'));
      }

      debugPrint('✅ Query OK — keys: ${result.data!.keys}');
      return Right(parser(result.data!));
    } catch (e, stack) {
      debugPrint('❌ Query catch: $e');
      debugPrint('❌ Stack: $stack');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, T>> _mutate<T>({
    required String document,
    Map<String, dynamic>? variables,
    required T Function(Map<String, dynamic> data) parser,
  }) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: parseString(document),
          variables: variables ?? {},
        ),
      );

      if (result.hasException) {
        final linkErr    = result.exception?.linkException;
        final graphqlErr = result.exception?.graphqlErrors;
        debugPrint('❌ Mutation exception:');
        if (linkErr != null)    debugPrint('   linkException: $linkErr');
        if (graphqlErr != null) debugPrint('   graphqlErrors: $graphqlErr');
        final msg = (graphqlErr != null && graphqlErr.isNotEmpty)
            ? graphqlErr.first.message
            : linkErr?.toString() ?? result.exception.toString();
        return Left(ServerFailure(message: msg));
      }

      if (result.data == null) {
        return Left(ServerFailure(message: 'No data returned'));
      }

      return Right(parser(result.data!));
    } catch (e, stack) {
      debugPrint('❌ Mutation catch: $e');
      debugPrint('❌ Stack: $stack');
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // ─────────────────────────────────────────────
  // QUERIES
  // ─────────────────────────────────────────────

  Future<Either<Failure, List<ReservationEntity>>> getMyReservations() =>
      _query(
        document: gql.getMyReservations,
        parser: (data) {
          final list = data['myReservations'] as List;
          debugPrint('📋 myReservations count: ${list.length}');
          debugPrint('📋 raw[0]: ${list.isNotEmpty ? list[0] : "vide"}');
          return list
              .where((e) => e != null)
              .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

  Future<Either<Failure, List<ReservationEntity>>> getAllReservations() =>
      _query(
        document: gql.getAllReservations,
        parser: (data) {
          final list = data['allReservations'] as List;
          debugPrint('📋 allReservations count: ${list.length}');
          return list
              .where((e) => e != null)
              .map((e) => ReservationModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

  Future<Either<Failure, ReservationEntity>> getReservationById(String id) =>
      _query(
        document: gql.getReservationById,
        variables: {'id': id},
        parser: (data) => ReservationModel.fromJson(
          data['reservationById'] as Map<String, dynamic>,
        ),
      );

  // ─────────────────────────────────────────────
  // MUTATIONS
  // ─────────────────────────────────────────────

  Future<Either<Failure, ReservationEntity>> cancelReservation(
    String id, {
    String? motifAnnulation,
  }) =>
      _mutate(
        document: gql.cancelReservation,
        variables: {
          'id': id,
          if (motifAnnulation != null) 'motifAnnulation': motifAnnulation,
        },
        parser: (data) => ReservationModel.fromJson(
          data['cancelReservation'] as Map<String, dynamic>,
        ),
      );

  Future<Either<Failure, ReservationEntity>> confirmReservationByAdherent(
          String id) =>
      _mutate(
        document: gql.confirmReservationByAdherent,
        variables: {'id': id},
        parser: (data) => ReservationModel.fromJson(
          data['confirmReservationByAdherent'] as Map<String, dynamic>,
        ),
      );

  Future<Either<Failure, ReservationEntity>> requestCancellation(
    String id,
    String motifAnnulation,
  ) =>
      _mutate(
        document: gql.requestCancellation,
        variables: {'id': id, 'motifAnnulation': motifAnnulation},
        parser: (data) => ReservationModel.fromJson(
          data['requestCancellation'] as Map<String, dynamic>,
        ),
      );

  Future<Either<Failure, ReservationEntity>> cancelPendingReservation(
          String id) =>
      _mutate(
        document: gql.cancelPendingReservation,
        variables: {'id': id},
        parser: (data) => ReservationModel.fromJson(
          data['cancelPendingReservation'] as Map<String, dynamic>,
        ),
      );
}
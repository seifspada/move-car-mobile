// lib/features/missions/presentation/providers/reservation_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/graphql/graphql_client.dart';
import '../../data/repositories/reservation_repository.dart';
import '../../domain/entities/reservation_entity.dart';

// ─────────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────────

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return ReservationRepository(client);
});

// ─────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────

class CreateReservationState {
  final bool loading;
  final String? errorMessage;
  final ReservationResponseEntity? lastResponse;

  const CreateReservationState({
    this.loading = false,
    this.errorMessage,
    this.lastResponse,
  });

  CreateReservationState copyWith({
    bool? loading,
    String? errorMessage,
    ReservationResponseEntity? lastResponse,
    bool clearError = false,
  }) {
    return CreateReservationState(
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastResponse: lastResponse ?? this.lastResponse,
    );
  }
}

// ─────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────

class CreateReservationNotifier
    extends StateNotifier<CreateReservationState> {
  final Ref _ref;

  CreateReservationNotifier(this._ref)
      : super(const CreateReservationState());

  ReservationRepository get _repo =>
      _ref.read(reservationRepositoryProvider);

  Future<ReservationResponseEntity> createReservation(
    CreateReservationInput input,
  ) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final response = await _repo.createReservation(input);
      state = state.copyWith(
        loading: false,
        lastResponse: response,
        errorMessage: response.success ? null : response.message,
      );
      return response;
    } catch (e) {
      debugPrint('❌ createReservation exception: $e');
      state = state.copyWith(loading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}

// ─────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────

final createReservationProvider =
    StateNotifierProvider<CreateReservationNotifier, CreateReservationState>(
        (ref) {
  ref.watch(graphqlClientProvider);
  return CreateReservationNotifier(ref);
});
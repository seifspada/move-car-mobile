// lib/features/reservations/presentation/providers/reservation_providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/graphql/graphql_client.dart';
import '../../data/repositories/reservation_repository_impl.dart';
import '../../domain/entities/reservation_entity.dart';

// ─────────────────────────────────────────────
// STATE
// ─────────────────────────────────────────────

class ReservationState {
  final List<ReservationEntity> reservations;
  final bool isLoading;
  final String? errorMessage;
  final String? actionLoadingId;

  const ReservationState({
    this.reservations = const [],
    this.isLoading = false,
    this.errorMessage,
    this.actionLoadingId,
  });

  ReservationState copyWith({
    List<ReservationEntity>? reservations,
    bool? isLoading,
    String? errorMessage,
    String? actionLoadingId,
    bool clearError = false,
    bool clearActionLoading = false,
  }) {
    return ReservationState(
      reservations:    reservations       ?? this.reservations,
      isLoading:       isLoading          ?? this.isLoading,
      errorMessage:    clearError         ? null : (errorMessage ?? this.errorMessage),
      actionLoadingId: clearActionLoading ? null : (actionLoadingId ?? this.actionLoadingId),
    );
  }
}

// ─────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────

class ReservationNotifier extends StateNotifier<ReservationState> {
  final Ref _ref;

  ReservationNotifier(this._ref) : super(const ReservationState());

  ReservationRepositoryImpl get _repo =>
      _ref.read(reservationRepositoryProvider);

  Future<void> fetchMyReservations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _repo.getMyReservations();
      result.fold(
        (failure) {
          debugPrint('❌ fetchMyReservations failure: ${failure.message}');
          state = state.copyWith(isLoading: false, errorMessage: failure.message);
        },
        (reservations) {
          debugPrint('✅ State updated: ${reservations.length} réservations');
          state = state.copyWith(isLoading: false, reservations: reservations);
          debugPrint('✅ State after update: ${state.reservations.length}');
        },
      );
    } catch (e) {
      debugPrint('❌ fetchMyReservations exception: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<String?> cancelPending(String id) async {
    state = state.copyWith(actionLoadingId: id);
    final result = await _repo.cancelPendingReservation(id);
    return result.fold(
      (f) {
        state = state.copyWith(clearActionLoading: true);
        return f.message;
      },
      (_) {
        fetchMyReservations();
        state = state.copyWith(clearActionLoading: true);
        return null;
      },
    );
  }

  Future<String?> cancelReservation(String id, {String? motif}) async {
    state = state.copyWith(actionLoadingId: id);
    final result = await _repo.cancelReservation(id, motifAnnulation: motif);
    return result.fold(
      (f) {
        state = state.copyWith(clearActionLoading: true);
        return f.message;
      },
      (_) {
        fetchMyReservations();
        state = state.copyWith(clearActionLoading: true);
        return null;
      },
    );
  }

  Future<String?> requestCancellation(String id, String motif) async {
    state = state.copyWith(actionLoadingId: id);
    final result = await _repo.requestCancellation(id, motif);
    return result.fold(
      (f) {
        state = state.copyWith(clearActionLoading: true);
        return f.message;
      },
      (_) {
        fetchMyReservations();
        state = state.copyWith(clearActionLoading: true);
        return null;
      },
    );
  }

  Future<String?> confirm(String id) async {
    state = state.copyWith(actionLoadingId: id);
    final result = await _repo.confirmReservationByAdherent(id);
    return result.fold(
      (f) {
        state = state.copyWith(clearActionLoading: true);
        return f.message;
      },
      (_) {
        fetchMyReservations();
        state = state.copyWith(clearActionLoading: true);
        return null;
      },
    );
  }
}

// ─────────────────────────────────────────────
// PROVIDER
// ─────────────────────────────────────────────

// ✅ FIX PRINCIPAL — watch(graphqlClientProvider) force la recréation
// du notifier quand le client GraphQL change (après login)
final reservationProvider =
    StateNotifierProvider<ReservationNotifier, ReservationState>((ref) {
  ref.watch(graphqlClientProvider);
  return ReservationNotifier(ref);
});
// presentation/providers/mission_session_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/graphql/graphql_client.dart';
import '../../data/models/mission_session_model.dart';
import '../../data/repositories/mission_session_repository_impl.dart';
import '../../domain/entities/mission_session_entity.dart';

// ─────────────────────────────────────────
// GRAPHQL CLIENT PROVIDER
// Override this in your app with actual client
// ─────────────────────────────────────────

// ─────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────

final missionSessionRepositoryProvider = Provider<MissionSessionRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return MissionSessionRepository(client: client);
});

// ─────────────────────────────────────────
// SESSION STATE NOTIFIER
// ─────────────────────────────────────────

class MissionSessionState {
  final MissionSessionEntity? session;
  final bool isLoading;
  final String? error;

  const MissionSessionState({
    this.session,
    this.isLoading = false,
    this.error,
  });

  MissionSessionState copyWith({
    MissionSessionEntity? session,
    bool? isLoading,
    String? error,
  }) {
    return MissionSessionState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get hasSession => session != null;
  bool get isEnCours => session?.statut == StatutSession.EN_COURS;
}

class MissionSessionNotifier extends StateNotifier<MissionSessionState> {
  final MissionSessionRepository _repo;

  MissionSessionNotifier(this._repo) : super(const MissionSessionState());

  // ── Load session ──────────────────────────

  Future<void> loadSession(String reservationId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _repo.getSessionByReservation(reservationId);
      state = state.copyWith(session: session, isLoading: false);
    } on MissionSessionException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Start session ──────────────────────────

Future<void> startSession(StartMissionSessionInputModel input) async {
  state = state.copyWith(isLoading: true, error: null);

  int attempt = 0;
  const maxRetries = 3;

  while (attempt < maxRetries) {
    try {
      final session = await _repo.startSession(input);
      state = state.copyWith(session: session, isLoading: false);
      return;

    } catch (e) {
      attempt++;
      final isTimeout = e.toString().contains('TimeoutException') ||
          e.toString().contains('No stream event') ||
          e.toString().contains('Délai dépassé');

      if (!isTimeout || attempt >= maxRetries) {
        final msg = isTimeout
            ? 'Connexion trop lente. Vérifiez votre réseau et réessayez.'
            : e.toString();
        state = state.copyWith(isLoading: false, error: msg);
        rethrow;
      }

      // Backoff : 2s, 4s, 6s
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }
}
  // ── End session ──────────────────────────

Future<void> endSession(EndMissionSessionInputModel input) async {
  state = state.copyWith(isLoading: true, error: null);

  int attempt = 0;
  const maxRetries = 3;

  while (attempt < maxRetries) {
    try {
      final session = await _repo.endSession(input);
      state = state.copyWith(session: session, isLoading: false);
      return;

    } catch (e) {
      attempt++;
      final isTimeout = e.toString().contains('TimeoutException') ||
          e.toString().contains('No stream event') ||
          e.toString().contains('Délai dépassé');

      if (!isTimeout || attempt >= maxRetries) {
        final msg = isTimeout
            ? 'Connexion trop lente. Vérifiez votre réseau et réessayez.'
            : e.toString();
        state = state.copyWith(isLoading: false, error: msg);
        rethrow;
      }

      // Backoff : 2s, 4s, 6s
      await Future.delayed(Duration(seconds: attempt * 2));
    }
  }
}

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final missionSessionProvider =
    StateNotifierProvider.family<MissionSessionNotifier, MissionSessionState, String>(
  (ref, reservationId) {
    final repo = ref.watch(missionSessionRepositoryProvider);
    return MissionSessionNotifier(repo);
  },
);

// ─────────────────────────────────────────
// LOCAL PHOTOS STATE (collected before upload)
// ─────────────────────────────────────────

class LocalPhotoState {
  final Map<TypeMediaSession, String> photos; // typeMedia -> base64Data

  const LocalPhotoState({this.photos = const {}});

  LocalPhotoState addPhoto(TypeMediaSession type, String base64Data) {
    return LocalPhotoState(photos: {...photos, type: base64Data});
  }

  LocalPhotoState removePhoto(TypeMediaSession type) {
    final updated = Map<TypeMediaSession, String>.from(photos);
    updated.remove(type);
    return LocalPhotoState(photos: updated);
  }

  bool hasPhoto(TypeMediaSession type) => photos.containsKey(type);

  bool hasAllRequired(List<TypeMediaSession> required) =>
      required.every((t) => photos.containsKey(t));

  List<TypeMediaSession> missingFrom(List<TypeMediaSession> required) =>
      required.where((t) => !photos.containsKey(t)).toList();

  List<MediaUploadInputModel> toUploadInputs() {
    return photos.entries
        .map((e) => MediaUploadInputModel(
              typeMedia: e.key,
              base64Data: e.value,
              typeContenu: 'image/jpeg',
            ))
        .toList();
  }

  String? getBase64(TypeMediaSession type) => photos[type];
}

class LocalPhotoNotifier extends StateNotifier<LocalPhotoState> {
  LocalPhotoNotifier() : super(const LocalPhotoState());

  void addPhoto(TypeMediaSession type, String base64Data) {
    state = state.addPhoto(type, base64Data);
  }

  void removePhoto(TypeMediaSession type) {
    state = state.removePhoto(type);
  }

  void clear() {
    state = const LocalPhotoState();
  }
}

final prePhotosProvider =
    StateNotifierProvider.autoDispose<LocalPhotoNotifier, LocalPhotoState>(
  (ref) => LocalPhotoNotifier(),
);

final postPhotosProvider =
    StateNotifierProvider.autoDispose<LocalPhotoNotifier, LocalPhotoState>(
  (ref) => LocalPhotoNotifier(),
);

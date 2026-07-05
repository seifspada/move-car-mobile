// presentation/providers/mission_session_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/graphql/graphql_client.dart';
import '../../data/models/mission_session_model.dart';
import '../../data/repositories/mission_session_repository_impl.dart';
import '../../domain/entities/mission_session_entity.dart';

// ─────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────

final missionSessionRepositoryProvider = Provider<MissionSessionRepository>((ref) {
  final client = ref.watch(graphqlClientProvider);
  return MissionSessionRepository(client: client);
});

// ─────────────────────────────────────────
// SESSION STATE
// ─────────────────────────────────────────

class MissionSessionState {
  final MissionSessionEntity? session;
  final bool isLoading;

  /// Erreur bloquante : la MUTATION elle-même a échoué.
  /// L'UI doit afficher un message d'erreur clair et empêcher la navigation.
  final String? mutationError;

  /// Avertissement non-bloquant : la mutation a réussi mais le refetch
  /// pour synchroniser l'état local a échoué.
  /// L'UI peut naviguer mais afficher un toast/snackbar discret.
  final String? refreshWarning;

  const MissionSessionState({
    this.session,
    this.isLoading = false,
    this.mutationError,
    this.refreshWarning,
  });

  MissionSessionState copyWith({
    MissionSessionEntity? session,
    bool? isLoading,
    String? mutationError,
    String? refreshWarning,
    bool clearMutationError = false,
    bool clearRefreshWarning = false,
  }) {
    return MissionSessionState(
      session: session ?? this.session,
      isLoading: isLoading ?? this.isLoading,
      mutationError: clearMutationError ? null : (mutationError ?? this.mutationError),
      refreshWarning: clearRefreshWarning ? null : (refreshWarning ?? this.refreshWarning),
    );
  }

  /// Rétro-compatibilité : expose "error" pour les widgets existants qui
  /// affichent state.error. Pointe vers mutationError (le seul cas bloquant).
  String? get error => mutationError;

  bool get hasSession => session != null;
  bool get isEnCours => session?.statut == StatutSession.EN_COURS;
}

// ─────────────────────────────────────────
// SESSION NOTIFIER
// ─────────────────────────────────────────

class MissionSessionNotifier extends StateNotifier<MissionSessionState> {
  final MissionSessionRepository _repo;

  MissionSessionNotifier(this._repo) : super(const MissionSessionState());

  // ── Load session (refetch initial) ─────────────────────────────

  /// Charge la session depuis le backend via getMyMissionSessions.
  /// Un échec ici n'est pas bloquant : on affiche juste un avertissement.
  Future<void> loadSession(String reservationId) async {
    state = state.copyWith(isLoading: true, clearMutationError: true, clearRefreshWarning: true);
    try {
      final session = await _repo.getSessionByReservation(reservationId);
      state = state.copyWith(session: session, isLoading: false);
    } on MissionSessionException catch (e) {
      // Le chargement initial a échoué : on affiche un avertissement non-bloquant
      // car l'utilisateur n'a encore rien soumis.
      state = state.copyWith(
        isLoading: false,
        refreshWarning: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        refreshWarning: e.toString(),
      );
    }
  }

  // ── Start session ──────────────────────────────────────────────

  /// Lance la mutation startMissionSession.
  /// - Si la MUTATION échoue → mutationError (bloquant, affiché dans l'UI).
  /// - La mutation retourne l'entité complète → pas de refetch nécessaire.
  Future<void> startSession(StartMissionSessionInputModel input) async {
    state = state.copyWith(
      isLoading: true,
      clearMutationError: true,
      clearRefreshWarning: true,
    );

    try {
      final session = await _repo.startSession(input);
      // La mutation a réussi et retourne les données complètes → mise à jour locale directe.
      state = state.copyWith(session: session, isLoading: false);
    } on MissionSessionException catch (e) {
      // Erreur GraphQL ou réseau côté mutation → bloquant.
      state = state.copyWith(isLoading: false, mutationError: e.message);
      rethrow;
    } catch (e) {
      final msg = _friendlyError(e);
      state = state.copyWith(isLoading: false, mutationError: msg);
      rethrow;
    }
  }

  // ── End session ────────────────────────────────────────────────

  /// Lance la mutation endMissionSession.
  /// - Si la MUTATION échoue → mutationError (bloquant, affiché dans l'UI).
  /// - La mutation retourne l'entité complète → pas de refetch nécessaire.
  Future<void> endSession(EndMissionSessionInputModel input) async {
    state = state.copyWith(
      isLoading: true,
      clearMutationError: true,
      clearRefreshWarning: true,
    );

    try {
      final session = await _repo.endSession(input);
      // La mutation a réussi et retourne les données complètes → mise à jour locale directe.
      state = state.copyWith(session: session, isLoading: false);
    } on MissionSessionException catch (e) {
      // Erreur GraphQL ou réseau côté mutation → bloquant.
      state = state.copyWith(isLoading: false, mutationError: e.message);
      rethrow;
    } catch (e) {
      final msg = _friendlyError(e);
      state = state.copyWith(isLoading: false, mutationError: msg);
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(clearMutationError: true, clearRefreshWarning: true);
  }

  // ── Helpers ────────────────────────────────────────────────────

  /// Traduit les exceptions techniques en messages lisibles.
  /// On distingue les erreurs réseau/timeout des erreurs inconnues.
  String _friendlyError(Object e) {
    final msg = e.toString();
    final isNetwork = msg.contains('TimeoutException') ||
        msg.contains('No stream event') ||
        msg.contains('SocketException') ||
        msg.contains('Connection refused');
    if (isNetwork) {
      return 'Connexion trop lente ou indisponible. Vérifiez votre réseau et réessayez.';
    }
    return msg;
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

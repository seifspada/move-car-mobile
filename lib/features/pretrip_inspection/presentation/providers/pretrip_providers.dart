// lib/features/pretrip_inspection/presentation/providers/pretrip_providers.dart

import 'package:convoyeur_mobile/features/pretrip_inspection/data/repositories/pretrip_repository_impl.dart';
import 'package:convoyeur_mobile/features/pretrip_inspection/domain/entities/pretrip_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/graphql/graphql_client.dart';
import '../../../../core/network/rest/dio_client.dart';
import '../../../../core/config/app_config.dart';

// ─────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────

final preTripRepositoryProvider = Provider<PreTripRepository>((ref) {
  final graphqlClient = ref.read(graphqlClientProvider);
  final dio = ref.read(dioProvider);
  return PreTripRepository(
    graphqlClient: graphqlClient,
    dio: dio,
    baseUrl: AppConfig.restBaseUrl,
  );
});

// ─────────────────────────────────────────
// RÉSULTAT DE VALIDATION
// Remplace ValidationResultModel qui n'existe plus côté GraphQL
// ─────────────────────────────────────────

class ValidationResult {
  /// true  → statut VALIDATED  (mission démarrée)
  /// false → statut REJECTED   (motif dans [motifRejet])
  final bool success;
  final PreTripInspectionModel inspection;

  const ValidationResult({required this.success, required this.inspection});

  String? get motifRejet => inspection.motifRejet;
}

// ─────────────────────────────────────────
// INSPECTION STATE
// ─────────────────────────────────────────

class PreTripState {
  final PreTripInspectionModel? inspection;
  final Map<TypeMediaInspection, MediaUploadState> mediaStates;
  final bool isLoading;
  final String? error;
  final bool consentSubmitted;
  final bool initialized;

  const PreTripState({
    this.inspection,
    this.mediaStates = const {},
    this.isLoading = false,
    this.error,
    this.consentSubmitted = false,
    this.initialized = false,
  });

  PreTripState copyWith({
    PreTripInspectionModel? inspection,
    Map<TypeMediaInspection, MediaUploadState>? mediaStates,
    bool? isLoading,
    String? error,
    bool? consentSubmitted,
    bool? initialized,
  }) {
    return PreTripState(
      inspection: inspection ?? this.inspection,
      mediaStates: mediaStates ?? this.mediaStates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      consentSubmitted: consentSubmitted ?? this.consentSubmitted,
      initialized: initialized ?? this.initialized,
    );
  }

  // ── Helpers calculés ──────────────────

  bool isMediaUploadedFor(TypeMediaInspection type) =>
      mediaStates[type]?.isUploaded ?? false;

  int get uploadedCount => mediaStates.values.where((s) => s.isUploaded).length;

  EtapeInspection get currentStep =>
      inspection?.etapeCourante ?? EtapeInspection.exterieur;

  bool isStepComplete(EtapeInspection step) {
    final required = InspectionStepMedia.byStep[step] ?? [];
    return required.every((t) => mediaStates[t]?.isUploaded == true);
  }

  /// true si toutes les 12 photos sont uploadées et le consentement signé
  bool get peutValider => inspection?.peutEtreValidee ?? false;

  /// true si l'inspection a été validée (mission démarrée)
  bool get isValidated => inspection?.statut == StatutPreTrip.validated;

  /// true si l'inspection a été rejetée par l'anti-fraude
  bool get isRejected => inspection?.statut == StatutPreTrip.rejected;
}

// ─────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────

class PreTripNotifier extends StateNotifier<PreTripState> {
  final PreTripRepository _repository;
  final String _token;

  PreTripNotifier(this._repository, this._token) : super(const PreTripState());

  // ── Chargement depuis le serveur ──────

  Future<void> loadInspection(String reservationId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final inspection = await _repository.getInspectionByReservation(
        reservationId,
      );
      if (inspection != null) {
        final mediaStates = _buildMediaStates(inspection);
        state = state.copyWith(
          inspection: inspection,
          mediaStates: mediaStates,
          isLoading: false,
          initialized: true,
        );
      } else {
        state = state.copyWith(isLoading: false, initialized: true);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        initialized: true,
      );
    }
  }

  // ── Démarrage de l'inspection ─────────

  Future<void> startInspection({
    required String reservationId,
    double? lat,
    double? lng,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final inspection = await _repository.startInspection(
        reservationId: reservationId,
        latitudeDebut: lat,
        longitudeDebut: lng,
      );
      state = state.copyWith(
        inspection: inspection,
        mediaStates: const {},
        isLoading: false,
        initialized: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Upload d'une photo ─────────────────

  Future<bool> uploadMedia({
    required TypeMediaInspection type,
    required XFile imageFile,
  }) async {
    final inspectionId = state.inspection?.id;
    if (inspectionId == null) return false;
    final localBytes = await imageFile.readAsBytes();

    // Marquer comme "en cours"
    final updatedStates = Map<TypeMediaInspection, MediaUploadState>.from(
      state.mediaStates,
    );
    updatedStates[type] = MediaUploadState(
      type: type,
      isUploading: true,
      localPath: imageFile.path,
      localBytes: localBytes,
    );
    state = state.copyWith(mediaStates: updatedStates, error: null);

    try {
      await _repository.uploadMedia(
        inspectionId: inspectionId,
        typeMedia: type,
        imageFile: imageFile,
        token: _token,
      );
      updatedStates[type] = MediaUploadState(
        type: type,
        isUploaded: true,
        localPath: imageFile.path,
        localBytes: localBytes,
      );
      state = state.copyWith(mediaStates: updatedStates);
      return true;
    } catch (e) {
      updatedStates[type] = MediaUploadState(
        type: type,
        localPath: imageFile.path,
        localBytes: localBytes,
        error: e.toString(),
      );
      state = state.copyWith(mediaStates: updatedStates, error: e.toString());
      return false;
    }
  }

  // ── Soumission du consentement ─────────

  Future<bool> submitConsent({
    required Map<String, bool> clauses,
    double? lat,
    double? lng,
  }) async {
    final inspectionId = state.inspection?.id;
    if (inspectionId == null) return false;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await _repository.submitConsent(
        inspectionId: inspectionId,
        versionConditions: 'v1.0',
        vehiculeVerifie: clauses['vehiculeVerifie'] ?? false,
        photosReelles: clauses['photosReelles'] ?? false,
        codeRoute: clauses['codeRoute'] ?? false,
        conduiteResponsable: clauses['conduiteResponsable'] ?? false,
        suiviGps: clauses['suiviGps'] ?? false,
        scoringConduite: clauses['scoringConduite'] ?? false,
        responsabiliteNegligence: clauses['responsabiliteNegligence'] ?? false,
        apteAConduire: clauses['apteAConduire'] ?? false,
        acceptationGlobale: clauses['acceptationGlobale'] ?? false,
        latitude: lat,
        longitude: lng,
      );
      state = state.copyWith(
        inspection: updated,
        isLoading: false,
        consentSubmitted: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // ── Validation finale + démarrage mission ─

  /// ✅ Retourne ValidationResult (local) basé sur PreTripInspectionModel
  ///    success = true  → statut VALIDATED
  ///    success = false → statut REJECTED (motifRejet disponible)
  Future<ValidationResult?> validateAndStart({double? lat, double? lng}) async {
    final inspectionId = state.inspection?.id;
    if (inspectionId == null) return null;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedInspection = await _repository.validateAndStartMission(
        inspectionId: inspectionId,
        latitudeFin: lat,
        longitudeFin: lng,
      );
      state = state.copyWith(inspection: updatedInspection, isLoading: false);
      return ValidationResult(
        success: updatedInspection.statut == StatutPreTrip.validated,
        inspection: updatedInspection,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // ── Helpers privés ─────────────────────

  /// Reconstruit la map des états médias à partir d'une inspection chargée
  Map<TypeMediaInspection, MediaUploadState> _buildMediaStates(
    PreTripInspectionModel inspection,
  ) {
    final map = <TypeMediaInspection, MediaUploadState>{};
    for (final media in inspection.medias) {
      map[media.typeMedia] = MediaUploadState(
        type: media.typeMedia,
        isUploaded: media.validatedByServer,
      );
    }
    return map;
  }
}

// ─────────────────────────────────────────
// FAMILY PROVIDER
// ─────────────────────────────────────────

/// Clé = reservationId
/// Le token est injecté automatiquement par AuthInterceptor dans Dio
final preTripProvider =
    StateNotifierProvider.family<PreTripNotifier, PreTripState, String>((
      ref,
      reservationId,
    ) {
      final repo = ref.watch(preTripRepositoryProvider);
      return PreTripNotifier(repo, ''); // token géré par AuthInterceptor
    });

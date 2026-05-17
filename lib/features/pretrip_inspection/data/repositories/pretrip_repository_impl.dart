// lib/features/pretrip_inspection/data/repositories/pretrip_repository_impl.dart

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../graphql/pretrip_queries.dart';
import '../models/pretrip_model.dart';
import 'upload_location.dart';

class PreTripRepository {
  final GraphQLClient _graphqlClient;
  final Dio _dio;
  final String _baseUrl;

  PreTripRepository({
    required GraphQLClient graphqlClient,
    required Dio dio,
    required String baseUrl,
  }) : _graphqlClient = graphqlClient,
       _dio = dio,
       _baseUrl = baseUrl;

  // ─────────────────────────────────────────
  // MUTATIONS
  // ─────────────────────────────────────────

  Future<PreTripInspectionModel> startInspection({
    required String reservationId,
    double? latitudeDebut,
    double? longitudeDebut,
  }) async {
    final result = await _graphqlClient
        .mutate(
          MutationOptions(
            document: gql(PreTripQueries.startInspection),
            variables: {
              'input': {
                'reservationId': reservationId,
                if (latitudeDebut != null) 'latitudeDebut': latitudeDebut,
                if (longitudeDebut != null) 'longitudeDebut': longitudeDebut,
              },
            },
          ),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () =>
              throw TimeoutException('startInspection a expiré après 30s'),
        );

    _handleGraphQLErrors(result);
    return PreTripInspectionModel.fromJson(
      result.data!['startInspection'] as Map<String, dynamic>,
    );
  }

  /// Upload via REST multipart (photos avec EXIF GPS)
  /// ✅ typeMedia.jsonValue utilisé à la place de .name.toUpperCase()
  ///    pour garantir EXT_FACE_AVANT et non extfaceavant
  Future<PreTripMediaModel> uploadMedia({
    required String inspectionId,
    required TypeMediaInspection typeMedia,
    required XFile imageFile,
    required String token,
  }) async {
    final typeMediaStr =
        typeMedia.jsonValue; // ✅ EXT_FACE_AVANT, PERMIS_RECTO, etc.
    final mimeType = _imageMimeType(imageFile);
    final extension = _extensionForMimeType(mimeType);
    final filename =
        '${typeMediaStr}_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final location = await getUploadLocation();
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        await imageFile.readAsBytes(),
        filename: filename,
        contentType: DioMediaType.parse(mimeType),
      ),
      if (location != null) 'latitude': location.latitude.toString(),
      if (location != null) 'longitude': location.longitude.toString(),
      if (location?.accuracy != null)
        'precisionGps': location!.accuracy.toString(),
      'timestampPhoto': DateTime.now().toIso8601String(),
    });

    try {
      final response = await _dio.post(
        '$_baseUrl/pretrip-inspection/$inspectionId/media/$typeMediaStr',
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
          'Upload échoué (${response.statusCode}) : ${response.data}',
        );
      }

      return PreTripMediaModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final serverMessage = _extractRestErrorMessage(e.response?.data);
      throw Exception(
        statusCode == null
            ? 'Upload impossible : ${e.message ?? e.type.name}'
            : 'Upload refuse ($statusCode) : $serverMessage',
      );
    }
  }

  Future<PreTripInspectionModel> submitConsent({
    required String inspectionId,
    required String versionConditions,
    required bool vehiculeVerifie,
    required bool photosReelles,
    required bool codeRoute,
    required bool conduiteResponsable,
    required bool suiviGps,
    required bool scoringConduite,
    required bool responsabiliteNegligence,
    required bool apteAConduire,
    required bool acceptationGlobale,
    double? latitude,
    double? longitude,
  }) async {
    final result = await _graphqlClient
        .mutate(
          MutationOptions(
            document: gql(PreTripQueries.submitConsent),
            variables: {
              'input': {
                'inspectionId': inspectionId,
                'versionConditions': versionConditions,
                'vehiculeVerifie': vehiculeVerifie,
                'photosReelles': photosReelles,
                'codeRoute': codeRoute,
                'conduiteResponsable': conduiteResponsable,
                'suiviGps': suiviGps,
                'scoringConduite': scoringConduite,
                'responsabiliteNegligence': responsabiliteNegligence,
                'apteAConduire': apteAConduire,
                'acceptationGlobale': acceptationGlobale,
                if (latitude != null) 'latitude': latitude,
                if (longitude != null) 'longitude': longitude,
              },
            },
          ),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () =>
              throw TimeoutException('submitConsent a expiré après 30s'),
        );

    _handleGraphQLErrors(result);
    return PreTripInspectionModel.fromJson(
      result.data!['submitConsent'] as Map<String, dynamic>,
    );
  }

  /// ✅ Retourne PreTripInspectionModel (le resolver NestJS retourne PreTripInspection,
  ///    pas un ValidationResultModel)
  Future<PreTripInspectionModel> validateAndStartMission({
    required String inspectionId,
    double? latitudeFin,
    double? longitudeFin,
  }) async {
    final result = await _graphqlClient
        .mutate(
          MutationOptions(
            document: gql(PreTripQueries.validateAndStartMission),
            variables: {
              'input': {
                'inspectionId': inspectionId,
                if (latitudeFin != null) 'latitudeFin': latitudeFin,
                if (longitudeFin != null) 'longitudeFin': longitudeFin,
              },
            },
          ),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException(
            'validateAndStartMission a expiré après 30s',
          ),
        );

    _handleGraphQLErrors(result);
    return PreTripInspectionModel.fromJson(
      result.data!['validateAndStartMission'] as Map<String, dynamic>,
    );
  }

  // ─────────────────────────────────────────
  // QUERIES
  // ─────────────────────────────────────────

  Future<PreTripInspectionModel?> getInspectionByReservation(
    String reservationId,
  ) async {
    final result = await _graphqlClient
        .query(
          QueryOptions(
            document: gql(PreTripQueries.getInspectionByReservation),
            variables: {'reservationId': reservationId},
            fetchPolicy: FetchPolicy.networkOnly,
          ),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () => throw TimeoutException(
            'getInspectionByReservation a expiré après 30s — '
            'vérifiez que le serveur GraphQL est accessible',
          ),
        );

    _handleGraphQLErrors(result);
    final data = result.data?['getInspectionByReservation'];
    if (data == null) return null;
    return PreTripInspectionModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PreTripInspectionModel> getInspectionDetails(
    String inspectionId,
  ) async {
    final result = await _graphqlClient
        .query(
          QueryOptions(
            document: gql(PreTripQueries.getInspectionDetails),
            variables: {'inspectionId': inspectionId},
            fetchPolicy: FetchPolicy.networkOnly,
          ),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () =>
              throw TimeoutException('getInspectionDetails a expiré après 30s'),
        );

    _handleGraphQLErrors(result);
    return PreTripInspectionModel.fromJson(
      result.data!['getInspectionDetails'] as Map<String, dynamic>,
    );
  }

  /// ✅ Sérialisation du statut via jsonValue pour matcher le backend
  ///    ex: StatutPreTrip.inProgress → 'IN_PROGRESS' (pas 'inProgress')
  Future<List<PreTripInspectionModel>> listInspections({
    StatutPreTrip? statut,
    String? reservationId,
  }) async {
    final Map<String, dynamic> filter = {};
    if (statut != null) {
      filter['statut'] = _statutToJson(statut);
    }
    if (reservationId != null) filter['reservationId'] = reservationId;

    final result = await _graphqlClient
        .query(
          QueryOptions(
            document: gql(PreTripQueries.listInspections),
            variables: {'filter': filter.isEmpty ? null : filter},
            fetchPolicy: FetchPolicy.networkOnly,
          ),
        )
        .timeout(
          const Duration(seconds: 30),
          onTimeout: () =>
              throw TimeoutException('listInspections a expiré après 30s'),
        );

    _handleGraphQLErrors(result);
    final list = result.data!['listInspections'] as List<dynamic>;
    return list
        .map((e) => PreTripInspectionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─────────────────────────────────────────
  // HELPERS PRIVÉS
  // ─────────────────────────────────────────

  /// ✅ Convertit StatutPreTrip en valeur JSON attendue par le backend
  String _statutToJson(StatutPreTrip statut) {
    switch (statut) {
      case StatutPreTrip.draft:
        return 'DRAFT';
      case StatutPreTrip.inProgress:
        return 'IN_PROGRESS';
      case StatutPreTrip.completed:
        return 'COMPLETED';
      case StatutPreTrip.validated:
        return 'VALIDATED';
      case StatutPreTrip.rejected:
        return 'REJECTED';
    }
  }

  // ─────────────────────────────────────────
  String _imageMimeType(XFile imageFile) {
    final mimeType = imageFile.mimeType?.toLowerCase();
    if (mimeType != null && mimeType.startsWith('image/')) {
      return mimeType == 'image/jpg' ? 'image/jpeg' : mimeType;
    }

    final name = imageFile.name.toLowerCase();
    if (name.endsWith('.png')) return 'image/png';
    if (name.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  String _extensionForMimeType(String mimeType) {
    switch (mimeType) {
      case 'image/png':
        return 'png';
      case 'image/webp':
        return 'webp';
      default:
        return 'jpg';
    }
  }

  String _extractRestErrorMessage(dynamic data) {
    if (data is Map) {
      final message = data['message'];
      if (message is List && message.isNotEmpty) {
        return message.first.toString();
      }
      if (message is String && message.isNotEmpty) return message;
      final error = data['error'];
      if (error is String && error.isNotEmpty) return error;
    }
    if (data != null && data.toString().isNotEmpty) return data.toString();
    return 'requete refusee par le serveur';
  }

  // ERROR HANDLING
  // ─────────────────────────────────────────

  void _handleGraphQLErrors(dynamic result) {
    if (!result.hasException) return;

    final exception = result.exception;

    // 1. Erreurs métier GraphQL (ex: "RESERVATION_NOT_FOUND")
    if (exception?.graphqlErrors?.isNotEmpty == true) {
      final messages = exception!.graphqlErrors
          .map((e) => e.message)
          .join('\n');
      throw Exception(messages);
    }

    // 2. Erreurs réseau / link
    final linkEx = exception?.linkException;
    if (linkEx != null) {
      final original = linkEx.originalException;

      if (original is TimeoutException) {
        throw Exception(
          'Timeout : le serveur GraphQL ne répond pas. '
          'Vérifiez que le backend est démarré et accessible.',
        );
      }
      final originalType = original.runtimeType.toString();
      if (originalType == 'SocketException') {
        throw Exception(
          "Impossible de joindre le serveur (SocketException). "
          "Vérifiez l'URL GraphQL et votre réseau.",
        );
      }
      if (originalType == 'HttpException') {
        throw Exception('Erreur HTTP : $original');
      }

      throw Exception(
        linkEx.toString().isNotEmpty
            ? linkEx.toString()
            : 'Erreur réseau inconnue',
      );
    }

    throw Exception('Erreur GraphQL inconnue');
  }
}

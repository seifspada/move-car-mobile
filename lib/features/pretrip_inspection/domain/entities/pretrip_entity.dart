// lib/features/pretrip_inspection/domain/entities/pretrip_entity.dart

// Re-export pour cohérence avec l'architecture feature-first
import 'dart:typed_data';

export 'package:convoyeur_mobile/features/pretrip_inspection/data/models/pretrip_model.dart'
    show
        PreTripInspectionModel,
        PreTripMediaModel,
        PreTripConsentModel,
        ValidationResultModel,
        StatutPreTrip,
        EtapeInspection,
        TypeMediaInspection,
        TypeMediaInspectionX,
        EtapeInspectionX;

import 'package:convoyeur_mobile/features/pretrip_inspection/data/models/pretrip_model.dart'
    show EtapeInspection, TypeMediaInspection;

/// État local de l'upload pour un type de média
class MediaUploadState {
  final TypeMediaInspection type;
  final bool isUploading;
  final bool isUploaded;
  final String? localPath;
  final Uint8List? localBytes;
  final String? error;

  const MediaUploadState({
    required this.type,
    this.isUploading = false,
    this.isUploaded = false,
    this.localPath,
    this.localBytes,
    this.error,
  });

  MediaUploadState copyWith({
    bool? isUploading,
    bool? isUploaded,
    String? localPath,
    Uint8List? localBytes,
    String? error,
  }) {
    return MediaUploadState(
      type: type,
      isUploading: isUploading ?? this.isUploading,
      isUploaded: isUploaded ?? this.isUploaded,
      localPath: localPath ?? this.localPath,
      localBytes: localBytes ?? this.localBytes,
      error: error,
    );
  }
}

/// ✅ CORRIGÉ : types alignés sur le backend NestJS (12 photos)
class InspectionStepMedia {
  static const Map<EtapeInspection, List<TypeMediaInspection>> byStep = {
    EtapeInspection.exterieur: [
      TypeMediaInspection.extFaceAvant,
      TypeMediaInspection.extFaceArriere,
      TypeMediaInspection.extCoteGauche,
      TypeMediaInspection.extCoteDroit,
    ],
    EtapeInspection.interieur: [
      TypeMediaInspection.intSiegeConducteur,
      TypeMediaInspection.intSiegePassager,
      TypeMediaInspection.intBanquetteArriere,
      TypeMediaInspection.intVueGlobale,
    ],
    EtapeInspection.tableauBord: [TypeMediaInspection.tableauBord],
    EtapeInspection.documents: [
      TypeMediaInspection.permisRecto,
      TypeMediaInspection.permisVerso,
    ],
    EtapeInspection.identite: [TypeMediaInspection.selfieVehicule],
  };

  static List<EtapeInspection> get orderedSteps => [
    EtapeInspection.exterieur,
    EtapeInspection.interieur,
    EtapeInspection.tableauBord,
    EtapeInspection.documents,
    EtapeInspection.identite,
    EtapeInspection.conditions,
  ];

  /// Total = 4 + 4 + 1 + 2 + 1 = 12
  static int get totalMediaCount =>
      byStep.values.fold(0, (sum, list) => sum + list.length);
}

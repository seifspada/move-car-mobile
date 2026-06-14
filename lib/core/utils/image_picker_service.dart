// lib/core/utils/image_picker_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'platform_utils.dart';

/// Service de sélection/capture d'images adapté à la plateforme
class ImagePickerService {
  /// Démonstration d'image en base64 (petit PNG 1x1 bleu)
  static const String _mockImageBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+P+/HgAFhAJ/wlseKgAAAABJRU5ErkJggg==';

  /// Capture une photo via la caméra
  static Future<String?> capturePhoto() async {
    if (PlatformUtils.isWeb) {
      debugPrint('📸 Web: Utilisation d\'image de démonstration');
      _showWebMessage('Caméra simulée - Image de démo chargée');
      return 'data:image/png;base64,$_mockImageBase64';
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      final bytes = await pickedFile.readAsBytes();
      return 'data:image/jpeg;base64,${base64Encode(bytes)}';
    } catch (e) {
      debugPrint('Erreur capture photo: $e');
      return null;
    }
  }

  /// Sélectionne une image depuis la galerie
  static Future<String?> pickImageFromGallery() async {
    if (PlatformUtils.isWeb) {
      debugPrint('🖼️ Web: Galerie simulée');
      _showWebMessage('Sélection depuis galerie simulée');
      return 'data:image/png;base64,$_mockImageBase64';
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      final bytes = await pickedFile.readAsBytes();
      return 'data:image/jpeg;base64,${base64Encode(bytes)}';
    } catch (e) {
      debugPrint('Erreur sélection image: $e');
      return null;
    }
  }

  /// Affiche un message pour informer l'utilisateur que c'est une simulation
  static void _showWebMessage(String message) {
    debugPrint('💡 Info Web: $message');
  }
}

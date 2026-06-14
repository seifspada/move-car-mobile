// lib/core/utils/platform_utils.dart

import 'package:flutter/foundation.dart';

/// Détecte la plateforme actuelle
class PlatformUtils {
  /// Vérifie si l'app s'exécute sur le web
  static bool get isWeb => kIsWeb;

  /// Vérifie si l'app s'exécute sur mobile (Android/iOS)
  static bool get isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static bool get isIOS =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isMobile => isAndroid || isIOS;

  /// Vérifie si la plateforme supporte les services natifs
  static bool get supportsNativeServices => isMobile;

  static bool get supportsBackgroundService => isAndroid || isIOS;

  /// Obtient le nom de la plateforme
  static String get platformName {
    if (kIsWeb) return 'web';
    if (defaultTargetPlatform == TargetPlatform.android) return 'android';
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return 'unknown';
  }
}

// lib/core/utils/logger.dart

import 'package:flutter/foundation.dart';
import '../../core/config/app_config.dart';

class AppLogger {
  static void info(String message) {
    if (AppConfig.isDebug) {
      debugPrint('ℹ️  [INFO] $message');
    }
  }

  static void success(String message) {
    if (AppConfig.isDebug) {
      debugPrint('✅ [SUCCESS] $message');
    }
  }

  static void warning(String message) {
    if (AppConfig.isDebug) {
      debugPrint('⚠️  [WARNING] $message');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (AppConfig.isDebug) {
      debugPrint('❌ [ERROR] $message');
      if (error != null) debugPrint('   Error: $error');
      if (stackTrace != null) debugPrint('   Stack: $stackTrace');
    }
  }

  static void network(String method, String url, {int? statusCode}) {
    if (AppConfig.isDebug) {
      debugPrint('🌐 [NETWORK] $method $url ${statusCode != null ? '→ $statusCode' : ''}');
    }
  }
}
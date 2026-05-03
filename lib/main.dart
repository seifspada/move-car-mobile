// lib/main.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/config/app_config.dart';

// ✅ Forcer 'prod' pour tester Render
// Remettre defaultValue: 'dev' quand le backend local est prêt
const String _env = String.fromEnvironment('ENV', defaultValue: 'prod');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final envFile = _env == 'prod' ? '.env.production' : '.env';

  try {
    await dotenv.load(fileName: envFile);
  } catch (e) {
    if (kDebugMode) {
      print('⚠️  Impossible de charger $envFile : $e');
    }
  }

  if (kDebugMode) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🌍 Environnement  : ${_env == 'prod' ? 'PRODUCTION' : 'LOCAL'}');
    print('📄 Fichier .env   : $envFile');
    print('🔧 API_URL (raw)  : ${dotenv.env['API_URL'] ?? 'NON TROUVÉ ⚠️'}');
    print('🚀 restBaseUrl    : ${AppConfig.restBaseUrl}');
    print('📡 graphqlUrl     : ${AppConfig.graphqlUrl}');
    print('🐛 debugMode      : ${AppConfig.isDebug}');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  // Réveille Render en avance (cold start)
  Future.microtask(() async {
    try {
      await Dio().get(
        '${AppConfig.restBaseUrl}/health',
        options: Options(
          sendTimeout: kIsWeb ? null : const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      if (kDebugMode) print('✅ Render réveillé');
    } catch (_) {
      if (kDebugMode) print('⏳ Render en cours de démarrage...');
    }
  });

  runApp(
    const ProviderScope(child: App()),
  );
}
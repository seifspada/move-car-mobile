// lib/main.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Généré par: flutterfire configure
import 'features/missions/data/repositories/firebase_notification_service.dart';
import 'app/app.dart';
import 'core/config/app_config.dart';

const String _env = String.fromEnvironment('ENV', defaultValue: 'prod');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ✅ Barre de navigation Android transparente (edge-to-edge)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  // ✅ Formatage des dates en français
  await initializeDateFormatting('fr_FR', null);

  // ✅ Chargement du fichier .env
  final envFile = _env == 'prod' ? '.env.production' : '.env';
  try {
    await dotenv.load(fileName: envFile);
  } catch (e) {
    if (kDebugMode) print('⚠️  Impossible de charger $envFile : $e');
  }

  // ✅ Initialisation Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kDebugMode) print('✅ Firebase initialisé');
  } catch (e) {
    if (kDebugMode) print('❌ Erreur initialisation Firebase: $e');
  }

  // ✅ Initialisation des notifications push (FCM)
  try {
    final notificationService = FirebaseNotificationService();
    await notificationService.initialize();
    if (kDebugMode) print('✅ Notifications Firebase initialisées');
  } catch (e) {
    if (kDebugMode) print('❌ Erreur initialisation notifications: $e');
  }

  // ✅ Logs de debug
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

  // ✅ Wake-up du serveur Render (non bloquant)
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

  runApp(const ProviderScope(child: App()));
}
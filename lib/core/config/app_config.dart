// lib/core/config/app_config.dart

import 'env.dart';

class AppConfig {
  static String get restBaseUrl  => Env.apiUrl;
  static String get graphqlUrl   => Env.graphqlUrl;
  static String get graphqlWsUrl => Env.graphqlWsUrl;
  static String get jwtSecret    => Env.jwtSecret;
  static bool   get isDebug      => Env.debugMode;
}
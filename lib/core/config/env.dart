// lib/core/config/env.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiUrl =>
      dotenv.env['API_URL'] ?? 'http://localhost:3000';

  static String get baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://localhost:3000';

  static String get graphqlUrl =>
      dotenv.env['GRAPHQL_URL'] ?? 'http://localhost:3000/graphql';

  static String get graphqlWsUrl =>
      graphqlUrl.replaceFirst('https', 'wss').replaceFirst('http', 'ws');

  static String get jwtSecret =>
      dotenv.env['JWT_SECRET'] ?? '';

  static bool get debugMode =>
      dotenv.env['DEBUG_MODE'] == 'true';
}
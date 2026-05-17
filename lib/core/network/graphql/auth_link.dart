// lib/core/network/graphql/auth_link.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppAuthLink extends AuthLink {
  static const _tokenKey = 'access_token';

  AppAuthLink()
      : super(
          getToken: () async {
            try {
              String? token;

              if (kIsWeb) {
                // Web → SharedPreferences uniquement
                final prefs = await SharedPreferences.getInstance();
                token = prefs.getString(_tokenKey);
              } else {
                // Mobile/Desktop → FlutterSecureStorage instancié localement
                const secure = FlutterSecureStorage();
                token = await secure.read(key: _tokenKey);
              }

              debugPrint(
                '🔑 TOKEN: ${token == null ? "NULL ⚠️" : "OK (${token.length} chars)"}',
              );

              if (token == null || token.isEmpty) return null;
              return 'Bearer $token';

            } catch (e) {
              debugPrint('🔑 AUTH LINK ERROR: $e');
              return null; // Ne pas crasher — laisser le serveur rejeter avec 401
            }
          },
        );
}
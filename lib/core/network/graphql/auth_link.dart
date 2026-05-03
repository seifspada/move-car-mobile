// lib/core/network/graphql/auth_link.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AppAuthLink extends AuthLink {
  static const _storage = FlutterSecureStorage();

  AppAuthLink()
      : super(
          getToken: () async {
            final token = await _storage.read(key: 'access_token');
            if (token == null || token.isEmpty) return null;
            return 'Bearer $token';
          },
        );
}
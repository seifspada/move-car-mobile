// lib/core/network/rest/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;
  final _storage = const FlutterSecureStorage();

  AuthInterceptor(this.ref);

@override
void onRequest(
  RequestOptions options,
  RequestInterceptorHandler handler,
) async {
  // ✅ Ajoute Content-Type json seulement si ce n'est pas un upload multipart
  final isMultipart = options.data is FormData;
  if (!isMultipart) {
    options.headers['Content-Type'] = 'application/json';
  }

  final isAuthRoute =
      options.path.contains('/auth/login') ||
      options.path.contains('/auth/register');

  if (!isAuthRoute) {
    final token = await _readToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer ${token.trim()}';
    }
  }

  handler.next(options);
}
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _deleteToken();
    }

    // Sur Chrome, DioException [unknown] avec response null = CORS sur erreur
    // On transforme en erreur lisible
    if (err.type == DioExceptionType.unknown && err.response == null) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          type: DioExceptionType.badResponse,
          message: 'Erreur réseau ou CORS — vérifier les credentials',
          error: err.error,
        ),
      );
    }

    handler.next(err);
  }

  Future<String?> _readToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('access_token');
    }
    return _storage.read(key: 'access_token');
  }

  Future<void> _deleteToken() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      return;
    }
    await _storage.delete(key: 'access_token');
  }
}

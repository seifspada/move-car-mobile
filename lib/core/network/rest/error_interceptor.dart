// lib/core/network/rest/error_interceptor.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/error/exceptions.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    // ✅ Sur Chrome : CORS error = type unknown, response null
    // Le backend a répondu mais Chrome bloque la lecture → on laisse passer
    if (err.type == DioExceptionType.unknown && err.response == null) {
      debugPrint('⚠️ CORS ou réseau : ${err.error}');
      // Rejeter avec un DioException propre que auth_remote_datasource peut lire
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          type: DioExceptionType.unknown,
          message: 'Erreur réseau (CORS ou connexion)',
          error: err.error,
        ),
      );
    }

    final statusCode = err.response?.statusCode;
    final message = _extractMessage(err.response);

    // ✅ Construire l'exception SANS throw — utiliser handler.reject()
    DioException transformed;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        transformed = _reject(err, 'Délai de connexion dépassé');
        break;

      case DioExceptionType.connectionError:
        transformed = _reject(err, 'Impossible de joindre le serveur');
        break;

      case DioExceptionType.badResponse:
        transformed = DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          type: DioExceptionType.badResponse,
          message: message,
          error: _buildException(statusCode, message),
        );
        break;

      default:
        transformed = _reject(err, err.message ?? 'Erreur inconnue');
    }

    handler.reject(transformed);
  }

  // ✅ Construire l'exception selon le status code
  Exception _buildException(int? statusCode, String message) {
    switch (statusCode) {
      case 400:
        return ServerException(message: message, statusCode: 400);
      case 401:
        return UnauthorizedException(message: 'Identifiants incorrects');
      case 403:
        return UnauthorizedException(message: 'Accès refusé');
      case 404:
        return ServerException(message: 'Ressource introuvable', statusCode: 404);
      case 500:
        return ServerException(message: 'Erreur serveur interne', statusCode: 500);
      default:
        return ServerException(message: message, statusCode: statusCode);
    }
  }

  DioException _reject(DioException original, String message) {
    return DioException(
      requestOptions: original.requestOptions,
      response: original.response,
      type: original.type,
      message: message,
      error: original.error,
    );
  }

  String _extractMessage(Response? response) {
    try {
      final data = response?.data;
      if (data is Map) {
        final msg = data['message'];
        if (msg is List) return msg.first.toString();
        if (msg is String) return msg;
      }
      return 'Erreur serveur';
    } catch (_) {
      return 'Erreur serveur';
    }
  }
}
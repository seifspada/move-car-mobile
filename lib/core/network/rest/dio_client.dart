// lib/core/network/rest/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.restBaseUrl,
      connectTimeout: const Duration(seconds: 90),
      receiveTimeout: const Duration(seconds: 90),
      // ⚠️ sendTimeout non supporté sur Flutter Web → null sur web
      sendTimeout: kIsWeb ? null : const Duration(seconds: 90),
      headers: {
       // 'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(ref),
    ErrorInterceptor(),
    _RenderWakeUpInterceptor(),
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: true,
      error: true,
      logPrint: (obj) => debugPrint('🌐 DIO: $obj'),
    ),
  ]);

  return dio;
});

/// Retry automatique si Render est en cold start
class _RenderWakeUpInterceptor extends Interceptor {
  static const int _maxRetries = 2;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra     = err.requestOptions.extra;
    final retryCount = (extra['_retryCount'] as int?) ?? 0;

    final isConnectionError =
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout    ||
        err.type == DioExceptionType.connectionError   ||
        err.type == DioExceptionType.unknown;

    if (isConnectionError && retryCount < _maxRetries) {
      debugPrint(
        '⏳ Render en cours de démarrage — tentative ${retryCount + 1}/$_maxRetries...',
      );

      await Future.delayed(const Duration(seconds: 6));

      final newOptions = err.requestOptions.copyWith(
        extra: {
          ...err.requestOptions.extra,
          '_retryCount': retryCount + 1,
        },
        // sendTimeout null sur web
        sendTimeout: kIsWeb ? null : const Duration(seconds: 90),
      );

      try {
        final retryDio = Dio(
          BaseOptions(
            baseUrl:        newOptions.baseUrl,
            connectTimeout: const Duration(seconds: 90),
            receiveTimeout: const Duration(seconds: 90),
            sendTimeout:    kIsWeb ? null : const Duration(seconds: 90),
            headers:        newOptions.headers,
          ),
        );
        final response = await retryDio.fetch(newOptions);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    return handler.next(err);
  }
}
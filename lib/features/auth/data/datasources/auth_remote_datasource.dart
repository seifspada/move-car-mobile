// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/rest/dio_client.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';

abstract class AuthRemoteDatasource {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final Dio dio;

  const AuthRemoteDatasourceImpl({required this.dio});

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: request.toJson(),
      );

      debugPrint('✅ RAW JSON: ${response.data}');

      final model = AuthResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      debugPrint('✅ accessToken: ${model.accessToken}');
      debugPrint('✅ user.nom: ${model.user.nom}');
      debugPrint('✅ user.prenom: ${model.user.prenom}');
      debugPrint('✅ user.role: ${model.user.role}');

      return model;
    } on DioException catch (e) {
      final error = e.error;
      if (error is UnauthorizedException) throw error;
      if (error is ServerException) throw error;
      if (error is NetworkException) throw error;

      String msg = e.message ?? 'Erreur de connexion';
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final raw = data['message'];
        if (raw is List) {
          msg = raw.first.toString();
        } else if (raw is String) {
          msg = raw;
        }
      }
      debugPrint('❌ LOGIN DioException: $msg (status: ${e.response?.statusCode})');
      throw ServerException(
        message: msg,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stack) {
      debugPrint('❌ LOGIN PARSE ERROR: $e');
      debugPrint('❌ STACK: $stack');
      rethrow;
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio.get('/auth/me');
      return UserModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final error = e.error;
      if (error is UnauthorizedException) throw error;
      if (error is ServerException) throw error;

      String msg = e.message ?? 'Erreur serveur';
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final raw = data['message'];
        if (raw is List) {
          msg = raw.first.toString();
        } else if (raw is String) {
          msg = raw;
        }
      }
      debugPrint('❌ GET_USER DioException: $msg (status: ${e.response?.statusCode})');
      throw ServerException(
        message: msg,
        statusCode: e.response?.statusCode,
      );
    } catch (e, stack) {
      debugPrint('❌ GET_USER PARSE ERROR: $e');
      debugPrint('❌ STACK: $stack');
      rethrow;
    }
  }
}

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  return AuthRemoteDatasourceImpl(dio: ref.read(dioProvider));
});
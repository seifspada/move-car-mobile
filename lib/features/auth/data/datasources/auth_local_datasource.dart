// lib/features/auth/data/datasources/auth_local_datasource.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDatasource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
  Future<void> clearAll();
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  static const _tokenKey  = 'access_token';
  static const _userIdKey = 'user_id';

  // Secure storage pour mobile/desktop
  static const _secure = FlutterSecureStorage();

  // Web : SharedPreferences (flutter_secure_storage crashe sur Chrome)
  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  @override
  Future<void> saveToken(String token) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      await prefs.setString(_tokenKey, token);
    } else {
      await _secure.write(key: _tokenKey, value: token);
    }
  }

  @override
  Future<String?> getToken() async {
    if (kIsWeb) {
      final prefs = await _prefs;
      return prefs.getString(_tokenKey);
    }
    return await _secure.read(key: _tokenKey);
  }

  @override
  Future<void> deleteToken() async {
    if (kIsWeb) {
      final prefs = await _prefs;
      await prefs.remove(_tokenKey);
    } else {
      await _secure.delete(key: _tokenKey);
    }
  }

  @override
  Future<void> saveUserId(String userId) async {
    if (kIsWeb) {
      final prefs = await _prefs;
      await prefs.setString(_userIdKey, userId);
    } else {
      await _secure.write(key: _userIdKey, value: userId);
    }
  }

  @override
  Future<String?> getUserId() async {
    if (kIsWeb) {
      final prefs = await _prefs;
      return prefs.getString(_userIdKey);
    }
    return await _secure.read(key: _userIdKey);
  }

  @override
  Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await _prefs;
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
    } else {
      await _secure.deleteAll();
    }
  }
}

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  return AuthLocalDatasourceImpl();
});
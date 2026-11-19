import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage() : _storage = const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'access_token';
  static const String _userKey = 'auth_user';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(
      key: _accessTokenKey,
      value: token,
    );
  }

  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(
      key: _userKey,
      value: jsonEncode(user),
    );
  }

  Future<Map<String, dynamic>> getUser() async {
    final value = await _storage.read(key: _userKey);

    if (value == null || value.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(value);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {
      // Data profil tidak valid akan diperlakukan sebagai kosong.
    }

    return <String, dynamic>{};
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  Future<void> deleteUser() async {
    await _storage.delete(key: _userKey);
  }

  Future<void> deleteSession() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _userKey);
  }
}

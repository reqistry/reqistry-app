import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthTokenService {
  static final AuthTokenService _instance = AuthTokenService._();
  factory AuthTokenService() => _instance;
  AuthTokenService._();

  static const String _boxName = 'auth_tokens';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiresAtKey = 'expires_at';
  static const String _deviceIdKey = 'device_id';
  static const String _deviceFingerprintKey = 'device_fingerprint';
  static const String _encryptionKeyName = 'auth_tokens_hive_key';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(migrateWithBackup: true),
  );

  late Box _box;

  Future<void> init() async {
    final storedKey = await _secureStorage.read(key: _encryptionKeyName);
    if (storedKey != null) {
      try {
        final cipher = HiveAesCipher(base64Url.decode(storedKey));
        _box = await Hive.openBox(_boxName, encryptionCipher: cipher);
        return;
      } catch (_) {
        // Corrupt key or interrupted first migration: drop local credentials
        // rather than weakening encryption. Force logout, keep encryption.
        await Hive.deleteBoxFromDisk(_boxName);
        await _secureStorage.delete(key: _encryptionKeyName);
      }
    }

    // First migration: persist the new key BEFORE deleting legacy data so a
    // crash/write failure retries instead of logging the user out.
    final legacyBox = await Hive.openBox(_boxName);
    final legacyData = Map<dynamic, dynamic>.from(legacyBox.toMap());
    await legacyBox.close();

    final key = Hive.generateSecureKey();
    await _secureStorage.write(
      key: _encryptionKeyName,
      value: base64UrlEncode(key),
    );
    await Hive.deleteBoxFromDisk(_boxName);
    _box = await Hive.openBox(
      _boxName,
      encryptionCipher: HiveAesCipher(key),
    );
    if (legacyData.isNotEmpty) {
      await _box.putAll(legacyData);
    }
  }

  String? get accessToken => _box.get(_accessTokenKey);
  String? get refreshToken => _box.get(_refreshTokenKey);
  String? get deviceId => _box.get(_deviceIdKey);
  String? get deviceFingerprint => _box.get(_deviceFingerprintKey);

  DateTime? get expiresAt {
    final ms = _box.get(_expiresAtKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  bool get isAuthenticated => accessToken != null && refreshToken != null;

  bool get isTokenExpired {
    final exp = expiresAt;
    if (exp == null) return true;
    return DateTime.now().isAfter(exp);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    String? deviceId,
    String? deviceFingerprint,
  }) async {
    await _box.put(_accessTokenKey, accessToken);
    await _box.put(_refreshTokenKey, refreshToken);
    await _box.put(
        _expiresAtKey,
        DateTime.now()
            .add(Duration(seconds: expiresIn))
            .millisecondsSinceEpoch);
    if (deviceId != null) await _box.put(_deviceIdKey, deviceId);
    if (deviceFingerprint != null) {
      await _box.put(_deviceFingerprintKey, deviceFingerprint);
    }
  }

  Future<void> updateAccessToken({
    required String accessToken,
    required int expiresIn,
  }) async {
    await _box.put(_accessTokenKey, accessToken);
    await _box.put(
        _expiresAtKey,
        DateTime.now()
            .add(Duration(seconds: expiresIn))
            .millisecondsSinceEpoch);
  }

  Future<void> clearTokens() async {
    await _box.clear();
  }

  String? getStoredDeviceId() => _box.get(_deviceIdKey);
}

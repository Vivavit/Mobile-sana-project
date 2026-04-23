import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _tokenKey = 'auth_token';
  static const String _warehouseIdKey = 'warehouse_id';
  static const String _warehouseNameKey = 'warehouse_name';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userPhoneKey = 'user_phone';
  static const String _userPermissionsKey = 'user_permissions';

  /// Save token securely
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get token securely
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Delete token
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Save all auth data
  static Future<void> saveAuthData({
    required String token,
    required String warehouseId,
    required String warehouseName,
    String? userName,
    String? userEmail,
    String? userPhone,
    List<String>? permissions,
  }) async {
    final futures = <Future>[
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _warehouseIdKey, value: warehouseId),
      _storage.write(key: _warehouseNameKey, value: warehouseName),
    ];

    if (userName != null) {
      futures.add(_storage.write(key: _userNameKey, value: userName));
    }
    if (userEmail != null) {
      futures.add(_storage.write(key: _userEmailKey, value: userEmail));
    }
    if (userPhone != null) {
      futures.add(_storage.write(key: _userPhoneKey, value: userPhone));
    }
    if (permissions != null) {
      futures.add(_storage.write(
        key: _userPermissionsKey,
        value: jsonEncode(permissions),
      ));
    }

    await Future.wait(futures);
  }

  /// Get warehouse ID
  static Future<String?> getWarehouseId() async {
    return await _storage.read(key: _warehouseIdKey);
  }

  /// Get warehouse name
  static Future<String?> getWarehouseName() async {
    return await _storage.read(key: _warehouseNameKey);
  }

  /// Get user name
  static Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }

  /// Get user phone
  static Future<String?> getUserPhone() async {
    return await _storage.read(key: _userPhoneKey);
  }

  /// Get user permissions
  static Future<List<String>?> getUserPermissions() async {
    final data = await _storage.read(key: _userPermissionsKey);
    if (data != null) {
      try {
        final List<dynamic> list = jsonDecode(data);
        return List<String>.from(list);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Save user permissions
  static Future<void> savePermissions(List<String> permissions) async {
    await _storage.write(
      key: _userPermissionsKey,
      value: jsonEncode(permissions),
    );
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    final warehouseId = await getWarehouseId();
    return token != null && warehouseId != null;
  }

  /// Clear all secure data (logout)
  static Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _warehouseIdKey),
      _storage.delete(key: _warehouseNameKey),
      _storage.delete(key: _userNameKey),
      _storage.delete(key: _userEmailKey),
      _storage.delete(key: _userPhoneKey),
    ]);
  }
}

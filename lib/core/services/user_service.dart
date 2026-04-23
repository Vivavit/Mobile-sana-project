import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_camsme_sana_project/core/constants/Config.dart';
import 'package:mobile_camsme_sana_project/core/models/user_model.dart';
import 'package:mobile_camsme_sana_project/core/services/secure_storage_service.dart';
import 'session.dart';

class UserService {
  static const String baseUrl = Config.apiBaseUrl;

  static Future<User?> getCurrentUser() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/me'),
            headers: {
              'Authorization': 'Bearer ${Session.token}',
              'Accept': 'application/json',
              'X-Client-Type': 'mobile',
            },
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('UserService.getCurrentUser response: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final userData = data is Map ? (data['user'] ?? data) : data;
        final user = User.fromJson(userData);

        // Sync permissions to Session and SecureStorage
        if (user.permissions != null) {
          Session.permissions = user.permissions;
          await SecureStorageService.savePermissions(user.permissions!);
        }

        return user;
      } else {
        debugPrint('Failed to load user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }
}

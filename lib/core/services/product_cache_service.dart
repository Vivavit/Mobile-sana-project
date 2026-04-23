import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_camsme_sana_project/core/models/product.dart';

class ProductCacheService {
  static const String _productsCacheKey = 'cached_products';
  static const String _cacheTimestampKey = 'products_cache_timestamp';
  static const int _cacheDuration = 5 * 60; // 5 minutes in seconds

  /// Cache products locally
  static Future<void> cacheProducts(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productJsonList = products.map((p) => p.toJson()).toList();
      await prefs.setString(_productsCacheKey, jsonEncode(productJsonList));
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error caching products: $e');
    }
  }

  /// Get cached products if they're still fresh
  static Future<List<Product>?> getCachedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_productsCacheKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);

      if (cachedJson == null || timestamp == null) {
        return null;
      }

      // Check if cache is still valid (less than 5 minutes old)
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (cacheAge > _cacheDuration * 1000) {
        return null; // Cache expired
      }

      final List<dynamic> jsonList = jsonDecode(cachedJson);
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting cached products: $e');
      return null;
    }
  }

  /// Clear product cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_productsCacheKey);
      await prefs.remove(_cacheTimestampKey);
    } catch (e) {
      debugPrint('Error clearing product cache: $e');
    }
  }

  /// Check if cache is valid
  static Future<bool> hasValidCache() async {
    final products = await getCachedProducts();
    return products != null && products.isNotEmpty;
  }
}

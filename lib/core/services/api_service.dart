import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mobile_camsme_sana_project/core/services/cache_service.dart';
import 'package:mobile_camsme_sana_project/core/services/session.dart';
import 'package:dio/dio.dart';

class ApiService {
  static late final Dio _dio;
  static bool _initialized = false;

  /// Initialize the Dio client with caching
  static Future<void> initialize() async {
    if (_initialized) return;
    _dio = await CacheService.createCachedDio();
    _initialized = true;
  }
    // Public getter — exposes the private _dioInstance
  static Future<Dio> get dioInstance => _dioInstance;

  // Public wrapper — exposes the private _handleRequest
  static Future<T> handleRequest<T>(Future<Response> Function() request) {
    return _handleRequest<T>(request);
  }

  /// Ensure Dio is initialized before making requests
  static Future<Dio> get _dioInstance async {
    if (!_initialized) {
      await initialize();
    }
    return _dio;
  }

  /// Helper method to handle API responses with proper error handling
  static Future<T> _handleRequest<T>(
    Future<Response> Function() request,
  ) async {
    try {
      final response = await request();

      if (response.statusCode == 200) {
        return response.data as T;
      } else {
        throw Exception(
          'API Error [${response.statusCode}]: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('No internet connection.');
      } else if (e.type == DioExceptionType.badResponse) {
        final message = e.response?.data?['message'] ?? 'Request failed';
        throw Exception(message);
      }
      rethrow;
    } catch (e) {
      debugPrint('ApiService error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final dio = await _dioInstance;

    return _handleRequest(
      () => dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      ),
    );
  }

  static Future<List<dynamic>> fetchProducts() async {
    final query = Session.warehouseId != null
        ? '?warehouse_id=${Session.warehouseId}'
        : '';

    final dio = await _dioInstance;
    final response = await _handleRequest<dynamic>(
      () => dio.get('/products$query'),
    );

    // Laravel typically returns {"success": true, "data": [...]}
    if (response is Map<String, dynamic>) {
      if (response.containsKey('data')) {
        return response['data'] as List<dynamic>;
      }
      // If no 'data' key but has 'products', use that
      if (response.containsKey('products')) {
        return response['products'] as List<dynamic>;
      }
    }

    // If response is already a list, return it
    if (response is List) {
      return response;
    }

    throw Exception('Invalid response format for products');
  }

  static Future<Map<String, dynamic>> fetchDashboardStats() async {
    final query = Session.warehouseId != null
        ? '?warehouse_id=${Session.warehouseId}'
        : '';

    final dio = await _dioInstance;

    return _handleRequest(
      () => dio.get('/dashboard$query'),
    );
  }

  static Future<Map<String, dynamic>> fetchAnalyticsSummary(
    String period,
  ) async {
    final query = Session.warehouseId != null
        ? '&warehouse_id=${Session.warehouseId}'
        : '';

    final dio = await _dioInstance;

    return _handleRequest(
      () => dio.get('/analytics/summary?period=$period$query'),
    );
  }

  static Future<List<Map<String, dynamic>>> fetchSalesChart(
    String period,
  ) async {
    final query = Session.warehouseId != null
        ? '&warehouse_id=${Session.warehouseId}'
        : '';

    final dio = await _dioInstance;
    final response = await _handleRequest<dynamic>(
      () => dio.get('/analytics/sales-chart?period=$period$query'),
    );

    if (response is Map<String, dynamic>) {
      // Try to extract data from common Laravel response formats
      if (response.containsKey('data')) {
        return (response['data'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    }

    if (response is List) {
      return response
          .map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  static Future<List<Map<String, dynamic>>> fetchTrendingProducts(
    String period,
  ) async {
    final query = Session.warehouseId != null
        ? '&warehouse_id=${Session.warehouseId}'
        : '';

    final dio = await _dioInstance;
    final response = await _handleRequest<dynamic>(
      () => dio.get('/analytics/trending?period=$period$query'),
    );

    if (response is Map<String, dynamic>) {
      // Try to extract data from common Laravel response formats
      if (response.containsKey('data')) {
        return (response['data'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      }
    }

    if (response is List) {
      return response
          .map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e))
          .toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> fetchInventoryStats() async {
    final query = Session.warehouseId != null
        ? '?warehouse_id=${Session.warehouseId}'
        : '';

    final dio = await _dioInstance;

    return _handleRequest(
      () => dio.get('/analytics/inventory-stats$query'),
    );
  }

  /// Force refresh - bypasses cache for this request
  static Future<List<dynamic>> fetchProductsForceRefresh() async {
    final query = Session.warehouseId != null
        ? '?warehouse_id=${Session.warehouseId}'
        : '';

    try {
      final dio = await _dioInstance;
      final response = await dio.get(
        '/products$query',
        options: Options(
          extra: {'forceRefresh': true},
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Handle Laravel response format
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            return data['data'] as List<dynamic>;
          }
          if (data.containsKey('products')) {
            return data['products'] as List<dynamic>;
          }
        }
        if (data is List) {
          return data;
        }
        throw Exception('Invalid response format');
      }
      throw Exception('Failed to load products');
    } on DioException catch (e) {
      debugPrint('Force refresh error: $e');
      rethrow;
    }
  }

  /// CREATE PRODUCT (with optional image)
  static Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> data,
    List<dynamic>? images,
  ) async {
    final dio = await _dioInstance;
    FormData formData = FormData.fromMap(data);

    if (images != null && images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        String? path;
        if (image is File) {
          path = image.path;
        } else if (image.hasProperty('path')) {
          path = image.path;
        } else if (image is String) {
          path = image;
        }
        if (path != null) {
          formData.files.add(
            MapEntry(
              'images[]',
              await MultipartFile.fromFile(
                path,
                filename: 'image_$i.jpg',
              ),
            ),
          );
        }
      }
    }

    final response = await _handleRequest(
      () => dio.post('/products', data: formData),
    );
    return response as Map<String, dynamic>;
  }

  /// UPDATE PRODUCT (with optional image)
  static Future<Map<String, dynamic>> updateProduct(
    int productId,
    Map<String, dynamic> data,
    List<dynamic>? images,
  ) async {
    final dio = await _dioInstance;
    FormData formData = FormData.fromMap(data);

    if (images != null && images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        String? path;
        if (image is File) {
          path = image.path;
        } else if (image.hasProperty('path')) {
          path = image.path;
        } else if (image is String) {
          path = image;
        }
        if (path != null) {
          formData.files.add(
            MapEntry(
              'images[]',
              await MultipartFile.fromFile(
                path,
                filename: 'image_$i.jpg',
              ),
            ),
          );
        }
      }
    }

    final response = await _handleRequest(
      () => dio.put('/products/$productId', data: formData),
    );
    return response as Map<String, dynamic>;
  }

  /// FETCH SINGLE PRODUCT
  static Future<Map<String, dynamic>> fetchProduct(int productId) async {
    final dio = await _dioInstance;
    final response = await _handleRequest<dynamic>(
      () => dio.get('/products/$productId'),
    );
    if (response is Map<String, dynamic>) {
      return response;
    }
    throw Exception('Invalid product response format');
  }

  /// DELETE PRODUCT
  static Future<Map<String, dynamic>> deleteProduct(int productId) async {
    final dio = await _dioInstance;
    return _handleRequest(
      () => dio.delete('/products/$productId'),
    );
  }

  /// FETCH CATEGORIES (for dropdowns)
  static Future<List<dynamic>> fetchCategories() async {
    final dio = await _dioInstance;
    final response = await _handleRequest<dynamic>(() => dio.get('/categories'));
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      final data = response['data'];
      if (data is List) return data;
      if (data != null) return [data]; // Wrap single object in list
      return [];
    }
    if (response is List) {
      return response;
    }
    return [];
  }

  /// FETCH BRANDS (for dropdowns)
  static Future<List<dynamic>> fetchBrands() async {
    final dio = await _dioInstance;
    final response = await _handleRequest<dynamic>(() => dio.get('/brands'));
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      final data = response['data'];
      if (data is List) return data;
      if (data != null) return [data];
      return [];
    }
    if (response is List) {
      return response;
    }
    return [];
  }

  /// FETCH WAREHOUSES (for stock assignment)
  static Future<List<dynamic>> fetchWarehouses() async {
    final dio = await _dioInstance;
    final response = await _handleRequest<dynamic>(() => dio.get('/warehouses'));
    if (response is Map<String, dynamic> && response.containsKey('data')) {
      final data = response['data'];
      if (data is List) return data;
      if (data != null) return [data];
      return [];
    }
    if (response is List) {
      return response;
    }
    return [];
  }

  /// FETCH SUPPLIERS (for purchase orders)
  static Future<List<dynamic>> fetchSuppliers({String? search}) async {
    final dio = await _dioInstance;
    final params = <String, dynamic>{};
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }

    final response = await _handleRequest<dynamic>(
      () => dio.get('/suppliers', queryParameters: params),
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      final data = response['data'];
      if (data is List) return data;
      if (data != null) return [data];
      return [];
    }
    if (response is List) {
      return response;
    }
    return [];
  }

}

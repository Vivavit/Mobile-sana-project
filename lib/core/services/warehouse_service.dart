import 'package:mobile_camsme_sana_project/core/services/api_service.dart';

class WarehouseService {
  static final WarehouseService _instance = WarehouseService._internal();
  factory WarehouseService() => _instance;
  WarehouseService._internal();

  // Fetch warehouses from API
  Future<List<Map<String, dynamic>>> fetchWarehouses() async {
    await ApiService.initialize();

    final dio = await ApiService.dioInstance;

    final response = await ApiService.handleRequest<dynamic>(
      () => dio.get('/warehouses'),
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return List<Map<String, dynamic>>.from(response['data']);
    }

    return [];
  }

  // Search warehouses
  Future<List<Map<String, dynamic>>> searchWarehouses(String query) async {
    await ApiService.initialize();

    final dio = await ApiService.dioInstance;
    final response = await ApiService.handleRequest<dynamic>(
      () => dio.get('/warehouses', queryParameters: {'search': query}),
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return List<Map<String, dynamic>>.from(response['data']);
    }

    return [];
  }
}
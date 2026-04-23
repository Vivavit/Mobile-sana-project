import 'package:mobile_camsme_sana_project/core/models/purchase.dart';
import 'package:mobile_camsme_sana_project/core/services/api_service.dart';

class SupplierService {
  static final SupplierService _instance = SupplierService._internal();
  factory SupplierService() => _instance;
  SupplierService._internal();

  // Fetch all suppliers
  Future<List<Supplier>> fetchSuppliers() async {
    await ApiService.initialize();

    final dio = await ApiService.dioInstance;
    final response = await ApiService.handleRequest<dynamic>(
      () => dio.get('/suppliers'),
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return (response['data'] as List)
          .map((json) => Supplier.fromJson(json))
          .toList();
    }

    throw Exception('Failed to fetch suppliers');
  }

  // Filter suppliers by search query
  Future<List<Supplier>> searchSuppliers(String query) async {
    await ApiService.initialize();

    final dio = await ApiService.dioInstance;
    final response = await ApiService.handleRequest<dynamic>(
      () => dio.get('/suppliers', queryParameters: {'search': query}),
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return (response['data'] as List)
          .map((json) => Supplier.fromJson(json))
          .toList();
    }

    throw Exception('Failed to search suppliers');
  }
}
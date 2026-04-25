import 'package:mobile_camsme_sana_project/core/models/order_model.dart';
import 'package:mobile_camsme_sana_project/core/services/api_service.dart';

class OrderService {
  /// Get user's orders (for mobile app)
  static Future<OrderListResponse> getMyOrders({
    int page = 1,
    int perPage = 15,
    String? status,
  }) async {
    final dio = await ApiService.dioInstance;
    
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await ApiService.handleRequest<Map<String, dynamic>>(
      () => dio.get('/my-orders', queryParameters: queryParams),
    );

    return OrderListResponse.fromJson(response);
  }

  /// Get order details by ID
  static Future<Order> getOrderDetail(int orderId) async {
    final dio = await ApiService.dioInstance;

    final response = await ApiService.handleRequest<Map<String, dynamic>>(
      () => dio.get('/orders/$orderId'),
    );

    return Order.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Create a new order (checkout)
  static Future<Order> createOrder(CreateOrderRequest request) async {
    final dio = await ApiService.dioInstance;

    final response = await ApiService.handleRequest<Map<String, dynamic>>(
      () => dio.post('/orders', data: request.toJson()),
    );

    return Order.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Cancel an order (customer can cancel pending orders)
  static Future<Order> cancelOrder(int orderId) async {
    final dio = await ApiService.dioInstance;

    final response = await ApiService.handleRequest<Map<String, dynamic>>(
      () => dio.post('/orders/$orderId/cancel'),
    );

    return Order.fromJson(response['data'] as Map<String, dynamic>);
  }

  /// Get order statistics (admin/staff only)
  static Future<Map<String, dynamic>> getOrderStats({
    String? dateFrom,
    String? dateTo,
  }) async {
    final dio = await ApiService.dioInstance;
    
    final queryParams = <String, dynamic>{};
    
    if (dateFrom != null && dateFrom.isNotEmpty) {
      queryParams['date_from'] = dateFrom;
    }
    
    if (dateTo != null && dateTo.isNotEmpty) {
      queryParams['date_to'] = dateTo;
    }

    return await ApiService.handleRequest<Map<String, dynamic>>(
      () => dio.get('/orders/stats', queryParameters: queryParams),
    );
  }

  /// Get all orders (admin/staff only)
  static Future<OrderListResponse> getAllOrders({
    int page = 1,
    int perPage = 15,
    String? status,
    int? warehouseId,
    String? search,
    String? dateFrom,
    String? dateTo,
  }) async {
    final dio = await ApiService.dioInstance;
    
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    
    if (warehouseId != null) {
      queryParams['warehouse_id'] = warehouseId;
    }
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    
    if (dateFrom != null && dateFrom.isNotEmpty) {
      queryParams['date_from'] = dateFrom;
    }
    
    if (dateTo != null && dateTo.isNotEmpty) {
      queryParams['date_to'] = dateTo;
    }

    final response = await ApiService.handleRequest<Map<String, dynamic>>(
      () => dio.get('/orders', queryParameters: queryParams),
    );

    return OrderListResponse.fromJson(response);
  }

  /// Update order status (admin/staff only)
  static Future<Order> updateOrderStatus(int orderId, String status) async {
    final dio = await ApiService.dioInstance;

    final response = await ApiService.handleRequest<Map<String, dynamic>>(
      () => dio.patch('/orders/$orderId/status', data: {'status': status}),
    );

    return Order.fromJson(response['data'] as Map<String, dynamic>);
  }
}

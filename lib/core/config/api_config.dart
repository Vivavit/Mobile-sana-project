import 'package:mobile_camsme_sana_project/core/services/session.dart';

class ApiConfig {
  // Base URL for the Laravel API
  static const String baseUrl = 'https://your-laravel-api-url.com/api';

  // API endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/me';

  // Product endpoints
  static const String products = '/products';
  static const String productDetails = '/products';

  // Purchase order endpoints
  static const String purchaseOrders = '/purchase-orders';
  static const String purchaseOrderDetails = '/purchase-orders';
  static const String purchaseOrdersReceive = '/purchase-orders';
  static const String purchaseOrdersStatus = '/purchase-orders';

  // Supplier endpoints
  static const String suppliers = '/suppliers';

  // Warehouse endpoints
  static const String warehouses = '/warehouses';

  // Analytics endpoints
  static const String dashboard = '/dashboard';
  static const String analyticsSummary = '/analytics/summary';
  static const String analyticsSalesChart = '/analytics/sales-chart';
  static const String analyticsTrending = '/analytics/trending';

  // Checkout endpoints
  static const String checkout = '/checkout';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Default pagination
  static const int defaultPerPage = 15;

  // Cache settings
  static const Duration cacheDuration = Duration(minutes: 5);

  // Purchase order statuses
  static const List<String> purchaseOrderStatuses = [
    'draft',
    'pending',
    'ordered',
    'received',
  ];

  // API headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Authorization header
  static Map<String, String> get authHeaders => {
    ...defaultHeaders,
    'Authorization': 'Bearer ${Session.token}',
  };
}
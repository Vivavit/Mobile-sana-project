import 'package:mobile_camsme_sana_project/core/models/purchase.dart';
import 'package:mobile_camsme_sana_project/core/models/product.dart';
import 'package:mobile_camsme_sana_project/core/models/purchase_order_model.dart';
import 'package:mobile_camsme_sana_project/core/services/api_service.dart';
import 'package:mobile_camsme_sana_project/core/services/session.dart';

class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();


  // API service integration
  Future<void> _ensureInitialized() async {
    await ApiService.initialize();
  }


  // Fetch suppliers from API
  Future<List<Supplier>> fetchSuppliers() async {
    await _ensureInitialized();

    final dio = await ApiService.dioInstance;
    final response = await ApiService.handleRequest<dynamic>(
      () => dio.get('/suppliers')
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return (response['data'] as List)
          .map((json) => Supplier.fromJson(json))
          .toList();
    }

    // Fallback to mock data if API fails
    return _suppliers;
  }

  // Mock data
  final List<Supplier> _suppliers = [
    Supplier(
      id: 1,
      name: 'ABC Supplies',
      contactPerson: 'John Smith',
      phone: '+1-555-0101',
      email: 'john@abc-supplies.com',
      address: '123 Industrial Ave, New York, NY',
      taxId: 'TAX-2023-001',
    ),
    Supplier(
      id: 2,
      name: 'Global Traders Co.',
      contactPerson: 'Sarah Johnson',
      phone: '+1-555-0102',
      email: 'sarah@globaltraders.com',
      address: '456 Commerce Blvd, Los Angeles, CA',
      taxId: 'TAX-2023-002',
    ),
    Supplier(
      id: 3,
      name: 'Tech Distributors Inc.',
      contactPerson: 'Mike Chen',
      phone: '+1-555-0103',
      email: 'mike@techdist.com',
      address: '789 Tech Park, San Francisco, CA',
      taxId: 'TAX-2023-003',
    ),
    Supplier(
      id: 4,
      name: 'Market Supplies Ltd.',
      contactPerson: 'Lisa Wong',
      phone: '+1-555-0104',
      email: 'lisa@marketsupplies.com',
      address: '321 Market St, Chicago, IL',
      taxId: 'TAX-2023-004',
    ),
    Supplier(
      id: 5,
      name: 'Wholesale Goods Corp.',
      contactPerson: 'David Miller',
      phone: '+1-555-0105',
      email: 'david@wholesalegoods.com',
      address: '654 Warehouse Dr, Houston, TX',
      taxId: 'TAX-2023-005',
    ),
  ];

  final List<Product> _allProducts = [
    Product(
      id: 1,
      name: 'Wireless Keyboard',
      description: 'Ergonomic wireless keyboard with long battery life',
      sku: 'KB-001',
      price: 45.99,
      stock: 150,
      image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=Keyboard',
    ),
    Product(
      id: 2,
      name: 'USB-C Cable',
      description: 'High-speed USB-C charging cable, 2m',
      sku: 'CB-002',
      price: 12.99,
      stock: 500,
      image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=USBCable',
    ),
    Product(
      id: 3,
      name: 'Laptop Stand',
      description: 'Adjustable aluminum laptop stand',
      sku: 'LS-003',
      price: 35.50,
      stock: 80,
      image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=LaptopStand',
    ),
    Product(
      id: 4,
      name: 'Bluetooth Mouse',
      description: 'Wireless optical mouse with precision tracking',
      sku: 'BM-004',
      price: 28.99,
      stock: 200,
      image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=Mouse',
    ),
    Product(
      id: 5,
      name: 'Monitor Light Bar',
      description: 'LED monitor light bar with adjustable brightness',
      sku: 'ML-005',
      price: 42.00,
      stock: 60,
      image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=LightBar',
    ),
    Product(
      id: 6,
      name: 'Webcam HD',
      description: '1080p webcam with built-in microphone',
      sku: 'WC-006',
      price: 65.99,
      stock: 45,
      image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=WebcamHD',
    ),
    Product(
      id: 7,
      name: 'Desk Organizer',
      description: 'Wooden desk organizer with multiple compartments',
      sku: 'DO-007',
      price: 29.99,
      stock: 120,
      image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=Organizer',
    ),
    Product(
      id: 8,
      name: 'Power Bank 20000mAh',
      description: 'Fast charging power bank with multiple ports',
      sku: 'PB-008',
      price: 39.99,
      stock: 180,
      image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=PowerBank',
    ),
  ];

  final List<Purchase> _purchases = [
    Purchase(
      id: 1,
      supplier: Supplier(
        id: 1,
        name: 'ABC Supplies',
        contactPerson: 'John Smith',
        phone: '+1-555-0101',
      ),
      date: DateTime.now().subtract(const Duration(days: 2)),
      purchaseId: 'PO-2024-001',
      notes: 'Regular monthly order',
      items: [
        PurchaseItem(
          product: Product(
            id: 1,
            name: 'Wireless Keyboard',
            description: '',
            price: 45.99,
            stock: 0,
            image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=Keyboard',
          ),
          price: 38.50,
          quantity: 20,
        ),
        PurchaseItem(
          product: Product(
            id: 2,
            name: 'USB-C Cable',
            description: '',
            price: 12.99,
            stock: 0,
            image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=USBCable',
          ),
          price: 9.99,
          quantity: 50,
        ),
      ],
      total: 1199.50,
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Purchase(
      id: 2,
      supplier: Supplier(
        id: 2,
        name: 'Global Traders Co.',
        contactPerson: 'Sarah Johnson',
        phone: '+1-555-0102',
      ),
      date: DateTime.now().subtract(const Duration(days: 5)),
      purchaseId: 'PO-2024-002',
      notes: 'Bulk order - 10% discount applied',
      items: [
        PurchaseItem(
          product: Product(
            id: 3,
            name: 'Laptop Stand',
            description: '',
            price: 35.50,
            stock: 0,
            image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=LaptopStand',
          ),
          price: 28.40,
          quantity: 30,
        ),
        PurchaseItem(
          product: Product(
            id: 4,
            name: 'Bluetooth Mouse',
            description: '',
            price: 28.99,
            stock: 0,
            image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=Mouse',
          ),
          price: 23.99,
          quantity: 40,
        ),
        PurchaseItem(
          product: Product(
            id: 5,
            name: 'Monitor Light Bar',
            description: '',
            price: 42.00,
            stock: 0,
            image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=LightBar',
          ),
          price: 35.00,
          quantity: 25,
        ),
      ],
      total: 2710.00,
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Purchase(
      id: 3,
      supplier: Supplier(
        id: 3,
        name: 'Tech Distributors Inc.',
        contactPerson: 'Mike Chen',
        phone: '+1-555-0103',
      ),
      date: DateTime.now().subtract(const Duration(days: 7)),
      purchaseId: 'PO-2024-003',
      notes: 'Urgent order for webcams',
      items: [
        PurchaseItem(
          product: Product(
            id: 6,
            name: 'Webcam HD',
            description: '',
            price: 65.99,
            stock: 0,
            image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=Webcam',
          ),
          price: 55.00,
          quantity: 15,
        ),
      ],
      total: 825.00,
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Purchase(
      id: 4,
      supplier: Supplier(
        id: 4,
        name: 'Market Supplies Ltd.',
        contactPerson: 'Lisa Wong',
        phone: '+1-555-0104',
      ),
      date: DateTime.now().subtract(const Duration(days: 10)),
      purchaseId: 'PO-2024-004',
      notes: '',
      items: [
        PurchaseItem(
          product: Product(
            id: 7,
            name: 'Desk Organizer',
            description: '',
            price: 29.99,
            stock: 0,
            image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=Organizer',
          ),
          price: 22.50,
          quantity: 50,
        ),
        PurchaseItem(
          product: Product(
            id: 8,
            name: 'Power Bank 20000mAh',
            description: '',
            price: 39.99,
            stock: 0,
            image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=PowerBank',
          ),
          price: 32.00,
          quantity: 35,
        ),
      ],
      total: 2372.50,
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Purchase(
      id: 5,
      supplier: Supplier(
        id: 5,
        name: 'Wholesale Goods Corp.',
        contactPerson: 'David Miller',
        phone: '+1-555-0105',
      ),
      date: DateTime.now().subtract(const Duration(days: 1)),
      purchaseId: 'PO-2024-005',
      notes: 'Restocking order',
      items: [
        PurchaseItem(
          product: Product(
            id: 1,
            name: 'Wireless Keyboard',
            description: '',
            price: 45.99,
            stock: 0,
            image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=Keyboard',
          ),
          price: 36.99,
          quantity: 25,
        ),
        PurchaseItem(
          product: Product(
            id: 4,
            name: 'Bluetooth Mouse',
            description: '',
            price: 28.99,
            stock: 0,
            image: 'https://via.placeholder.com/300x200/03624C/FFFFFF?text=Mouse',
          ),
          price: 22.99,
          quantity: 60,
        ),
      ],
      total: 1569.00,
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // Getters
  List<Supplier> get suppliers => List.unmodifiable(_suppliers);

  // Fetch purchase orders from API
  Future<List<PurchaseOrder>> fetchPurchaseOrders({
    String? status,
    int? supplierId,
    String? searchQuery,
    int? page = 1,
    int? perPage = 15,
  }) async {
    await _ensureInitialized();

    final dio = await ApiService.dioInstance;

    // Build query parameters
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (status != null) params['status'] = status;
    if (supplierId != null) params['supplier_id'] = supplierId;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      params['search'] = searchQuery;
    }

    final response = await ApiService.handleRequest<dynamic>(
      () => dio.get('/purchase-orders', queryParameters: params),
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return (response['data'] as List)
          .map((json) => PurchaseOrder.fromJson(json))
          .toList();
    }

    throw Exception('Failed to fetch purchase orders');
  }

  // Fetch user's purchase orders
  Future<List<PurchaseOrder>> fetchMyPurchaseOrders({
    int? page = 1,
    int? perPage = 15,
  }) async {
    await _ensureInitialized();

    final dio = await ApiService.dioInstance;

    final params = {
      'page': page,
      'per_page': perPage,
    };

    final response = await ApiService.handleRequest<dynamic>(
      () => dio.get('/my-purchase-orders', queryParameters: params),
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return (response['data'] as List)
          .map((json) => PurchaseOrder.fromJson(json))
          .toList();
    }

    throw Exception('Failed to fetch purchase orders');
  }

  // Fetch single purchase order
  Future<PurchaseOrder> fetchPurchaseOrder(int id) async {
    await _ensureInitialized();

    final dio = await ApiService.dioInstance;
    final response = await ApiService.handleRequest<dynamic>(
      () => dio.get('/purchase-orders/$id'),
    );

    if (response is Map<String, dynamic>) {
      return PurchaseOrder.fromJson(response);
    }
    throw Exception('Failed to fetch purchase order');
  }

  // Fetch purchase orders in legacy format for backward compatibility
  Future<List<Purchase>> fetchPurchaseOrdersLegacy({
    String? status,
    int? supplierId,
    String? searchQuery,
    int? page = 1,
    int? perPage = 15,
  }) async {
    final orders = await fetchPurchaseOrders(
      status: status,
      supplierId: supplierId,
      searchQuery: searchQuery,
      page: page,
      perPage: perPage,
    );

    return orders.map((order) => order.toPurchase()).toList();
  }
  List<Product> getProductsForSupplier(int supplierId) {
    // For demo: return all products for any supplier
    return _allProducts;
  }

  List<Purchase> getPurchases({String? searchQuery, DateTime? startDate, DateTime? endDate}) {
    var result = List<Purchase>.from(_purchases);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      result = result.where((purchase) {
        final query = searchQuery.toLowerCase();
        return purchase.purchaseId?.toLowerCase().contains(query) ??
               false ||
               purchase.supplier.name.toLowerCase().contains(query) ||
               purchase.items.any((item) => item.product.name.toLowerCase().contains(query));
      }).toList();
    }

    if (startDate != null) {
      result = result.where((purchase) => purchase.date.isAfter(startDate) || purchase.date.isAtSameMomentAs(startDate)).toList();
    }

    if (endDate != null) {
      result = result.where((purchase) => purchase.date.isBefore(endDate) || purchase.date.isAtSameMomentAs(endDate)).toList();
    }

    // Sort by date descending (newest first)
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  Purchase? getPurchaseById(int id) {
    try {
      return _purchases.firstWhere((purchase) => purchase.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create purchase order
  Future<PurchaseOrder> createPurchaseOrder({
    required int supplierId,
    required int warehouseId,
    required List<Map<String, dynamic>> items,
    double taxRate = 0,
    double shippingCost = 0,
    String? notes,
  }) async {
    await _ensureInitialized();

    final dio = await ApiService.dioInstance;

    // Build request body
    final Map<String, dynamic> requestBody = {
      'supplier_id': supplierId,
      'warehouse_id': warehouseId,
      'items': items,
      'tax_rate': taxRate,
      'shipping_cost': shippingCost,
      'notes': notes,
    };

    final response = await ApiService.handleRequest(
      () => dio.post('/purchase-orders', data: requestBody),
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return PurchaseOrder.fromJson(response['data']);
    }

    throw Exception('Failed to create purchase order');
  }

  // Create purchase order (legacy method)
  Future<Purchase> createPurchase(Purchase purchase) async {
    final items = purchase.items.map((item) {
      return {
        'product_id': item.product.id,
        'quantity': item.quantity,
        'unit_price': item.price,
        'discount': item.product.price != item.price ? (item.product.price - item.price) / item.product.price : 0,
      };
    }).toList();

    final newOrder = await createPurchaseOrder(
      supplierId: purchase.supplier.id,
      warehouseId: (Session.warehouseId as int?) ?? 1,
      items: items,
      notes: purchase.notes,
    );

    return newOrder.toPurchase();
  }

  // Update purchase order
  Future<PurchaseOrder> updatePurchaseOrder(int id, {
    int? supplierId,
    int? warehouseId,
    double? taxRate,
    double? shippingCost,
    String? notes,
    String? status,
  }) async {
    await _ensureInitialized();

    final dio = await ApiService.dioInstance;

    final Map<String, dynamic> requestBody = {};
    if (supplierId != null) requestBody['supplier_id'] = supplierId;
    if (warehouseId != null) requestBody['warehouse_id'] = warehouseId;
    if (taxRate != null) requestBody['tax_rate'] = taxRate;
    if (shippingCost != null) requestBody['shipping_cost'] = shippingCost;
    if (notes != null) requestBody['notes'] = notes;
    if (status != null) requestBody['status'] = status;

    final response = await ApiService.handleRequest(
      () => dio.put('/purchase-orders/$id', data: requestBody),
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return PurchaseOrder.fromJson(response['data']);
    }

    throw Exception('Failed to update purchase order');
  }

  // Update purchase order (legacy method)
  Future<Purchase> updatePurchase(Purchase purchase) async {
    final updatedOrder = await updatePurchaseOrder(
      purchase.id!,
      supplierId: purchase.supplier.id,
      warehouseId: Session.warehouseId != null ? int.tryParse(Session.warehouseId.toString()) : null,
      notes: purchase.notes,
      status: purchase.status,
    );

    return updatedOrder.toPurchase();
  }

  // Delete purchase order
  Future<void> deletePurchase(int id) async {
    await _ensureInitialized();

    final dio = await ApiService.dioInstance;
    await ApiService.handleRequest(
      () => dio.delete('/purchase-orders/$id'),
    );
  }

  // Receive stock for purchase order
  Future<PurchaseOrder> receiveStock(int purchaseOrderId, List<Map<String, dynamic>> receivedItems) async {
    await _ensureInitialized();

    final dio = await ApiService.dioInstance;

    final response = await ApiService.handleRequest(
      () => dio.post('/purchase-orders/$purchaseOrderId/receive', data: {
        'received_items': receivedItems,
      }),
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return PurchaseOrder.fromJson(response['data']);
    }

    throw Exception('Failed to receive stock');
  }

  // Receive stock (legacy method)
  Future<Purchase> receiveStockLegacy(int purchaseOrderId, List<Map<String, dynamic>> receivedItems) async {
    final updatedOrder = await receiveStock(purchaseOrderId, receivedItems);
    return updatedOrder.toPurchase();
  }

  // Update purchase order status
  Future<PurchaseOrder> updatePurchaseStatus(int id, String status) async {
    await _ensureInitialized();

    final dio = await ApiService.dioInstance;

    final response = await ApiService.handleRequest(
      () => dio.patch('/purchase-orders/$id/status', data: {
        'status': status,
      }),
    );

    if (response is Map<String, dynamic> && response.containsKey('data')) {
      return PurchaseOrder.fromJson(response['data']);
    }

    throw Exception('Failed to update status');
  }

  // Update purchase order status (legacy method)
  Future<Purchase> updatePurchaseStatusLegacy(int id, String status) async {
    final updatedOrder = await updatePurchaseStatus(id, status);
    return updatedOrder.toPurchase();
  }

  // Statistics
  Map<String, dynamic> getPurchaseStats() {
    final totalPurchases = _purchases.length;
    final totalAmount = _purchases.fold<double>(0, (sum, p) => sum + p.total);
    final averagePurchase = totalPurchases > 0 ? totalAmount / totalPurchases : 0.0;
    final thisMonth = DateTime.now().month;
    final thisYear = DateTime.now().year;
    final monthlyPurchases = _purchases.where((p) =>
      p.date.month == thisMonth && p.date.year == thisYear
    ).length;

    return {
      'total_purchases': totalPurchases,
      'total_amount': totalAmount,
      'average_purchase': averagePurchase,
      'monthly_purchases': monthlyPurchases,
    };
  }

  // Calculate purchase order totals
  Map<String, dynamic> calculatePurchaseTotals({
    required List<Map<String, dynamic>> items,
    double taxRate = 0,
    double shippingCost = 0,
  }) {
    double subtotal = 0;

    for (final item in items) {
      final quantity = item['quantity'] ?? 0;
      final unitPrice = item['unit_price']?.toDouble() ?? 0;
      final discount = item['discount']?.toDouble() ?? 0;

      double itemTotal = quantity * unitPrice;
      itemTotal -= discount;
      subtotal += itemTotal;
    }

    double taxAmount = subtotal * (taxRate / 100);
    double total = subtotal + taxAmount + shippingCost;

    return {
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'total': total,
    };
  }
}

import 'package:mobile_camsme_sana_project/core/models/warehouse.dart';
import 'package:flutter/foundation.dart';

enum OrderStatus {
  pending('pending', 'Pending', 0xFFFF9800),
  processing('processing', 'Processing', 0xFF2196F3),
  completed('completed', 'Completed', 0xFF4CAF50),
  cancelled('cancelled', 'Cancelled', 0xFFF44336);

  const OrderStatus(this.value, this.label, this.color);
  final String value;
  final String label;
  final int color;

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }
}

class Order {
  final int id;
  final String orderNumber;
  final int userId;
  final int warehouseId;
  final Warehouse? warehouse;
  final double subtotal;
  final double total;
  final OrderStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;
  final User? user;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    required this.warehouseId,
    this.warehouse,
    required this.subtotal,
    required this.total,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
    this.user,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    debugPrint('Order JSON: $json');
    
    final itemsData = json['items'] as List<dynamic>? ?? [];
    final items = itemsData
        .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
        .toList();

    // Build warehouse from flat fields since API returns warehouse_name not warehouse object
    final warehouseId = _parseIntSafely(json['warehouse_id']);
    final warehouseName = json['warehouse_name'] as String?;
    final warehouse = warehouseName != null
        ? Warehouse(id: warehouseId, name: warehouseName)
        : null;

    // Build user from flat fields
    final userId = _parseIntSafely(json['user_id']);
    final userName = json['user_name'] as String?;
    final user = userName != null
        ? User(id: userId, name: userName, email: '')
        : null;

    // Use first product name as order identifier if no order_number
    String orderIdentifier = 'Unknown';
    if (json['order_number'] != null && json['order_number'].toString().isNotEmpty) {
      orderIdentifier = json['order_number'] as String;
    } else if (items.isNotEmpty) {
      orderIdentifier = items.first.productName;
      if (items.length > 1) {
        orderIdentifier += ' +${items.length - 1} more';
      }
    }

    return Order(
      id: _parseIntSafely(json['id']),
      orderNumber: orderIdentifier,
      userId: userId,
      warehouseId: warehouseId,
      warehouse: warehouse,
      subtotal: _parseDoubleSafely(json['subtotal']),
      total: _parseDoubleSafely(json['total']),
      status: OrderStatus.fromString(json['status'] as String? ?? 'pending'),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      items: items,
      user: user,
    );
  }

  // Helper methods for safe parsing
  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDoubleSafely(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'user_id': userId,
      'warehouse_id': warehouseId,
      'warehouse': warehouse?.toJson(),
      'subtotal': subtotal,
      'total': total,
      'status': status.value,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'items': items.map((item) => item.toJson()).toList(),
      'user': user?.toJson(),
    };
  }

  Order copyWith({
    int? id,
    String? orderNumber,
    int? userId,
    int? warehouseId,
    Warehouse? warehouse,
    double? subtotal,
    double? total,
    OrderStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderItem>? items,
    User? user,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouse: warehouse ?? this.warehouse,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      items: items ?? this.items,
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order &&
        other.id == id &&
        other.orderNumber == orderNumber &&
        other.userId == userId &&
        other.warehouseId == warehouseId &&
        other.subtotal == subtotal &&
        other.total == total &&
        other.status == status &&
        other.notes == notes &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.user == user;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      orderNumber,
      userId,
      warehouseId,
      subtotal,
      total,
      status,
      notes,
      createdAt,
      updatedAt,
      user,
    );
  }
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final String productName;
  final int quantity;
  final double price;
  final double total;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
    this.product,
  });

  // Computed property for subtotal (same as total for individual items)
  double get subtotal => total;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    try {
      return OrderItem(
        id: _parseIntSafely(json['id']),
        orderId: _parseIntSafely(json['order_id']),
        productId: _parseIntSafely(json['product_id']),
        productName: json['product_name'] as String? ?? 'Unknown Product',
        quantity: _parseIntSafely(json['quantity']),
        price: _parseDoubleSafely(json['price']),
        total: _parseDoubleSafely(json['total']),
      );
    } catch (e) {
      return OrderItem(
        id: 0,
        orderId: 0,
        productId: 0,
        productName: 'Error Item',
        quantity: 0,
        price: 0.0,
        total: 0.0,
      );
    }
  }

  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDoubleSafely(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}

class Product {
  final int id;
  final String name;
  final double price;
  final String? description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseIntSafely(json['id']),
      name: json['name'] as String? ?? 'Unknown Product',
      price: _parseDoubleSafely(json['price']),
      description: json['description'] as String?,
    );
  }

  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  static double _parseDoubleSafely(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
    };
  }
}

class User {
  final int id;
  final String name;
  final String email;

  User({
    required this.id,
    required this.name,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      return User(
        id: _parseIntSafely(json['id']),
        name: json['name'] as String? ?? 'Unknown',
        email: json['email'] as String? ?? 'unknown@example.com',
      );
    } catch (e) {
      return User(
        id: 0,
        name: 'Error User',
        email: 'error@example.com',
      );
    }
  }

  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class OrderListResponse {
  final List<Order> orders;
  final int currentPage;
  final int lastPage;
  final int total;

  OrderListResponse({
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Step into the outer 'data' object first
      final outer = json['data'] as Map<String, dynamic>? ?? {};
      
      // Orders are in outer['data']
      final ordersData = outer['data'] as List<dynamic>? ?? [];
      final orders = ordersData
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();

      // Pagination is in outer['meta']
      final meta = outer['meta'] as Map<String, dynamic>? ?? {};

      return OrderListResponse(
        orders: orders,
        currentPage: _parseIntSafely(meta['current_page']),
        lastPage: _parseIntSafely(meta['last_page']),
        total: _parseIntSafely(meta['total']),
      );
    } catch (e) {
      debugPrint('OrderListResponse.fromJson error: $e');
      return OrderListResponse(
        orders: [],
        currentPage: 1,
        lastPage: 1,
        total: 0,
      );
    }
  }

  static int _parseIntSafely(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 1;
    if (value is double) return value.toInt();
    return 1;
  }
}

class CreateOrderRequest {
  final List<CreateOrderItemRequest> items;
  final int warehouseId;
  final String? notes;

  CreateOrderRequest({
    required this.items,
    required this.warehouseId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'warehouse_id': warehouseId,
      'notes': notes,
    };
  }
}

class CreateOrderItemRequest {
  final int productId;
  final int quantity;
  final double price;

  CreateOrderItemRequest({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price': price,
    };
  }
}

import 'package:mobile_camsme_sana_project/core/models/warehouse.dart';

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
    final itemsData = json['items'] as List<dynamic>? ?? [];
    final items = itemsData.map((item) => OrderItem.fromJson(item as Map<String, dynamic>)).toList();

    return Order(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      userId: json['user_id'] as int,
      warehouseId: json['warehouse_id'] as int,
      warehouse: json['warehouse'] != null ? Warehouse.fromJson(json['warehouse'] as Map<String, dynamic>) : null,
      subtotal: (json['subtotal'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.fromString(json['status'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      items: items,
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
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
  final String? productName;
  final String? productSku;
  final int quantity;
  final double price;
  final double subtotal;
  final Product? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    this.productName,
    this.productSku,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      productName: json['product_name'] as String?,
      productSku: json['product_sku'] as String?,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      product: json['product'] != null ? Product.fromJson(json['product'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'quantity': quantity,
      'price': price,
      'subtotal': subtotal,
      'product': product?.toJson(),
    };
  }

  OrderItem copyWith({
    int? id,
    int? orderId,
    int? productId,
    String? productName,
    String? productSku,
    int? quantity,
    double? price,
    double? subtotal,
    Product? product,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
      product: product ?? this.product,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem &&
        other.id == id &&
        other.orderId == orderId &&
        other.productId == productId &&
        other.productName == productName &&
        other.productSku == productSku &&
        other.quantity == quantity &&
        other.price == price &&
        other.subtotal == subtotal &&
        other.product == product;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      orderId,
      productId,
      productName,
      productSku,
      quantity,
      price,
      subtotal,
      product,
    );
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
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class Product {
  final int id;
  final String name;
  final String? sku;

  Product({
    required this.id,
    required this.name,
    this.sku,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      sku: json['sku'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
    };
  }
}

class CreateOrderRequest {
  final int warehouseId;
  final List<CreateOrderItemRequest> items;
  final String? notes;

  CreateOrderRequest({
    required this.warehouseId,
    required this.items,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'warehouse_id': warehouseId,
      'items': items.map((item) => item.toJson()).toList(),
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

class OrderListResponse {
  final List<Order> orders;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  OrderListResponse({
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final ordersData = data['data'] as List<dynamic>? ?? [];
    final orders = ordersData.map((order) => Order.fromJson(order as Map<String, dynamic>)).toList();

    return OrderListResponse(
      orders: orders,
      currentPage: data['current_page'] as int,
      lastPage: data['last_page'] as int,
      perPage: data['per_page'] as int,
      total: data['total'] as int,
    );
  }
}

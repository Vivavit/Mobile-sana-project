import 'package:mobile_camsme_sana_project/core/models/product.dart';

class Supplier {
  final int id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;

  Supplier({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.taxId,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      name: json['name']?.toString() ?? '',
      contactPerson: json['contact_person']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      taxId: json['tax_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'tax_id': taxId,
    };
  }

  @override
  String toString() => name;
}

class PurchaseItem {
  final int? id;
  final Product product;
  final double price;
  final int quantity;
  final double subtotal;

  PurchaseItem({
    this.id,
    required this.product,
    required this.price,
    required this.quantity,
  }) : subtotal = price * quantity;

  PurchaseItem copyWith({
    int? id,
    Product? product,
    double? price,
    int? quantity,
  }) {
    return PurchaseItem(
      id: id ?? this.id,
      product: product ?? this.product,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': product.id,
      'product_name': product.name,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  @override
  String toString() => '${product.name} x $quantity';
}

class Purchase {
  final int? id;
  final Supplier supplier;
  final DateTime date;
  final String? purchaseId;
  final String? notes;
  final List<PurchaseItem> items;
  final double total;
  final String? status;
  final DateTime? createdAt;

  Purchase({
    this.id,
    required this.supplier,
    required this.date,
    this.purchaseId,
    this.notes,
    required this.items,
    required this.total,
    this.status = 'completed',
    this.createdAt,
  });

  Purchase copyWith({
    int? id,
    Supplier? supplier,
    DateTime? date,
    String? purchaseId,
    String? notes,
    List<PurchaseItem>? items,
    double? total,
    String? status,
    DateTime? createdAt,
  }) {
    return Purchase(
      id: id ?? this.id,
      supplier: supplier ?? this.supplier,
      date: date ?? this.date,
      purchaseId: purchaseId ?? this.purchaseId,
      notes: notes ?? this.notes,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Purchase.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];

    final items = itemsJson.map((item) {
      if (item is! Map<String, dynamic>) return null;

      final product = Product.fromJson(
        (item['product'] is Map<String, dynamic>)
            ? item['product'] as Map<String, dynamic>
            : item,
      );

      // ✅ Safe price: try unit_price first, then price, fallback to 0.0
      final rawPrice = item['unit_price'] ?? item['price'];
      final price = rawPrice != null
          ? double.tryParse(rawPrice.toString()) ?? 0.0
          : 0.0;

      // ✅ Safe quantity: fallback to 0
      final quantity = item['quantity'] != null
          ? int.tryParse(item['quantity'].toString()) ?? 0
          : 0;

      return PurchaseItem(
        id: item['id'] != null
            ? int.tryParse(item['id'].toString())
            : null,
        product: product,
        price: price,
        quantity: quantity,
      );
    }).whereType<PurchaseItem>().toList(); // filters out any nulls

    // ✅ Safe total: try total_amount first, then total, fallback to 0.0
    final rawTotal = json['total_amount'] ?? json['total'];
    final total = rawTotal != null
        ? double.tryParse(rawTotal.toString()) ?? 0.0
        : 0.0;

    return Purchase(
      id: json['id'] != null
          ? int.tryParse(json['id'].toString())
          : null,
      supplier: Supplier.fromJson(
        (json['supplier'] is Map<String, dynamic>)
            ? json['supplier'] as Map<String, dynamic>
            : <String, dynamic>{},
      ),
      date: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      purchaseId: json['po_number']?.toString() ?? json['purchase_id']?.toString(),
      notes: json['notes']?.toString(),
      items: items,
      total: total,
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_id': supplier.id,
      'supplier_name': supplier.name,
      'date': date.toIso8601String(),
      'purchase_id': purchaseId,
      'notes': notes,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() => 'Purchase #$purchaseId - ${supplier.name}';
}
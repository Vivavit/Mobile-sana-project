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
      id: json['id'] != null ? int.parse(json['id'].toString()) : 0,
      name: json['name'] ?? '',
      contactPerson: json['contact_person'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      taxId: json['tax_id'],
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
  final double price; // Purchase price at time of purchase
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
  final String? purchaseId; // External reference (e.g., PO-001)
  final String? notes;
  final List<PurchaseItem> items;
  final double total;
  final String? status; // pending, completed, cancelled
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
      final product = Product.fromJson(item['product'] ?? item);
      return PurchaseItem(
        id: item['id'],
        product: product,
        price: double.parse(item['unit_price']?.toString() ?? item['price'].toString()),
        quantity: int.parse(item['quantity'].toString()),
      );
    }).toList();

    return Purchase(
      id: json['id'],
      supplier: Supplier.fromJson(json['supplier']),
      date: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      purchaseId: json['po_number'] ?? json['purchase_id'],
      notes: json['notes'],
      items: items,
      total: json['total_amount'] != null
          ? double.parse(json['total_amount'].toString())
          : double.parse(json['total'].toString()),
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
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

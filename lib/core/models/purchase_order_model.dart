import 'package:mobile_camsme_sana_project/core/models/purchase_item_model.dart';
import 'package:mobile_camsme_sana_project/core/models/purchase.dart';
import 'package:mobile_camsme_sana_project/core/models/product.dart';

class PurchaseOrderRef {
  final int id;
  final String? name;

  const PurchaseOrderRef({
    required this.id,
    this.name,
  });

  factory PurchaseOrderRef.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderRef(
      id: _toInt(json['id']) ?? 0,
      name: json['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class PurchaseOrder {
  final int? id;
  final String? poNumber;
  final String? referenceNumber;
  final String? status;
  final int supplierId;
  final String? supplierName;
  final int warehouseId;
  final String? warehouseName;
  final String? notes;
  final double taxRate;
  final double shippingCost;
  final double subtotal;
  final double taxAmount;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? receivedAt;
  final int? createdById;
  final String? createdByName;
  final PurchaseOrderRef? supplier;
  final PurchaseOrderRef? warehouse;
  final PurchaseOrderRef? createdBy;

  final List<PurchaseOrderItem> items;

  PurchaseOrder({
    this.id,
    this.poNumber,
    this.referenceNumber,
    this.status = 'draft',
    required this.supplierId,
    this.supplierName,
    required this.warehouseId,
    this.warehouseName,
    this.notes,
    this.taxRate = 0,
    this.shippingCost = 0,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    this.receivedAt,
    this.createdById,
    this.createdByName,
    this.supplier,
    this.warehouse,
    this.createdBy,
    required this.items,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] is List ? (json['items'] as List) : const <dynamic>[];
    final items = itemsJson
        .whereType<Map<String, dynamic>>()
        .map(PurchaseOrderItem.fromJson)
        .toList();

    final supplierJson = _asMap(json['supplier']);
    final warehouseJson = _asMap(json['warehouse']);

    // Some backends return "creator", others return "created_by" as object.
    final createdByJson = _asMap(json['created_by']) ?? _asMap(json['creator']);

    final supplierRef = supplierJson != null ? PurchaseOrderRef.fromJson(supplierJson) : null;
    final warehouseRef = warehouseJson != null ? PurchaseOrderRef.fromJson(warehouseJson) : null;
    final createdByRef = createdByJson != null ? PurchaseOrderRef.fromJson(createdByJson) : null;

    return PurchaseOrder(
      id: _toInt(json['id']),
      poNumber: json['po_number']?.toString(),
      referenceNumber: json['reference_number']?.toString(),
      status: json['status']?.toString(),
      supplierId: _toInt(json['supplier_id']) ?? supplierRef?.id ?? 0,
      supplierName: json['supplier_name']?.toString() ?? supplierRef?.name,
      warehouseId: _toInt(json['warehouse_id']) ?? warehouseRef?.id ?? 0,
      warehouseName: json['warehouse_name']?.toString() ?? warehouseRef?.name,
      notes: json['notes']?.toString(),
      taxRate: _toDouble(json['tax_rate']) ?? 0,
      shippingCost: _toDouble(json['shipping_cost']) ?? 0,
      subtotal: _toDouble(json['subtotal']) ?? 0,
      taxAmount: _toDouble(json['tax_amount']) ?? 0,
      total: _toDouble(json['total']) ?? 0,
      createdAt: _toDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _toDate(json['updated_at']) ?? DateTime.now(),
      receivedAt: _toDate(json['received_at']),
      createdById: _toInt(json['created_by']) ?? createdByRef?.id,
      createdByName: json['created_by_name']?.toString() ?? createdByRef?.name,
      supplier: supplierRef,
      warehouse: warehouseRef,
      createdBy: createdByRef,
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'po_number': poNumber,
      'reference_number': referenceNumber,
      'status': status,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'warehouse_id': warehouseId,
      'warehouse_name': warehouseName,
      'notes': notes,
      'tax_rate': taxRate,
      'shipping_cost': shippingCost,
      'subtotal': subtotal,
      'tax_amount': taxAmount,
      'total': total,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'received_at': receivedAt?.toIso8601String(),
      'created_by': createdById,
      'created_by_name': createdByName,
      'supplier': supplier?.toJson(),
      'warehouse': warehouse?.toJson(),
      'created_by_object': createdBy?.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  PurchaseOrder copyWith({
    int? id,
    String? poNumber,
    String? referenceNumber,
    String? status,
    int? supplierId,
    String? supplierName,
    int? warehouseId,
    String? warehouseName,
    String? notes,
    double? taxRate,
    double? shippingCost,
    double? subtotal,
    double? taxAmount,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? receivedAt,
    int? createdById,
    String? createdByName,
    PurchaseOrderRef? supplier,
    PurchaseOrderRef? warehouse,
    PurchaseOrderRef? createdBy,
    List<PurchaseOrderItem>? items,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      poNumber: poNumber ?? this.poNumber,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      status: status ?? this.status,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      notes: notes ?? this.notes,
      taxRate: taxRate ?? this.taxRate,
      shippingCost: shippingCost ?? this.shippingCost,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      receivedAt: receivedAt ?? this.receivedAt,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      supplier: supplier ?? this.supplier,
      warehouse: warehouse ?? this.warehouse,
      createdBy: createdBy ?? this.createdBy,
      items: items ?? this.items,
    );
  }

  // Check if the purchase order can be received
  bool get canReceive => status == 'ordered' && items.any((item) => (item.receivedQuantity ?? 0) < item.quantity);

  // Calculate remaining quantity to receive
  int get remainingQuantity => items.fold(0, (sum, item) => sum + (item.quantity - (item.receivedQuantity ?? 0)));

  // Convert to legacy Purchase model for backward compatibility
  Purchase toPurchase() {
    return Purchase(
      id: id,
      supplier: Supplier(
        id: supplierId,
        name: supplierName ?? '',
      ),
      date: createdAt,
      purchaseId: poNumber,
      notes: notes,
      items: items.map((item) => PurchaseItem(
        id: item.id,
        product: item.product,
        price: item.unitPrice,
        quantity: item.quantity,
      )).toList(),
      total: total,
      status: status,
      createdAt: createdAt,
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  return null;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

class PurchaseOrderItem {
  final int? id;
  final int productId;
  final Product product;
  final int quantity;
  final double unitPrice;
  final double? taxRate;
  final double? discount;
  final double totalPrice;
  final int? receivedQuantity;
 
  PurchaseOrderItem({
    this.id,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.taxRate,
    this.discount,
    this.receivedQuantity = 0,
  }) : totalPrice = (unitPrice * quantity) - (discount ?? 0);
 
  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderItem(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      productId: json['product_id'] != null
          ? int.tryParse(json['product_id'].toString()) ?? 0
          : 0,
      product: Product.fromJson(json['product'] ?? json),
      quantity: json['quantity'] != null
          ? int.tryParse(json['quantity'].toString()) ?? 0
          : 0,
      unitPrice: json['unit_price'] != null
          ? double.tryParse(json['unit_price'].toString()) ?? 0.0
          : 0.0,
      taxRate: json['tax_rate'] != null
          ? double.tryParse(json['tax_rate'].toString())
          : null,
      discount: json['discount'] != null
          ? double.tryParse(json['discount'].toString())
          : null,
      receivedQuantity: json['received_quantity'] != null
          ? int.tryParse(json['received_quantity'].toString()) ?? 0
          : 0,
    );
  }
 
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'tax_rate': taxRate,
      'discount': discount,
      'total_price': totalPrice,
    };
  }
 
  PurchaseOrderItem copyWith({
    int? id,
    int? productId,
    Product? product,
    int? quantity,
    double? unitPrice,
    double? taxRate,
    double? discount,
    int? receivedQuantity,
  }) {
    return PurchaseOrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      taxRate: taxRate ?? this.taxRate,
      discount: discount ?? this.discount,
      receivedQuantity: receivedQuantity ?? this.receivedQuantity,
    );
  }
}
import 'package:mobile_camsme_sana_project/core/models/purchase_item_model.dart';
import 'package:mobile_camsme_sana_project/core/models/purchase.dart';

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
    required this.items,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson.map((item) => PurchaseOrderItem.fromJson(item)).toList();
    final supplier = json['supplier'] as Map<String, dynamic>?;
    final warehouse = json['warehouse'] as Map<String, dynamic>?;
    final creator = json['creator'] as Map<String, dynamic>?;

    return PurchaseOrder(
      id: json['id'],
      poNumber: json['po_number'],
      referenceNumber: json['reference_number'],
      status: json['status'],
      supplierId: json['supplier_id'] ?? supplier?['id'] ?? 0,
      supplierName: json['supplier_name'] ?? supplier?['name'],
      warehouseId: json['warehouse_id'] ?? warehouse?['id'] ?? 0,
      warehouseName: json['warehouse_name'] ?? warehouse?['name'],
      notes: json['notes'],
      taxRate: json['tax_rate']?.toDouble() ?? 0,
      shippingCost: json['shipping_cost']?.toDouble() ?? 0,
      subtotal: json['subtotal']?.toDouble() ?? 0,
      taxAmount: json['tax_amount']?.toDouble() ?? 0,
      total: json['total']?.toDouble() ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
      receivedAt: json['received_at'] != null
          ? DateTime.parse(json['received_at'].toString())
          : null,
      createdById: json['created_by'] ?? creator?['id'],
      createdByName: json['created_by_name'] ?? creator?['name'],
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
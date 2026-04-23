import 'package:mobile_camsme_sana_project/core/models/product.dart';

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
      id: json['id'],
      productId: json['product_id'],
      product: Product.fromJson(json['product'] ?? json),
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
      taxRate: json['tax_rate']?.toDouble(),
      discount: json['discount']?.toDouble(),
      receivedQuantity: json['received_quantity'],
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
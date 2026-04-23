class CartItem {
  final int productId;
  final int warehouseId;
  final int quantity;

  CartItem({
    required this.productId,
    required this.warehouseId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'warehouse_id': warehouseId,
      'quantity': quantity,
    };
  }
}

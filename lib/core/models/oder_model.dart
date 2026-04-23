class Order {
  final String id;
  final DateTime date;
  final String warehouseId;
  final List<OrderItem> items;
  final double total;

  Order({
    required this.id,
    required this.date,
    required this.warehouseId,
    required this.items,
    required this.total,
  });
}

class OrderItem {
  final int productId;
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });
}

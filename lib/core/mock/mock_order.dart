// import '../models/oder_model.dart';
// import 'mock_product.dart';

// class OrderService {
//   static final List<Order> _orders = [];

//   static Future<void> createOrder(Order order) async {
//     _orders.add(order);

//     // decrease stock
//     for (final item in order.items) {
//       MockProduct.decreaseStock(item.productId, item.quantity);
//     }
//   }

//   static List<Order> getOrders({
//     required String warehouseId,
//     DateTime? from,
//     DateTime? to,
//   }) {
//     return _orders.where((o) {
//       if (o.warehouseId != warehouseId) return false;
//       if (from != null && o.date.isBefore(from)) return false;
//       if (to != null && o.date.isAfter(to)) return false;
//       return true;
//     }).toList();
//   }
// }

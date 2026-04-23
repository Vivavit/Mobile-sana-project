import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_camsme_sana_project/core/constants/config.dart';
import '../models/product.dart';
import 'session.dart';

class CheckoutService {
  static const String baseUrl = Config.apiBaseUrl;

  static Future<void> checkout(List<Product> products) async {
    if (Session.token == null) {
      throw Exception('Please login again');
    }

    if (Session.warehouseId == null) {
      throw Exception('Warehouse not assigned. Please login again.');
    }

    final warehouseId = int.tryParse(Session.warehouseId!);
    if (warehouseId == null || warehouseId <= 0) {
      throw Exception(
        'Invalid warehouse selected. Please re-login or select a valid warehouse.',
      );
    }

    final validProducts = products.where((p) => p.quantity > 0).toList();
    if (validProducts.isEmpty) {
      throw Exception('No products selected');
    }

    final items = validProducts.map((p) {
      return {
        'product_id': p.id,
        'warehouse_id': warehouseId,
        'quantity': p.quantity,
      };
    }).toList();

    // debugPrint('Checkout Request:');
    // debugPrint('Warehouse ID: $warehouseId');
    // debugPrint('Items: ${jsonEncode(items)}');

    final response = await http
        .post(
          Uri.parse('$baseUrl/checkout'),
          headers: {
            'Authorization': 'Bearer ${Session.token}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Client-Type': 'mobile',
          },
          body: jsonEncode({
            'warehouse_id': warehouseId,
            'items': items.map((p) {
              return {'product_id': p['product_id'], 'quantity': p['quantity']};
            }).toList(),
          }),
        )
        .timeout(const Duration(seconds: 30));

    // debugPrint('Response Status: ${response.statusCode}');
    // debugPrint('Response Body: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return;
    } else {
      throw Exception(data['message'] ?? 'Checkout failed');
    }
  }
}

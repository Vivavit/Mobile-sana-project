import 'package:mobile_camsme_sana_project/core/constants/config.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final String? sku;
  final int? categoryId;
  final int? brandId;
  final double price;
  final double? costPrice;
  final double? comparePrice;
  final double? weight;
  final int? defaultLowStockThreshold;
  final bool manageStock;
  final bool isActive;
  final bool isFeatured;
  final bool hasVariants;
  final String? slug;
  final String? shortDescription;

  // Backward compatibility fields
  final String image; // Primary image URL
  final int stock; // Total available stock
  int quantity; // Cart quantity (mutable)

  // Internal raw data (optional usage)
  final List<dynamic>? images;
  final List<dynamic>? inventoryLocations;

  Product({
    required this.id,
    required this.name,
    required this.description,
    this.sku,
    this.categoryId,
    this.brandId,
    required this.price,
    this.costPrice,
    this.comparePrice,
    this.weight,
    this.defaultLowStockThreshold,
    this.manageStock = false,
    this.isActive = true,
    this.isFeatured = false,
    this.hasVariants = false,
    this.slug,
    this.shortDescription,
    required this.image,
    required this.stock,
    this.quantity = 0,
    this.images,
    this.inventoryLocations,
  });

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    final id = json['id'] != null ? _parseInt(json['id']) : 0;
    final name = json['name'] ?? '';
    final description = json['description'] ?? '';
    final sku = json['sku'];
    final categoryId = json['category_id'] != null ? _parseInt(json['category_id']) : null;
    final brandId = json['brand_id'] != null ? _parseInt(json['brand_id']) : null;
    final price = _parseDouble(json['price']);
    final costPrice = json['cost_price'] != null ? _parseDouble(json['cost_price']) : null;
    final comparePrice = json['compare_price'] != null ? _parseDouble(json['compare_price']) : null;
    final weight = json['weight'] != null ? _parseDouble(json['weight']) : null;
    final defaultLowStockThreshold = json['default_low_stock_threshold'] != null ? _parseInt(json['default_low_stock_threshold']) : null;
    final manageStock = json['manage_stock'] == 1 || json['manage_stock'] == true;
    final isActive = json['is_active'] == 1 || json['is_active'] == true;
    final isFeatured = json['is_featured'] == 1 || json['is_featured'] == true;
    final hasVariants = json['has_variants'] == 1 || json['has_variants'] == true;
    final slug = json['slug'];
    final shortDescription = json['short_description'];

    // Determine primary image URL
    String primaryImage = '';
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      final firstImage = json['images'][0];
      if (firstImage is Map) {
        final path = firstImage['image_path'] ?? '';
        primaryImage = Config.getProductImageUrl(path);
      } else if (firstImage is String) {
        primaryImage = Config.getProductImageUrl(firstImage);
      }
    } else if (json['image'] != null) {
      primaryImage = Config.getProductImageUrl(json['image']);
    }

    // Calculate total stock from inventory locations or fallback
    int totalStock = 0;
    if (json['inventory_locations'] != null) {
      totalStock = (json['inventory_locations'] as List)
          .fold(0, (sum, loc) => sum + _parseInt(loc['quantity']));
    } else {
      final stockCandidates = [
        json['stock'],
        json['available_stock'],
        json['available'],
        json['qty'],
        json['quantity'],
      ];
      for (var c in stockCandidates) {
        final v = _parseInt(c);
        if (v != 0) {
          totalStock = v;
          break;
        }
      }
    }

    return Product(
      id: id,
      name: name,
      description: description,
      sku: sku,
      categoryId: categoryId,
      brandId: brandId,
      price: price,
      costPrice: costPrice,
      comparePrice: comparePrice,
      weight: weight,
      defaultLowStockThreshold: defaultLowStockThreshold,
      manageStock: manageStock,
      isActive: isActive,
      isFeatured: isFeatured,
      hasVariants: hasVariants,
      slug: slug,
      shortDescription: shortDescription,
      image: primaryImage,
      stock: totalStock,
      images: json['images'] as List<dynamic>?,
      inventoryLocations: json['inventory_locations'] as List<dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sku': sku,
      'category_id': categoryId,
      'brand_id': brandId,
      'price': price,
      'cost_price': costPrice,
      'compare_price': comparePrice,
      'weight': weight,
      'default_low_stock_threshold': defaultLowStockThreshold,
      'manage_stock': manageStock ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'is_featured': isFeatured ? 1 : 0,
      'has_variants': hasVariants ? 1 : 0,
      'slug': slug,
      'short_description': shortDescription,
      'image': image,
      'stock': stock,
      'quantity': quantity,
      'images': images,
      'inventory_locations': inventoryLocations,
    };
  }
}

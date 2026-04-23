/// Model to hold product form data during create/edit operations
class ProductFormData {
  String name;
  String sku;
  int categoryId;
  int? brandId;
  double price;
  double? costPrice;
  double? comparePrice;
  String? description;
  String? shortDescription;
  double? weight;
  int? defaultLowStockThreshold;
  bool manageStock;
  bool isActive;
  bool isFeatured;
  List<Map<String, dynamic>> warehouseStock;
  List<dynamic>? images; // List of File objects (or XFile) when uploading
  String? existingImageUrl; // For edit mode to show current image

  ProductFormData({
    required this.name,
    required this.sku,
    required this.categoryId,
    this.brandId,
    required this.price,
    this.costPrice,
    this.comparePrice,
    this.description,
    this.shortDescription,
    this.weight,
    this.defaultLowStockThreshold,
    this.manageStock = false,
    this.isActive = true,
    this.isFeatured = false,
    List<Map<String, dynamic>>? warehouseStock,
    this.images,
    this.existingImageUrl,
  }) : warehouseStock = warehouseStock ?? [];

  /// Convert form data to API map (excluding warehouseStock and images which are separate)
  Map<String, dynamic> toApiMap() {
    return {
      'name': name,
      'sku': sku,
      'category_id': categoryId,
      'brand_id': brandId,
      'price': price,
      'cost_price': costPrice,
      'compare_price': comparePrice,
      'description': description,
      'short_description': shortDescription,
      'weight': weight,
      'default_low_stock_threshold': defaultLowStockThreshold,
      'manage_stock': manageStock ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'is_featured': isFeatured ? 1 : 0,
    };
  }

  /// Convert to warehouse_stock array for API
  Map<String, dynamic> toWarehouseStockMap() {
    final map = <String, dynamic>{};
    for (var item in warehouseStock) {
      final warehouseId = item['warehouse_id'].toString();
      map[warehouseId] = item['quantity'];
    }
    return map;
  }

  /// Convert to location_code array for API (indexed by warehouse_id)
  Map<String, dynamic> toLocationCodeMap() {
    final map = <String, dynamic>{};
    for (var item in warehouseStock) {
      final warehouseId = item['warehouse_id'].toString();
      if (item['location_code'] != null) {
        map[warehouseId] = item['location_code'];
      }
    }
    return map;
  }

  /// Create form data from existing product (for edit mode)
  factory ProductFormData.fromProduct(Map<String, dynamic> product) {
    final stockList = <Map<String, dynamic>>[];
    if (product['inventory_locations'] != null) {
      for (var loc in product['inventory_locations']) {
        stockList.add({
          'warehouse_id': loc['warehouse_id'],
          'quantity': loc['quantity'],
          'location_code': loc['location_code'] ?? '',
        });
      }
    }

    // Determine first image URL if exists
    String? imageUrl;
    if (product['images'] != null && (product['images'] as List).isNotEmpty) {
      final first = product['images'][0];
      if (first is Map) {
        imageUrl = first['image_path'];
      } else if (first is String) {
        imageUrl = first;
      }
    }

    return ProductFormData(
      name: product['name'] ?? '',
      sku: product['sku'] ?? '',
      categoryId: product['category_id'] ?? 0,
      brandId: product['brand_id'],
      price: product['price']?.toDouble() ?? 0.0,
      costPrice: product['cost_price']?.toDouble(),
      comparePrice: product['compare_price']?.toDouble(),
      description: product['description'],
      shortDescription: product['short_description'],
      weight: product['weight']?.toDouble(),
      defaultLowStockThreshold: product['default_low_stock_threshold'],
      manageStock: product['manage_stock'] == 1 || product['manage_stock'] == true,
      isActive: product['is_active'] == 1 || product['is_active'] == true,
      isFeatured: product['is_featured'] == 1 || product['is_featured'] == true,
      warehouseStock: stockList,
      existingImageUrl: imageUrl,
    );
  }

  /// Reset to defaults
  void clear() {
    name = '';
    sku = '';
    categoryId = 0;
    brandId = null;
    price = 0.0;
    costPrice = null;
    comparePrice = null;
    description = null;
    shortDescription = null;
    weight = null;
    defaultLowStockThreshold = null;
    manageStock = false;
    isActive = true;
    isFeatured = false;
    warehouseStock.clear();
    images = null;
    existingImageUrl = null;
  }
}

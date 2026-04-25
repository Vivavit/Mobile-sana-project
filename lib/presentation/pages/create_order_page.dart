import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/models/order_model.dart';
import 'package:mobile_camsme_sana_project/core/models/product.dart' as product_model;
import 'package:mobile_camsme_sana_project/core/models/warehouse.dart';
import 'package:mobile_camsme_sana_project/core/providers/order_provider.dart';
import 'package:mobile_camsme_sana_project/core/services/api_service.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/loading_states.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage>
    with TickerProviderStateMixin {
  late CreateOrderProvider _createOrderProvider;
  late TabController _tabController;
  late TextEditingController _notesController;
  late TextEditingController _searchController;
  
  List<product_model.Product> _products = [];
  List<Warehouse> _warehouses = [];
  List<product_model.Product> _filteredProducts = [];
  bool _isLoadingProducts = false;
  bool _isLoadingWarehouses = false;
  String? _productsError;
  String? _warehousesError;

  @override
  void initState() {
    super.initState();
    _createOrderProvider = CreateOrderProvider();
    _tabController = TabController(length: 2, vsync: this);
    _notesController = TextEditingController();
    _searchController = TextEditingController();
    
    _loadData();
    
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) =>
        product.name.toLowerCase().contains(query) ||
        (product.sku?.toLowerCase().contains(query) ?? false)
      ).toList();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadProducts(),
      _loadWarehouses(),
    ]);
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productsError = null;
    });

    try {
      final productsData = await ApiService.fetchProducts();
      _products = productsData.map((json) => product_model.Product.fromJson(json as Map<String, dynamic>)).toList();
      _filteredProducts = _products;
    } catch (e) {
      _productsError = e.toString();
    } finally {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _loadWarehouses() async {
    setState(() {
      _isLoadingWarehouses = true;
      _warehousesError = null;
    });

    try {
      final warehousesData = await ApiService.fetchWarehouses();
      _warehouses = warehousesData.map((json) => Warehouse.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      _warehousesError = e.toString();
    } finally {
      setState(() {
        _isLoadingWarehouses = false;
      });
    }
  }

  Future<void> _createOrder() async {
    final success = await _createOrderProvider.createOrder();
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_createOrderProvider.errorMessage ?? 'Failed to create order'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectWarehouse(Warehouse warehouse) {
    _createOrderProvider.selectWarehouse(warehouse.id);
  }

  void _addProduct(product_model.Product product) {
    if (product.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This product is out of stock'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _createOrderProvider.addItem(
      CreateOrderItemRequest(
        productId: product.id,
        quantity: 1,
        price: product.price,
      ),
    );
  }

  void _updateItemQuantity(int productId, int quantity) {
    _createOrderProvider.updateItemQuantity(productId, quantity);
  }

  void _removeItem(int productId) {
    _createOrderProvider.removeItem(productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Order Summary'),
          ],
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          _buildSummaryTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProductsTab() {
    if (_isLoadingProducts) {
      return const LoadingWidget();
    }

    if (_productsError != null) {
      return ErrorStateWidget(
        message: _productsError!,
        onRetry: _loadProducts,
      );
    }

    if (_products.isEmpty) {
      return const EmptyStateWidget(
        title: 'No products available',
        subtitle: 'There are no products to add to your order',
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        // Warehouse selector
        _buildWarehouseSelector(),
        // Products list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final product = _filteredProducts[index];
              return ProductCard(
                product: product,
                onAdd: () => _addProduct(product),
                isInCart: _createOrderProvider.items.any((item) => item.productId == product.id),
                currentQuantity: _createOrderProvider.items
                    .firstWhere((item) => item.productId == product.id,
                        orElse: () => CreateOrderItemRequest(productId: product.id, quantity: 0, price: product.price))
                    .quantity,
                onQuantityChanged: (quantity) => _updateItemQuantity(product.id, quantity),
                onRemove: () => _removeItem(product.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWarehouseSelector() {
    if (_isLoadingWarehouses) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LoadingWidget(height: 48),
      );
    }

    if (_warehousesError != null || _warehouses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Warehouse',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _warehouses.map((warehouse) {
              final isSelected = _createOrderProvider.selectedWarehouseId == warehouse.id;
              return FilterChip(
                label: Text(warehouse.name),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    _selectWarehouse(warehouse);
                  }
                },
                backgroundColor: Colors.grey[100],
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                checkmarkColor: Theme.of(context).primaryColor,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    final items = _createOrderProvider.items;
    final selectedWarehouseId = _createOrderProvider.selectedWarehouseId;

    if (items.isEmpty) {
      return const EmptyStateWidget(
        title: 'Your cart is empty',
        subtitle: 'Add some products to create an order',
        icon: Icons.shopping_cart_outlined,
      );
    }

    return Column(
      children: [
        // Order items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final product = _products.firstWhere(
                (p) => p.id == item.productId,
                orElse: () => product_model.Product(
                  id: item.productId,
                  name: 'Product ${item.productId}',
                  description: '',
                  price: item.price,
                  image: '',
                  stock: 0,
                ),
              );
              return OrderSummaryItem(
                product: product,
                item: item,
                onQuantityChanged: (quantity) => _updateItemQuantity(item.productId, quantity),
                onRemove: () => _removeItem(item.productId),
              );
            },
          ),
        ),
        // Notes field
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Notes (Optional)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                onChanged: _createOrderProvider.updateNotes,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add any special instructions...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final items = _createOrderProvider.items;
    final subtotal = _createOrderProvider.subtotal;
    final selectedWarehouseId = _createOrderProvider.selectedWarehouseId;
    final isLoading = _createOrderProvider.isLoading;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedWarehouseId == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Please select a warehouse',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total (${items.length} items)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '\$${subtotal.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: (selectedWarehouseId != null && !isLoading) ? _createOrder : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isLoading
                      ? const LoadingWidget(width: 16, height: 16)
                      : const Text('Create Order'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final product_model.Product product;
  final VoidCallback onAdd;
  final bool isInCart;
  final int currentQuantity;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAdd,
    required this.isInCart,
    required this.currentQuantity,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  image: product.image.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(product.image),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: product.image.isEmpty
                    ? const Icon(Icons.inventory_2_outlined, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Stock: ${product.stock}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: product.stock > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              // Add/Quantity controls
              if (!isInCart)
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: currentQuantity > 1
                          ? () => onQuantityChanged(currentQuantity - 1)
                          : onRemove,
                      icon: Icon(
                        currentQuantity > 1 ? Icons.remove_circle : Icons.delete,
                        color: currentQuantity > 1 ? Colors.orange : Colors.red,
                      ),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        currentQuantity.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: currentQuantity < product.stock
                          ? () => onQuantityChanged(currentQuantity + 1)
                          : null,
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderSummaryItem extends StatelessWidget {
  final product_model.Product product;
  final CreateOrderItemRequest item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const OrderSummaryItem({
    super.key,
    required this.product,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Product image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              image: product.image.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(product.image),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product.image.isEmpty
                ? const Icon(Icons.inventory_2_outlined, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '\$${item.price.toStringAsFixed(2)} each',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Quantity controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: item.quantity > 1
                    ? () => onQuantityChanged(item.quantity - 1)
                    : onRemove,
                icon: Icon(
                  item.quantity > 1 ? Icons.remove_circle : Icons.delete,
                  color: item.quantity > 1 ? Colors.orange : Colors.red,
                  size: 24,
                ),
              ),
              Container(
                width: 30,
                alignment: Alignment.center,
                child: Text(
                  item.quantity.toString(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: item.quantity < product.stock
                    ? () => onQuantityChanged(item.quantity + 1)
                    : null,
                icon: const Icon(Icons.add_circle, color: Colors.green, size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

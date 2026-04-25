import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/models/product.dart';
import 'package:mobile_camsme_sana_project/core/services/api_service.dart';
import 'package:mobile_camsme_sana_project/core/services/product_cache_service.dart';
import 'package:mobile_camsme_sana_project/core/utils/permission_checker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage>
    with TickerProviderStateMixin {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _canManageProducts = false;
  late AnimationController _fabAnimController;
  late Animation<double> _fabAnim;

  @override
  void initState() {
    super.initState();
    _canManageProducts = PermissionChecker.canManageProducts();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fabAnim = CurvedAnimation(
      parent: _fabAnimController,
      curve: Curves.easeOutBack,
    );
    _loadProducts();
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<dynamic> data = await ApiService.fetchProducts();
      final products = data
          .whereType<Map<String, dynamic>>()
          .map((e) => Product.fromJson(e))
          .toList();

      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
        if (_canManageProducts) _fabAnimController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _refresh() async {
    _fabAnimController.reverse();
    await _loadProducts();
  }

  Future<void> _deleteProduct(int productId, String productName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade400, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Product',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "$productName"? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.deleteProduct(productId);
        await ProductCacheService.clearCache();
        if (mounted) {
          _showSnackBar('Product deleted successfully', isError: false);
          await _loadProducts();
        }
      } catch (e) {
        if (mounted) {
          _showSnackBar('Failed to delete: $e', isError: true);
        }
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _navigateToEdit(int productId) {
    Navigator.pushNamed(context, '/admin/products/edit', arguments: productId)
        .then((_) => _loadProducts());
  }

  void _navigateToCreate() {
    Navigator.pushNamed(context, '/admin/products/create')
        .then((_) => _loadProducts());
  }

  void _navigateToDetail(int productId) {
    Navigator.pushNamed(context, '/admin/products/detail', arguments: productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: _buildBody(),
      floatingActionButton: _canManageProducts
          ? ScaleTransition(
              scale: _fabAnim,
              child: FloatingActionButton(
                onPressed: _navigateToCreate,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 3,
                child: const Icon(Icons.add_rounded),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading && _products.isEmpty) {
      return _buildLoadingSkeleton();
    }

    if (_errorMessage != null && _products.isEmpty) {
      return _buildErrorState();
    }

    if (_products.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: AppColors.primary,
      child: CustomScrollView(
        slivers: [
          if (!_canManageProducts) _buildViewOnlyBanner(),
          SliverToBoxAdapter(  // Wrap SizedBox in SliverToBoxAdapter
          child: SizedBox(height: 12),
        ),
          SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),  // Changed left padding from 160 to 16
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ProductCard(
                product: _products[index],
                canManage: _canManageProducts,
                onTap: () => _navigateToDetail(_products[index].id),
                onEdit: () => _navigateToEdit(_products[index].id),
                onDelete: () =>
                    _deleteProduct(_products[index].id, _products[index].name),
              ),
              childCount: _products.length,
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => const _SkeletonCard(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off_rounded,
                  color: Colors.red.shade300, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inventory_2_outlined,
                  color: Colors.grey.shade400, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'No products yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _canManageProducts
                  ? 'Tap "Add Product" below to create your first one.'
                  : 'No products have been added yet.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildViewOnlyBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.visibility_outlined,
                color: Colors.amber.shade700, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'View-only mode — admin access required to manage products.',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.amber.shade800,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatefulWidget {
  final Product product;
  final bool canManage;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.canManage,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _pressController;
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isLowStock = product.stock < 5;

    return GestureDetector(
      onTapDown: (_) => _pressController.reverse(),
      onTapUp: (_) {
        _pressController.forward();
        widget.onTap();
      },
      onTapCancel: () => _pressController.forward(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              children: [
                // Image
                _buildProductImage(product),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${product.sku ?? 'N/A'}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _PriceBadge(price: product.price),
                          const SizedBox(width: 8),
                          _StockBadge(
                              stock: product.stock, isLow: isLowStock),
                        ],
                      ),
                    ],
                  ),
                ),
                // Actions
                _buildActionMenu(product),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: product.image.isNotEmpty
            ? product.image
            : 'https://via.placeholder.com/72',
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 72,
          height: 72,
          color: Colors.grey.shade100,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 72,
          height: 72,
          color: Colors.grey.shade100,
          child: Icon(Icons.image_not_supported_outlined,
              color: Colors.grey.shade400, size: 28),
        ),
      ),
    );
  }

  Widget _buildActionMenu(Product product) {
    return PopupMenuButton<_ProductAction>(
      icon: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.more_vert_rounded, color: Colors.grey.shade700, size: 20),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      padding: EdgeInsets.zero,
      onSelected: (action) {
        switch (action) {
          case _ProductAction.view:
            widget.onTap();
            break;
          case _ProductAction.edit:
            widget.onEdit();
            break;
          case _ProductAction.delete:
            widget.onDelete();
            break;
        }
      },
      itemBuilder: (context) {
        final items = <PopupMenuItem<_ProductAction>>[
          PopupMenuItem(
            value: _ProductAction.view,
            child: Row(
              children: [
                Icon(Icons.open_in_new_rounded, size: 18, color: Colors.blue.shade600),
                const SizedBox(width: 10),
                const Text('View Details'),
              ],
            ),
          ),
        ];

        if (widget.canManage) {
          items.addAll([
            PopupMenuItem(
              value: _ProductAction.edit,
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, size: 18, color: Colors.orange.shade600),
                  const SizedBox(width: 10),
                  const Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: _ProductAction.delete,
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red.shade600),
                  const SizedBox(width: 10),
                  const Text('Delete'),
                ],
              ),
            ),
          ]);
        }

        return items;
      },
    );
  }
}

enum _ProductAction { view, edit, delete }

class _PriceBadge extends StatelessWidget {
  final double price;
  const _PriceBadge({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '\$${price.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.green.shade700,
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;
  final bool isLow;
  const _StockBadge({required this.stock, required this.isLow});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLow ? Colors.red.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLow)
            Icon(Icons.warning_amber_rounded,
                size: 12, color: Colors.red.shade500),
          if (isLow) const SizedBox(width: 3),
          Text(
            'Stock: $stock',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isLow ? Colors.red.shade600 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton Loader ──────────────────────────────────────────────────────────

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (_, __) {
        final opacity =
            0.4 + (_shimmerController.value * 0.4);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _shimmerBox(72, 72, radius: 12, opacity: opacity),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(20, double.infinity, radius: 6, opacity: opacity),
                    const SizedBox(height: 8),
                    _shimmerBox(14, 100, radius: 6, opacity: opacity),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _shimmerBox(26, 60, radius: 8, opacity: opacity),
                        const SizedBox(width: 8),
                        _shimmerBox(26, 70, radius: 8, opacity: opacity),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerBox(double height, double width,
      {required double radius, required double opacity}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade200.withOpacity(opacity),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
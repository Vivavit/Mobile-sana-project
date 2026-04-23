import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/models/product.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/constants/config.dart';
import 'package:mobile_camsme_sana_project/core/services/api_service.dart';
import 'package:mobile_camsme_sana_project/core/services/product_cache_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ProductListWidget extends StatefulWidget {
  final Function(int)? onItemAdded;
  final String selectedFilter;
  final String searchQuery;
  final Function(List<Product>)? onCartChanged;
  final Function(VoidCallback)? onClearCartCallback;
  final void Function()? onProductsLoaded;

  const ProductListWidget({
    super.key,
    this.onItemAdded,
    this.onCartChanged,
    this.onClearCartCallback,
    required this.selectedFilter,
    required this.searchQuery,
    required this.onProductsLoaded,
  });

  @override
  State<ProductListWidget> createState() => ProductListWidgetState();
}

class ProductListWidgetState extends State<ProductListWidget> {
  List<Product> products = [];
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onClearCartCallback?.call(clearCart);
  }

  /// Public method: Called by the InventoryPage refresh trigger
  Future<void> refreshData() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });
    await loadProducts(forceRefresh: true);
  }

  /// Load products with optional force refresh and retry logic
  Future<void> loadProducts({bool forceRefresh = false, int retryCount = 0}) async {
    try {
      // Try to get cached products first (only on initial load)
      if (!forceRefresh && retryCount == 0) {
        final cachedProducts = await ProductCacheService.getCachedProducts();
        if (cachedProducts != null && mounted) {
          setState(() {
            products = cachedProducts;
            isLoading = false;
            hasError = false;
          });
          widget.onProductsLoaded?.call();
        }
      }

      // Fetch fresh data from API
      final data = await ApiService.fetchProducts();

      // Cache the fresh data
      await ProductCacheService.cacheProducts(
        data.map((e) => e is Product ? e : Product.fromJson(e)).toList(),
      );

      if (mounted) {
        setState(() {
          products = data.map((e) => e is Product ? e : Product.fromJson(e)).toList();
          isLoading = false;
          hasError = false;
          errorMessage = null;
        });
      }
      widget.onProductsLoaded?.call();
    } catch (e) {
      debugPrint("Error fetching products: $e");

      if (mounted) {
        // Retry logic: try up to 2 times with exponential backoff
        if (retryCount < 2) {
          setState(() => isLoading = true);
          await Future.delayed(Duration(seconds: (retryCount + 1) * 2));
          await loadProducts(forceRefresh: forceRefresh, retryCount: retryCount + 1);
          return;
        }

        setState(() {
          isLoading = false;
          hasError = true;
          errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  void updateCart() {
    final cartProducts = products.where((p) => p.quantity > 0).toList();
    widget.onItemAdded?.call(
      cartProducts.fold(0, (sum, p) => sum + p.quantity),
    );
    widget.onCartChanged?.call(cartProducts);
  }

  void clearCart() {
    setState(() {
      for (var product in products) {
        product.quantity = 0;
      }
    });
    updateCart();
  }

  @override
  Widget build(BuildContext context) {
    // Show error state if there's an error
    if (hasError && products.isEmpty) {
      return _buildErrorState();
    }

    if (isLoading && products.isEmpty) {
      return _buildSkeletonLoader();
    }

    // --- FILTER LOGIC ---
    var filteredProducts = products.where((product) {
      final search = widget.searchQuery.toLowerCase();
      final matchesSearch =
          product.name.toLowerCase().contains(search) ||
          product.description.toLowerCase().contains(search);

      bool matchesFilter;
      switch (widget.selectedFilter) {
        case "Out Of Stock":
          matchesFilter = product.stock == 0;
          break;
        case "In Stock":
          matchesFilter = product.stock > 5;
          break;
        case "Low Stock":
          matchesFilter = product.stock > 0 && product.stock <= 5;
          break;
        default:
          matchesFilter = true;
      }
      return matchesFilter && matchesSearch;
    }).toList();

    filteredProducts = filteredProducts.reversed.toList();

    if (filteredProducts.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                widget.searchQuery.isNotEmpty
                    ? "No products match your search"
                    : "No products available",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              if (widget.searchQuery.isNotEmpty) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    // Clear search - parent widget handles this
                  },
                  icon: const Icon(Icons.clear, size: 18),
                  label: const Text("Clear search"),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return AnimationConfiguration.staggeredGrid(
          position: index,
          duration: const Duration(milliseconds: 375),
          columnCount: 2,
          child: SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(
              child: _buildProductCard(product),
            ),
          ),
        );
      },
    );
  }

  /// Skeleton loader with shimmer effect
  Widget _buildSkeletonLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade100,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 6, // Show 6 skeleton cards
        itemBuilder: (context, index) {
          return _SkeletonProductCard();
        },
      ),
    );
  }

  /// Error state with retry button
  Widget _buildErrorState() {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Failed to load products',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
                loadProducts(forceRefresh: true);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with smooth loading
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: CachedNetworkImage(
              imageUrl: product.image.isNotEmpty
                  ? product.image.startsWith('http')
                      ? product.image
                      : Config.getProductImageUrl(product.image)
                  : 'https://via.placeholder.com/300x200/E9FFFA/03624C?text=No+Image',
              width: double.infinity,
              height: 120,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 300),
              placeholder: (context, url) => Container(
                width: double.infinity,
                height: 120,
                color: Colors.grey.shade200,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (context, url, error) {
                debugPrint('Image error for $url: $error');
                // Fallback to placeholder on any error
                return Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      product.name.isNotEmpty ? product.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${product.stock} stock",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "\$${product.price.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      _buildAddOrCounter(product),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOrCounter(Product product) {
    if (product.quantity == 0) {
      final isOutOfStock = product.stock == 0;
      return GestureDetector(
        onTap: isOutOfStock
            ? null
            : () {
                setState(() => product.quantity = 1);
                updateCart();
              },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isOutOfStock ? Colors.red.shade200 : AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            isOutOfStock ? "Out" : "Add",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _iconButton(Icons.remove, () {
            setState(() {
              if (product.quantity > 0) product.quantity--;
            });
            updateCart();
          }),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: Text(
              key: ValueKey(product.quantity),
              product.quantity.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          _iconButton(Icons.add, () {
            setState(() {
              if (product.quantity < product.stock) product.quantity++;
            });
            updateCart();
          }),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}

/// Skeleton loading card with shimmer effect
class _SkeletonProductCard extends StatelessWidget {
  const _SkeletonProductCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer effect for image placeholder
          Container(
            width: double.infinity,
            height: 120,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Container(
                color: Colors.grey.shade200,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 40,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

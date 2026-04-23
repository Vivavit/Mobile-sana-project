import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/models/product.dart';
import 'package:mobile_camsme_sana_project/core/utils/debouncer.dart';
import 'package:mobile_camsme_sana_project/core/utils/page_transitions.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/checkout.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/product_list_widget.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/search_widget.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/checkout_bar_widget.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class InventoryPage extends StatefulWidget {
  final VoidCallback? onLoadingComplete;

  const InventoryPage({super.key, this.onLoadingComplete});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final GlobalKey<ProductListWidgetState> _productListKey = GlobalKey();

  String selectedFilter = "All";
  String searchQuery = "";
  int totalItems = 0;
  bool showCheckoutBar = false;
  List<Product> cartProducts = [];
  VoidCallback? _clearCartCallback;
  final Debouncer _searchDebouncer = Debouncer(milliseconds: 300);

  final List<String> filters = ["All", "Out Of Stock", "In Stock", "Low Stock"];

  double get total =>
      cartProducts.fold(0, (sum, p) => sum + (p.price * p.quantity));

  Future<void> _handleRefresh() async {
    await _productListKey.currentState?.refreshData();

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {});
    widget.onLoadingComplete?.call();
  }

  @override
  void initState() {
    super.initState();
    // ProductListWidget will call onProductsLoaded when data is ready
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F0),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: Colors.white,
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  children: [
                    AnimationConfiguration.staggeredList(
                      position: 0,
                      delay: const Duration(milliseconds: 100),
                      duration: const Duration(milliseconds: 300),
                      child: SlideAnimation(
                        verticalOffset: 30.0,
                        child: FadeInAnimation(
                          child: SearchWidget(
                            onChanged: (value) {
                              // Debounce search to prevent excessive rebuilds
                              _searchDebouncer.run(() {
                                if (mounted) {
                                  setState(() {
                                    searchQuery = value;
                                  });
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ),

                    _buildFilterChips(),

                    const SizedBox(height: 10),

                    ProductListWidget(
                      key: _productListKey,
                      selectedFilter: selectedFilter,
                      searchQuery: searchQuery,
                      onItemAdded: (count) {
                        setState(() {
                          totalItems = count;
                          showCheckoutBar = count > 0;
                        });
                      },
                      onCartChanged: (products) => cartProducts = products,
                      onClearCartCallback: (callback) =>
                          _clearCartCallback = callback,
                      onProductsLoaded: () {},
                    ),

                    SizedBox(height: showCheckoutBar ? 100 : 20),
                  ],
                ),
              ),
            ),

            if (showCheckoutBar)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildCheckoutBar(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;
          return AnimationConfiguration.staggeredList(
            position: index,
            delay: Duration(milliseconds: index * 100),
            duration: const Duration(milliseconds: 300),
            child: SlideAnimation(
              verticalOffset: 30.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => selectedFilter = filter),
                    selectedColor: AppColors.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 13,
                    ),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

Widget _buildCheckoutBar() {
  return AnimatedSlide(
    offset: showCheckoutBar ? Offset.zero : const Offset(0, 1),
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeOutCubic,
    child: AnimatedOpacity(
      opacity: showCheckoutBar ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: CheckoutBarWidget(
        totalItems: totalItems,
        total: total,
        onClearCart: _clearCartCallback,
        onCheckout: () async {
          final success = await Navigator.push<bool>(
            context,
            SmoothPageRoute(
              builder: (_) => CheckoutPage(products: List.from(cartProducts)),
              type: TransitionType.slide,
            ),
          );
          if (success == true && mounted) {
            _clearCartCallback?.call();
            setState(() {
              cartProducts.clear();
              totalItems = 0;
              showCheckoutBar = false;
            });
          }
        },
      ),
    ),
  );
}
}

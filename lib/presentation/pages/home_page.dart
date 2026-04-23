import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/models/product.dart';
import '../../core/services/api_service.dart';
import 'package:mobile_camsme_sana_project/core/utils/page_transitions.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/product_list_widget.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/search_widget.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/checkout.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/checkout_bar_widget.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onLoadingComplete;

  const HomePage({super.key, this.onLoadingComplete});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = "";
  Map<String, dynamic> dashboardStats = {};
  bool isLoadingStats = true;
  bool isProductsLoaded = false;

  int totalItems = 0;
  bool showCheckoutBar = false;
  List<Product> cartProducts = [];
  List<Map<String, dynamic>> get dashboardCards => [
    {
      'title': 'Total Sales',
      'value': '\$${dashboardStats['total_sales'] ?? '0.00'}',
      'icon': Icons.attach_money,
      'color': AppColors.primary,
    },
    {
      'title': 'Total Stock',
      'value': '${dashboardStats['total_stock'] ?? 0}',
      'icon': Icons.inventory_2_outlined,
      'color': Colors.blue,
    },
    {
      'title': 'Out Of Stock',
      'value': '${dashboardStats['out_of_stock'] ?? 0}',
      'icon': Icons.shopping_bag_outlined,
      'color': Colors.red,
    },
    {
      'title': 'Low On Stock',
      'value': '${dashboardStats['low_stock'] ?? 0}',
      'icon': Icons.warning_amber_rounded,
      'color': Colors.orange,
    },
  ];
  VoidCallback? _clearCartCallback;

  double get total {
    return cartProducts.fold(0, (sum, p) => sum + (p.price * p.quantity));
  }

  @override
  void initState() {
    super.initState();
    loadDashboardStats();
  }

  Future<void> loadDashboardStats() async {
    setState(() {
      isLoadingStats = true;
      isProductsLoaded = false;
    });
    try {
      // Try cache first for stats
      dashboardStats = await ApiService.fetchDashboardStats();
    } catch (e) {
      debugPrint(e.toString());
      // Set default empty stats on error
      dashboardStats = {
        'total_sales': 0,
        'total_stock': 0,
        'out_of_stock': 0,
        'low_stock': 0,
      };
    }
    if (mounted) {
      setState(() {
        isLoadingStats = false;
      });
      _checkIfFullyLoaded();
    }
  }

  void _checkIfFullyLoaded() {
    if (!isLoadingStats && isProductsLoaded) {
      widget.onLoadingComplete?.call();
    }
  }

  // NEW: Callback for when products finish loading
  void _onProductsLoaded() {
    if (mounted) {
      setState(() {
        isProductsLoaded = true;
      });
      _checkIfFullyLoaded();
    }
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
              onRefresh: loadDashboardStats,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.4,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: dashboardCards.length,
                        itemBuilder: (context, index) {
                          final card = dashboardCards[index];
                          return AnimationConfiguration.staggeredGrid(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            columnCount: 2,
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildInfoCard(
                                  title: card['title'],
                                  value: card['value'],
                                  icon: card['icon'],
                                  iconColor: card['color'],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    AnimationConfiguration.staggeredList(
                      position: 2,
                      delay: const Duration(milliseconds: 200),
                      duration: const Duration(milliseconds: 300),
                      child: SlideAnimation(
                        verticalOffset: 30.0,
                        child: FadeInAnimation(
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: SearchWidget(
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                    ProductListWidget(
                      searchQuery: searchQuery,
                      selectedFilter: '',
                      onItemAdded: (count) {
                        setState(() {
                          totalItems = count;
                          showCheckoutBar = count > 0;
                        });
                      },
                      onCartChanged: (products) {
                        cartProducts = products;
                      },
                      onClearCartCallback: (callback) {
                        _clearCartCallback = callback;
                      },
                      onProductsLoaded: _onProductsLoaded,
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

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

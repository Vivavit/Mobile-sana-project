import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/models/purchase.dart';
import 'package:mobile_camsme_sana_project/core/services/purchase_service.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/purchase_card.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/purchases/create_purchase_page.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/search_widget.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mobile_camsme_sana_project/core/utils/page_transitions.dart';

class PurchaseListPage extends StatefulWidget {
  final VoidCallback? onLoadingComplete;

  const PurchaseListPage({super.key, this.onLoadingComplete});

  @override
  State<PurchaseListPage> createState() => _PurchaseListPageState();
}

class _PurchaseListPageState extends State<PurchaseListPage> {
  final PurchaseService _purchaseService = PurchaseService();

  List<Purchase> _purchases = [];
  List<Purchase> _filteredPurchases = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    final hasData = _purchases.isNotEmpty;
    setState(() {
      _isLoading = !hasData;
      _errorMessage = null;
    });

    try {
      // Use real API instead of mock
      _purchases = await _purchaseService.fetchPurchaseOrdersLegacy();
      _filteredPurchases = List.from(_purchases);
    } catch (e) {
      if (!hasData) {
        _purchases = [];
        _filteredPurchases = [];
      }
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        widget.onLoadingComplete?.call();
      }
    }
  }

  void _filterPurchases(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPurchases = List.from(_purchases);
      });
    } else {
      final lowerQuery = query.toLowerCase();
      setState(() {
        _filteredPurchases = _purchases.where((purchase) {
          final purchaseId = purchase.purchaseId?.toLowerCase() ?? '';
          final supplierName = purchase.supplier.name.toLowerCase();
          final hasMatchingItem = purchase.items.any(
            (item) => item.product.name.toLowerCase().contains(lowerQuery),
          );

          return purchaseId.contains(lowerQuery) ||
              supplierName.contains(lowerQuery) ||
              hasMatchingItem;
        }).toList();
      });
    }
  }

  Future<void> _handleRefresh() async {
    await _loadPurchases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _handleRefresh,
          child: Column(
            children: [
              // Header with title
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                // Search bar
                child: SearchWidget(
                  onChanged: _filterPurchases,
                ),
              ),
              const SizedBox(height: 12),

              // Purchases list
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _errorMessage != null
                        ? _buildErrorState()
                    : _filteredPurchases.isEmpty
                        ? _buildEmptyState()
                        : AnimationConfiguration.staggeredList(
                            position: 0,
                            delay: const Duration(milliseconds: 100),
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: _filteredPurchases.length,
                                  itemBuilder: (context, index) {
                                    final purchase = _filteredPurchases[index];
                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      delay: Duration(milliseconds: index * 50),
                                      duration: const Duration(milliseconds: 300),
                                      child: SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: PurchaseCard(purchase: purchase),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            SmoothPageRoute(
              builder: (_) => const CreatePurchasePage(),
              type: TransitionType.slide,
            ),
          );
          await _loadPurchases();
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading purchases...',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 50,
              color: AppColors.primary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Purchases Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first purchase order\nfrom a supplier',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: Colors.red.withValues(alpha: 0.75),
            ),
            const SizedBox(height: 14),
            const Text(
              'Unable to load purchases',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Please check your connection and try again.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadPurchases,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

}

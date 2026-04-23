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

  late List<Purchase> _purchases;
  List<Purchase> _filteredPurchases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPurchases();
  }

  Future<void> _loadPurchases() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 300)); // Simulate loading
    _purchases = _purchaseService.getPurchases();
    _filteredPurchases = List.from(_purchases);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      widget.onLoadingComplete?.call();
    }
  }

  void _filterPurchases(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPurchases = List.from(_purchases);
      });
    } else {
      setState(() {
        _filteredPurchases = _purchaseService.getPurchases(searchQuery: query);
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

}

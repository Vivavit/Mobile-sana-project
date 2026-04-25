import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/models/order_model.dart';
import 'package:mobile_camsme_sana_project/core/providers/order_provider.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/order_detail_page.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/order_status_badge.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/loading_states.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage>
    with TickerProviderStateMixin {
  late OrderProvider _orderProvider;
  late ScrollController _scrollController;
  late TabController _tabController;
  final List<String> _statusFilters = ['All', 'pending', 'processing', 'completed', 'cancelled'];

  @override
  void initState() {
    super.initState();
    _orderProvider = OrderProvider();
    _scrollController = ScrollController();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    
    _scrollController.addListener(_onScroll);
    _tabController.addListener(_onTabChanged);
    
    // Load initial orders
    _loadOrders();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreOrders();
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    
    final status = _tabController.index == 0 ? null : _statusFilters[_tabController.index];
    _loadOrders(status: status, refresh: true);
  }

  Future<void> _loadOrders({String? status, bool refresh = false}) async {
    await _orderProvider.fetchOrders(status: status, refresh: refresh);
    
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadMoreOrders() async {
    if (!_orderProvider.isLoading && _orderProvider.hasMore) {
      await _orderProvider.fetchOrders();
      
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _refreshOrders() async {
    final status = _tabController.index == 0 ? null : _statusFilters[_tabController.index];
    await _loadOrders(status: status, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).primaryColor,
          tabs: _statusFilters.map((status) => Tab(
            text: status == 'All' ? 'All' : status[0].toUpperCase() + status.substring(1),
          )).toList(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
          ),
        ],
      ),
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: TabBarView(
          controller: _tabController,
          children: _statusFilters.map((status) {
            return _buildOrderList(status == 'All' ? null : status);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderList(String? status) {
    final orders = _orderProvider.orders;
    final isLoading = _orderProvider.isLoading;
    final errorMessage = _orderProvider.errorMessage;

    if (errorMessage != null && orders.isEmpty) {
      return ErrorStateWidget(
        message: errorMessage,
        onRetry: () => _loadOrders(status: status, refresh: true),
      );
    }

    if (orders.isEmpty && !isLoading) {
      return EmptyStateWidget(
        title: 'No orders found',
        subtitle: status != null 
          ? 'You don\'t have any ${status.toLowerCase()} orders'
          : 'You haven\'t placed any orders yet',
        icon: Icons.inbox_outlined,
        action: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/create-order');
          },
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Create Order'),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter == 0) {
          _loadMoreOrders();
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: orders.length + (isLoading && orders.isNotEmpty ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orders.length) {
            return const PaginationLoadingWidget();
          }

          final order = orders[index];
          return OrderCard(
            order: order,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailPage(orderId: order.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
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
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.orderNumber,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(order.createdAt),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    OrderStatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.items.length} items',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                if (order.warehouse != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.warehouse!.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

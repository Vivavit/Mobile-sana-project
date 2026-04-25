import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/models/order_model.dart';
import 'package:mobile_camsme_sana_project/core/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _perPage = 15;
  String? _currentStatusFilter;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  String? get currentStatusFilter => _currentStatusFilter;

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset orders list and pagination
  void resetOrders() {
    _orders = [];
    _currentPage = 1;
    _hasMore = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// Fetch orders with pagination and optional status filter
  Future<void> fetchOrders({String? status, bool refresh = false}) async {
    if (refresh) {
      resetOrders();
      _currentStatusFilter = status;
    } else if (_isLoading || !_hasMore) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await OrderService.getMyOrders(
        page: _currentPage,
        perPage: _perPage,
        status: status ?? _currentStatusFilter,
      );

      if (refresh) {
        _orders = response.orders;
      } else {
        _orders.addAll(response.orders);
      }

      _hasMore = response.currentPage < response.lastPage;
      _currentPage++;

      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get single order details
  Future<Order?> getOrderDetail(int orderId) async {
    try {
      final order = await OrderService.getOrderDetail(orderId);
      
      // Update order in list if it exists
      final index = _orders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        _orders[index] = order;
        notifyListeners();
      }
      
      return order;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Create new order
  Future<bool> createOrder(CreateOrderRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newOrder = await OrderService.createOrder(request);
      
      // Add new order to the beginning of the list
      _orders.insert(0, newOrder);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Cancel order
  Future<bool> cancelOrder(int orderId) async {
    try {
      final updatedOrder = await OrderService.cancelOrder(orderId);
      
      // Update order in list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update order status (admin/staff only)
  Future<bool> updateOrderStatus(int orderId, String status) async {
    try {
      final updatedOrder = await OrderService.updateOrderStatus(orderId, status);
      
      // Update order in list
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index] = updatedOrder;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}

class OrderDetailProvider extends ChangeNotifier {
  Order? _order;
  bool _isLoading = false;
  String? _errorMessage;

  Order? get order => _order;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Fetch order details
  Future<void> fetchOrderDetail(int orderId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _order = await OrderService.getOrderDetail(orderId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancel current order
  Future<bool> cancelCurrentOrder() async {
    if (_order == null) return false;

    try {
      final updatedOrder = await OrderService.cancelOrder(_order!.id);
      _order = updatedOrder;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update current order status
  Future<bool> updateOrderStatus(String status) async {
    if (_order == null) return false;

    try {
      final updatedOrder = await OrderService.updateOrderStatus(_order!.id, status);
      _order = updatedOrder;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear order data
  void clearOrder() {
    _order = null;
    _errorMessage = null;
    notifyListeners();
  }
}

class CreateOrderProvider extends ChangeNotifier {
  List<CreateOrderItemRequest> _items = [];
  int? _selectedWarehouseId;
  String? _notes;
  bool _isLoading = false;
  String? _errorMessage;

  List<CreateOrderItemRequest> get items => _items;
  int? get selectedWarehouseId => _selectedWarehouseId;
  String? get notes => _notes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Select warehouse
  void selectWarehouse(int warehouseId) {
    _selectedWarehouseId = warehouseId;
    notifyListeners();
  }

  /// Update notes
  void updateNotes(String notes) {
    _notes = notes;
    notifyListeners();
  }

  /// Add item to order
  void addItem(CreateOrderItemRequest item) {
    // Check if item already exists
    final existingIndex = _items.indexWhere((i) => i.productId == item.productId);
    if (existingIndex != -1) {
      // Update quantity if item exists
      _items[existingIndex] = CreateOrderItemRequest(
        productId: item.productId,
        quantity: _items[existingIndex].quantity + item.quantity,
        price: item.price,
      );
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  /// Update item quantity
  void updateItemQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final index = _items.indexWhere((i) => i.productId == productId);
    if (index != -1) {
      _items[index] = CreateOrderItemRequest(
        productId: productId,
        quantity: quantity,
        price: _items[index].price,
      );
      notifyListeners();
    }
  }

  /// Remove item from order
  void removeItem(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  /// Clear all items
  void clearItems() {
    _items.clear();
    notifyListeners();
  }

  /// Create order
  Future<bool> createOrder() async {
    if (_selectedWarehouseId == null) {
      _errorMessage = 'Please select a warehouse';
      notifyListeners();
      return false;
    }

    if (_items.isEmpty) {
      _errorMessage = 'Please add at least one item';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = CreateOrderRequest(
        warehouseId: _selectedWarehouseId!,
        items: _items,
        notes: _notes,
      );

      await OrderService.createOrder(request);
      
      // Clear form after successful creation
      _items.clear();
      _notes = null;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset form
  void resetForm() {
    _items.clear();
    _selectedWarehouseId = null;
    _notes = null;
    _errorMessage = null;
    notifyListeners();
  }
}

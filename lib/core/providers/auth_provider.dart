import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/services/auth_service.dart';
import 'package:mobile_camsme_sana_project/core/services/secure_storage_service.dart';
import 'package:mobile_camsme_sana_project/core/services/session.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _token;
  String? _warehouseId;
  String? _userName;
  String? _userEmail;
  String? _userPhone;
  List<String>? _permissions;
  int? _userId;
  String? _userType;
  String? _errorMessage;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get warehouseId => _warehouseId;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get userPhone => _userPhone;
  List<String>? get permissions => _permissions;
  int? get userId => _userId;
  String? get userType => _userType;
  String? get errorMessage => _errorMessage;

  // Role getters
  bool get isAdmin => _userType == 'admin';
  bool get isStaff => _userType == 'staff';
  bool get isGuest => _userType == 'guest';

  // Permission getters
  bool get canManageInventory => _permissions?.contains('manage-inventory') ?? false;
  bool get canViewAnalytics => _permissions?.contains('view-analytics') ?? false;
  bool get canCheckout => _permissions?.contains('checkout') ?? false;
  bool get canManageProducts => _permissions?.contains('manage-products') ?? false;
  bool get canManageOrders => _permissions?.contains('manage-orders') ?? false;

  /// Initialize auth state from storage
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await SecureStorageService.getToken();
      final warehouseId = await SecureStorageService.getWarehouseId();
      final userName = await SecureStorageService.getUserName();
      final userEmail = await SecureStorageService.getUserEmail();
      final userPhone = await SecureStorageService.getUserPhone();
      final permissions = await SecureStorageService.getPermissions();
      final userId = await SecureStorageService.getUserId();
      final userType = await SecureStorageService.getUserType();

      _token = token;
      _warehouseId = warehouseId;
      _userName = userName;
      _userEmail = userEmail;
      _userPhone = userPhone;
      _permissions = permissions;
      _userId = userId;
      _userType = userType;
      _isLoggedIn = token != null && warehouseId != null;

      // Update Session for backward compatibility
      Session.token = token;
      Session.warehouseId = warehouseId;
      Session.userName = userName;
      Session.userEmail = userEmail;
      Session.userPhone = userPhone;
      Session.permissions = permissions;
      Session.userId = userId;
      Session.userType = userType;

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to initialize auth: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Login user and update state
  Future<bool> login({
    required String token,
    required String warehouseId,
    String? userName,
    String? userEmail,
    String? userPhone,
    List<String>? permissions,
    int? userId,
    String? userType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Save to secure storage
      await AuthService.saveLoginData(
        token,
        warehouseId,
        '', // warehouseName not needed for this
        userName: userName,
        userEmail: userEmail,
        userPhone: userPhone,
        permissions: permissions,
        userType: userType,
      );

      // Update state
      _token = token;
      _warehouseId = warehouseId;
      _userName = userName;
      _userEmail = userEmail;
      _userPhone = userPhone;
      _permissions = permissions;
      _userId = userId;
      _userType = userType;
      _isLoggedIn = true;

      // Update Session for backward compatibility
      Session.token = token;
      Session.warehouseId = warehouseId;
      Session.userName = userName;
      Session.userEmail = userEmail;
      Session.userPhone = userPhone;
      Session.permissions = permissions;
      Session.userId = userId;
      Session.userType = userType;

      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout user and clear state
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Clear secure storage
      await AuthService.logout();

      // Clear state
      _token = null;
      _warehouseId = null;
      _userName = null;
      _userEmail = null;
      _userPhone = null;
      _permissions = null;
      _userId = null;
      _userType = null;
      _isLoggedIn = false;
      _errorMessage = null;

      // Clear Session for backward compatibility
      Session.clear();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user info (for profile updates)
  void updateUserInfo({
    String? userName,
    String? userEmail,
    String? userPhone,
  }) {
    if (userName != null) _userName = userName;
    if (userEmail != null) _userEmail = userEmail;
    if (userPhone != null) _userPhone = userPhone;

    // Update Session for backward compatibility
    Session.userName = _userName;
    Session.userEmail = _userEmail;
    Session.userPhone = _userPhone;

    notifyListeners();
  }

  /// Update warehouse
  void updateWarehouse(String? warehouseId) {
    _warehouseId = warehouseId;
    Session.warehouseId = warehouseId;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Check if user has specific permission
  bool hasPermission(String permission) {
    return _permissions?.contains(permission) ?? false;
  }

  /// Get user display name
  String get displayName => _userName ?? _userEmail ?? 'User';

  /// Debug method to print current state
  void debugPrintState() {
    debugPrint('=== AuthProvider State ===');
    debugPrint('isLoggedIn: $_isLoggedIn');
    debugPrint('userType: $_userType');
    debugPrint('isAdmin: $isAdmin');
    debugPrint('isStaff: $isStaff');
    debugPrint('userName: $_userName');
    debugPrint('userId: $_userId');
    debugPrint('permissions: $_permissions');
    debugPrint('========================');
  }
}

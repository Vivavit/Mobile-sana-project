class Session {
  static String? token;
  static String? warehouseId;
  static String? userName;
  static String? userEmail;
  static String? userPhone;
  static List<String>? permissions;
  static int? userId;
  static String? userType;
  static int? defaultWarehouseId;

  // Clear all session data
  static void clear() {
    token = null;
    warehouseId = null;
    userName = null;
    userEmail = null;
    userPhone = null;
    permissions = null;
    userId = null;
    userType = null;
    defaultWarehouseId = null;
  }

  // Check if user has a specific permission
  static bool hasPermission(String permission) {
    return permissions?.contains(permission) ?? false;
  }

  // Check if user can manage inventory
  static bool get canManageInventory => hasPermission('manage-inventory');

  // Check if user can view analytics
  static bool get canViewAnalytics => hasPermission('view-analytics');

  // Check if user can checkout
  static bool get canCheckout => hasPermission('checkout');

  // Check if user is admin
  static bool get isAdmin => userType == 'admin';

  // Check if user is staff
  static bool get isStaff => userType == 'staff';
}

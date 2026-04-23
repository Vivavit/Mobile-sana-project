import 'package:mobile_camsme_sana_project/core/services/session.dart';

class PermissionChecker {
  /// Check if user has a specific permission
  static bool hasPermission(String permission) {
    return Session.permissions?.contains(permission) ?? false;
  }

  /// Check if user can manage products (admin)
  static bool canManageProducts() {
    return hasPermission('manage-products');
  }

  /// Check if user can do checkout (staff)
  static bool canCheckout() {
    return hasPermission('checkout');
  }
}

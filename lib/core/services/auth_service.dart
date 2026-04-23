import 'package:mobile_camsme_sana_project/core/services/secure_storage_service.dart';
import 'package:mobile_camsme_sana_project/core/services/session.dart';

class AuthService {
  static Future<void> saveLoginData(
    String token,
    String warehouseId,
    String warehouseName, {
    String? userName,
    String? userEmail,
    String? userPhone,
    List<String>? permissions,
  }) async {
    await SecureStorageService.saveAuthData(
      token: token,
      warehouseId: warehouseId,
      warehouseName: warehouseName,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
      permissions: permissions,
    );

    Session.token = token;
    Session.warehouseId = warehouseId;
    Session.userName = userName;
    Session.userEmail = userEmail;
    Session.userPhone = userPhone;
    Session.permissions = permissions;
  }

  static Future<bool> isLoggedIn() async {
    final token = await SecureStorageService.getToken();
    final warehouseId = await SecureStorageService.getWarehouseId();

    Session.token = token;
    Session.warehouseId = warehouseId;
    Session.userName = await SecureStorageService.getUserName();
    Session.userEmail = await SecureStorageService.getUserEmail();
    Session.userPhone = await SecureStorageService.getUserPhone();

    return token != null && warehouseId != null;
  }

  static Future<void> logout() async {
    await SecureStorageService.clearAll();

    Session.token = null;
    Session.warehouseId = null;
    Session.userName = null;
    Session.userEmail = null;
    Session.userPhone = null;
  }

  static Future<String?> getWarehouseId() async {
    return await SecureStorageService.getWarehouseId();
  }

  static Future<String?> getWarehouseName() async {
    return await SecureStorageService.getWarehouseName();
  }
}

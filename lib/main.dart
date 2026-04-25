import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/providers/auth_provider.dart';
import 'package:mobile_camsme_sana_project/core/services/api_service.dart';
import 'package:mobile_camsme_sana_project/core/services/auth_service.dart';
import 'package:mobile_camsme_sana_project/core/services/secure_storage_service.dart';
import 'package:mobile_camsme_sana_project/core/services/session.dart';
import 'package:mobile_camsme_sana_project/route/app_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API service with caching
  await ApiService.initialize();

  await _initializeSession();
  await AuthService.isLoggedIn();

  runApp(MyApp());
}

Future<void> _initializeSession() async {
  try {
    final token = await SecureStorageService.getToken();
    final warehouseId = await SecureStorageService.getWarehouseId();

    Session.token = token;
    Session.warehouseId = warehouseId;

    debugPrint('=== Session Initialized ===');
    debugPrint('Token loaded: ${Session.token != null ? "YES" : "NO"}');
    debugPrint('Warehouse ID: ${Session.warehouseId}');
    debugPrint('===========================');
  } catch (e) {
    debugPrint('Error initializing session: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: AppRoute.routes,
        initialRoute: '/',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            onPrimary: Colors.white,
            onSecondary: AppColors.text,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: AppColors.text),
            bodyMedium: TextStyle(color: AppColors.text),
            bodySmall: TextStyle(color: AppColors.text),
          ),
        ),
      ),
    );
  }
}

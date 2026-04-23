import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/analytic_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/home_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/inventory_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/login_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/main_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/setting/privacy_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/setting/profile_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/setting/terms_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/setting_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/welcome_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/admin/product_list_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/admin/product_form_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/admin/product_detail_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/purchases/purchase_list_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/purchases/create_purchase_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/purchases/purchase_detail_page.dart';

class AppRoute {
  static Map<String, WidgetBuilder> routes = {
    '/home': (_) => HomePage(),
    '/login': (_) => LoginPage(),
    '/setting': (_) => SettingPage(),
    '/inventory': (_) => InventoryPage(),
    '/analytic': (_) => AnalyticPage(),
    '/term': (_) => TermsPage(),
    '/profile': (_) => ProfilePage(currentName: ''),
    '/privacy': (_) => PrivacyPage(),
    '/': (_) => const WelcomePage(),
    '/main': (_) => MainPage(),
    // Admin routes
    '/admin/products': (_) => const ProductListPage(),
    '/admin/products/create': (_) => const ProductFormPage(),
    '/admin/products/edit': (ctx) => ProductFormPage(
          productId: ModalRoute.of(ctx)!.settings.arguments as int?,
        ),
    '/admin/products/detail': (ctx) => ProductDetailPage(
          productId: ModalRoute.of(ctx)!.settings.arguments as int,
        ),
    // Purchase routes
    '/purchases': (_) => const PurchaseListPage(),
    '/purchases/create': (_) => const CreatePurchasePage(),
    '/purchases/detail': (ctx) => PurchaseDetailPage(
          purchaseId: ModalRoute.of(ctx)!.settings.arguments as int,
        ),
  };
}

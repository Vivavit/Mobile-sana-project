import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/analytic_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/home_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/inventory_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/login_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/main_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/setting_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/welcome_page.dart';

class AppRoute {
  static Map<String, WidgetBuilder> routes = {
    '/home': (_) => HomePage(),
    '/login': (_) => LoginPage(),
    '/setting': (_) => SettingPage(),
    '/inventory': (_) => InventoryPage(),
    '/analytic': (_) => AnalyticPage(),
    '/': (_) => MainPage(),
    '/welcome': (_) => WelcomePage(),

    
  };
}
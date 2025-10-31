import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/analytic_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/home_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/inventory_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/setting_page.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/app_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    AnalyticPage(),
    InventoryPage(),
    SettingPage(),
  ];

  final List<String> _titles = [
    'Hello, YamYam',
    'Analytics',
    'Inventory',
    'Setting',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [ScrollHideAppBar(title: _titles[currentPageIndex])];
        },
        body: _pages[currentPageIndex],
      ),

      // bottom nav bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((
                states,
              ) {
                if (states.contains(MaterialState.selected)) {
                  return const TextStyle(color: Colors.white);
                }
                return const TextStyle(color: Colors.white70);
              }),
            ),
            child: NavigationBar(
              backgroundColor: AppColors.primary,
              height: 70,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              indicatorColor: AppColors.text,
              selectedIndex: currentPageIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.home, color: Colors.white),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.analytics_outlined, color: Colors.grey),
                  selectedIcon: Icon(
                    Icons.analytics_outlined,
                    color: Colors.white,
                  ),
                  label: 'Analytics',
                ),
                NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined, color: Colors.grey),
                  selectedIcon: Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white,
                  ),
                  label: 'Inventory',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.settings, color: Colors.white),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

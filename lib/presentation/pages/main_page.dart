import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/services/session.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/analytic_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/home_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/inventory_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/admin/product_list_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/purchases/purchase_list_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/setting_page.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/app_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPageIndex = 0;
  int selectedIndex = 0;
  String _userName = 'User';

  // Icon data for tabs (outlined = unselected, filled = selected)
  final List<Map<String, IconData>> _tabIcons = const [
    {'outlined': Icons.home_outlined, 'filled': Icons.home},
    {'outlined': Icons.analytics_outlined, 'filled': Icons.analytics},
    {'outlined': Icons.inventory_2_outlined, 'filled': Icons.inventory_2},
    {'outlined': Icons.settings_outlined, 'filled': Icons.settings},
  ];

  final List<String> _tabLabels = const [
    'Home',
    'Analytics',
    'Inventory',
    'Settings',
  ];

  // Staff navigation destinations (no FAB, simpler layout)
  final List<NavigationDestination> _staffDestinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined, color: Colors.grey),
      selectedIcon: Icon(Icons.home, color: Colors.white),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.analytics_outlined, color: Colors.grey),
      selectedIcon: Icon(Icons.analytics, color: Colors.white),
      label: 'Analytics',
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined, color: Colors.grey),
      selectedIcon: Icon(Icons.inventory_2, color: Colors.white),
      label: 'Inventory',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined, color: Colors.grey),
      selectedIcon: Icon(Icons.settings, color: Colors.white),
      label: 'Settings',
    ),
  ];

  bool get isAdmin => Session.isAdmin;

  List<Widget> get _pages {
    return [
      HomePage(onLoadingComplete: _pageLoadingComplete),
      AnalyticPage(onLoadingComplete: _pageLoadingComplete),
      InventoryPage(onLoadingComplete: _pageLoadingComplete),
      SettingPage(onLoadingComplete: _pageLoadingComplete),
    ];
  }

  String _getAppBarTitle() {
    final titles = ['Hello', 'Analytics', 'Inventory', 'Settings'];
    return selectedIndex < titles.length ? titles[selectedIndex] : '';
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    debugPrint('=== DEBUG INFO ===');
    debugPrint('Session.userType: ${Session.userType}');
    debugPrint('Session.isAdmin: ${Session.isAdmin}');
    debugPrint('Session.userName: ${Session.userName}');
    debugPrint('==================');
    
    setState(() {
      _userName = Session.userName ?? 'User';
    });
  }

  void _pageLoadingComplete() {}

  Widget get _currentPage => _pages[currentPageIndex];

  void _onPageChanged(int index) {
    if (currentPageIndex == index) return;
    setState(() {
      selectedIndex = index;
      currentPageIndex = index;
    });
  }

  void _showManagementHub() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Management Hub',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildManagementOption(
                    icon: Icons.inventory_2,
                    label: 'Products',
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductListPage(),
                        ),
                      );
                    },
                  ),
                  _buildManagementOption(
                    icon: Icons.shopping_cart,
                    label: 'Purchases',
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PurchaseListPage(
                            onLoadingComplete: _pageLoadingComplete,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildManagementOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building MainPage - isAdmin: $isAdmin');
    return Scaffold(
      extendBody: true,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            ScrollHideAppBar(title: _getAppBarTitle(), userName: _userName),
          ];
        },
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _currentPage,
        ),
      ),
      // Only show FAB for admin users
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _showManagementHub,
              backgroundColor: const Color(0xFFFFD700), // Gold color
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // Conditional bottom navigation bar
      bottomNavigationBar: isAdmin ? _buildAdminNavBar() : _buildStaffNavBar(),
    );
  }

  // Admin Navigation Bar with FAB notch
  Widget _buildAdminNavBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(0),
                  _buildNavItem(1),
                ],
              ),
            ),
            const SizedBox(width: 48),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(2),
                  _buildNavItem(3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Staff Navigation Bar (original style, no FAB)
  Widget _buildStaffNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
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
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(color: Colors.white);
              }
              return const TextStyle(color: Colors.white70);
            }),
          ),
          child: NavigationBar(
            backgroundColor: AppColors.primary,
            height: 70,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            indicatorColor: AppColors.text,
            selectedIndex: selectedIndex,
            onDestinationSelected: _onPageChanged,
            destinations: _staffDestinations,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => _onPageChanged(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? _tabIcons[index]['filled']! : _tabIcons[index]['outlined']!,
              color: isSelected ? Colors.white : Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 2),
            FittedBox(
              child: Text(
                _tabLabels[index],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/providers/auth_provider.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/analytic_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/home_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/inventory_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/admin/product_list_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/purchases/purchase_list_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/order_list_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/setting_page.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/app_bar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int currentPageIndex = 0;
  int selectedIndex = 0;
  late AnimationController _fabController;

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

  // Staff navigation destinations
  final List<NavigationDestination> _staffDestinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.analytics_outlined),
      selectedIcon: Icon(Icons.analytics),
      label: 'Analytics',
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2),
      label: 'Inventory',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  String _getAppBarTitle() {
    final titles = ['Hello', 'Analytics', 'Inventory', 'Settings'];
    return selectedIndex < titles.length ? titles[selectedIndex] : '';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      authProvider.initialize().then((_) {
        authProvider.debugPrintState();
      });
    });
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Header with icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.dashboard_customize_outlined,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Management Hub',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Management Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildManagementOption(
                      icon: Icons.inventory_2_outlined,
                      label: 'Products',
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductListPage()),
                        );
                      },
                    ),
                    _buildManagementOption(
                      icon: Icons.shopping_cart_outlined,
                      label: 'Purchases',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PurchaseListPage(
                              onLoadingComplete: _pageLoadingComplete,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: color.withOpacity(0.15), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 42),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> get _pages {
    return [
      HomePage(onLoadingComplete: _pageLoadingComplete),
      AnalyticPage(onLoadingComplete: _pageLoadingComplete),
      InventoryPage(onLoadingComplete: _pageLoadingComplete),
      SettingPage(onLoadingComplete: _pageLoadingComplete),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          extendBody: true,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                ScrollHideAppBar(title: _getAppBarTitle(), userName: authProvider.displayName),
              ];
            },
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _currentPage,
            ),
          ),
          // Custom Speed Dial FAB - Reactive to auth state
          floatingActionButton: authProvider.isAdmin
              ? _CustomSpeedDial(
                  mainFABIcon: Icons.add,
                  mainFABColor: AppColors.primary,
                  closeFABColor: AppColors.primary,
                  children: [
                    _SpeedDialChild(
                      icon: Icons.inventory_2_outlined,
                      backgroundColor: Colors.white,
                      iconColor: AppColors.primary,
                      label: 'Products',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProductListPage()),
                        );
                      },
                    ),
                    _SpeedDialChild(
                      icon: Icons.shopping_cart_outlined,
                      backgroundColor: Colors.white,
                      iconColor: Colors.green,
                      label: 'Purchases',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PurchaseListPage(
                              onLoadingComplete: _pageLoadingComplete,
                            ),
                          ),
                        );
                      },
                    ),
                    _SpeedDialChild(
                      icon: Icons.receipt_long_outlined,
                      backgroundColor: Colors.white,
                      iconColor: Colors.purple,
                      label: 'Orders',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const OrderListPage()),
                        );
                      },
                    ),
                  ],
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          // Conditional bottom navigation - Reactive to auth state
          bottomNavigationBar: authProvider.isAdmin ? _buildAdminNavBar() : _buildStaffNavBar(),
        );
      },
    );
  }

  // Improved Admin Navigation Bar
  Widget _buildAdminNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        color: AppColors.primary,
        elevation: 0,
        height: 64,                          // ← explicit height
        padding: EdgeInsets.zero,            // ← kill default internal padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAdminNavItem(0),
                  _buildAdminNavItem(1),
                ],
              ),
            ),
            const SizedBox(width: 72),       // space for FAB
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAdminNavItem(2),
                  _buildAdminNavItem(3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Improved Staff Navigation Bar
  Widget _buildStaffNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                );
              }
              return const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                fontSize: 11,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Colors.white, size: 26);
              }
              return const IconThemeData(color: Colors.white70, size: 24);
            }),
          ),
          child: NavigationBar(
            backgroundColor: AppColors.primary,
            height: 76,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            indicatorColor: Colors.white.withOpacity(0.2),
            selectedIndex: selectedIndex,
            onDestinationSelected: _onPageChanged,
            destinations: _staffDestinations,
          ),
        ),
      ),
    );
  }

  // Enhanced Admin Nav Item
  Widget _buildAdminNavItem(int index) {
    final isSelected = selectedIndex == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onPageChanged(index),
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 250),
                scale: isSelected ? 1.15 : 1.0,
                child: Icon(
                  isSelected
                      ? _tabIcons[index]['filled']!
                      : _tabIcons[index]['outlined']!,
                  color: isSelected ? Colors.white : Colors.white70,
                  size: 22,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedOpacity(
                opacity: isSelected ? 1.0 : 0.7,
                duration: const Duration(milliseconds: 250),
                child: Text(
                  _tabLabels[index],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.white70,
                  ),
                ),
              ),
              // Active indicator — only shown when selected, no extra SizedBox padding
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  width: 18,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomSpeedDial extends StatefulWidget {
  final IconData mainFABIcon;
  final Color mainFABColor;
  final Color closeFABColor;
  final List<_SpeedDialChild> children;

  const _CustomSpeedDial({
    required this.mainFABIcon,
    required this.mainFABColor,
    required this.closeFABColor,
    required this.children,
  });

  @override
  State<_CustomSpeedDial> createState() => _CustomSpeedDialState();
}

class _CustomSpeedDialState extends State<_CustomSpeedDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    _animationController.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggle() {
    if (_isOpen) {
      _animationController.reverse().then((_) {
        _removeOverlay();
        if (mounted) setState(() => _isOpen = false);
      });
    } else {
      setState(() => _isOpen = true);
      _overlayEntry = _buildOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
      _animationController.forward();
    }
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: Stack(
            children: [
              // Tap outside to close
              GestureDetector(
                onTap: _toggle,
                behavior: HitTestBehavior.translucent,
                child: Container(color: Colors.transparent),
              ),
              // Menu anchored above the FAB
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(-72, -(widget.children.length * 64.0 + 16)),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.15),
                      end: Offset.zero,
                    ).animate(_fadeAnimation),
                    child: SizedBox(
                      width: 200,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: widget.children.reversed.map((child) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _buildSpeedDialItem(child),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpeedDialItem(_SpeedDialChild child) {
    return GestureDetector(
      onTap: () {
        _toggle();
        child.onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: child.iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(child.icon, color: child.iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              child.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: FloatingActionButton(
        onPressed: _toggle,
        backgroundColor: _isOpen ? widget.closeFABColor : widget.mainFABColor,
        elevation: 6,
        shape: const CircleBorder(),
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 250),
          turns: _isOpen ? 0.125 : 0,
          child: Icon(
            _isOpen ? Icons.close : widget.mainFABIcon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _SpeedDialChild {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _SpeedDialChild({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });
}

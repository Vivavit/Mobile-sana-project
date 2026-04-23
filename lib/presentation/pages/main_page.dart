import 'package:flutter/material.dart';
import 'package:mobile_camsme_sana_project/core/constants/app_color.dart';
import 'package:mobile_camsme_sana_project/core/services/user_service.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/analytic_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/home_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/inventory_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/admin/product_list_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/purchases/purchase_list_page.dart';
import 'package:mobile_camsme_sana_project/presentation/pages/setting_page.dart';
import 'package:mobile_camsme_sana_project/presentation/widgets/app_bar.dart';
import 'dart:async';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  int currentPageIndex = 0;
  int selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;
  late Completer<void> _pageLoadingCompleter;
  String _userName = 'User';

  List<Widget> get _pages {
    return [
      HomePage(onLoadingComplete: _pageLoadingComplete),
      AnalyticPage(onLoadingComplete: _pageLoadingComplete),
      InventoryPage(onLoadingComplete: _pageLoadingComplete),
      PurchaseListPage(onLoadingComplete: _pageLoadingComplete),
      ProductListPage(),
      SettingPage(onLoadingComplete: _pageLoadingComplete),
    ];
  }

  String _getAppBarTitle() {
    final titles = ['Hello', 'Analytics', 'Inventory', 'Purchases', 'Products', 'Settings'];
    if (selectedIndex < titles.length) {
      return titles[selectedIndex];
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _pageLoadingCompleter = Completer();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final user = await UserService.getCurrentUser();
      if (mounted && user != null) {
        setState(() {
          _userName = user.name;
        });
      }
    } catch (e) {
      debugPrint('Failed to load user: $e');
    }
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideAnim = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(0, -0.1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: Offset.zero,
          end: const Offset(0, 0.1),
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Opacity animation: fade in → fade out
    _opacityAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  void _startLoaderAnimation() {
    _controller.repeat();
  }

  void _pageLoadingComplete() {
    if (!_pageLoadingCompleter.isCompleted) {
      _pageLoadingCompleter.complete();
    }
  }

  Widget get _loader => Container(
    color: Colors.white,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _opacityAnim,
              child: Image.asset('asset/image/logo.png', height: 150),
            ),
          ),
          const SizedBox(height: 40),
          SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _opacityAnim,
              child: Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          SlideTransition(
            position: _slideAnim,
            child: FadeTransition(
              opacity: _opacityAnim,
              child: SizedBox(
                width: 200,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        color: AppColors.primary,
                        backgroundColor: Color(0xFFE0E0E0),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget get _currentPage {
    if (currentPageIndex == -1) return _loader;
    return _pages[currentPageIndex];
  }

  void _onPageChanged(int index) async {
    if (currentPageIndex == index) return;

    setState(() {
      selectedIndex = index;
      currentPageIndex = -1;
    });

    _pageLoadingCompleter = Completer();
    _startLoaderAnimation();

    try {
      await _pageLoadingCompleter.future.timeout(const Duration(seconds: 5));
    } on TimeoutException catch (e) {
      debugPrint('Page loading timeout - forcing completion: $e');
      // Complete it manually if it timed out
      if (!_pageLoadingCompleter.isCompleted) {
        _pageLoadingCompleter.complete();
      }
    } catch (e) {
      debugPrint('Page loading error: $e');
    }

    if (mounted) {
      setState(() {
        currentPageIndex = index;
      });
      _controller.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            if (currentPageIndex != -1)
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
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((
                states,
              ) {
                if (states.contains(WidgetState.selected)) {
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
              selectedIndex: selectedIndex,
              onDestinationSelected: _onPageChanged,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.home, color: Colors.white),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.analytics_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.analytics, color: Colors.white),
                  label: 'Analytics',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.inventory_2_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.inventory_2, color: Colors.white),
                  label: 'Inventory',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.shopping_cart_outlined, color: Colors.grey),
                  selectedIcon: Icon(Icons.shopping_cart, color: Colors.white),
                  label: 'Buy',
                ),
                const NavigationDestination(
                  icon: Icon(
                    Icons.production_quantity_limits_outlined,
                    color: Colors.grey,
                  ),
                  selectedIcon: Icon(
                    Icons.production_quantity_limits,
                    color: Colors.white,
                  ),
                  label: 'Products',
                ),
                const NavigationDestination(
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

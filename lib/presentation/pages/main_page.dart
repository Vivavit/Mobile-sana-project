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

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  int currentPageIndex = 0;
  int selectedIndex = 0;
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;

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
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Slide animation: from top → center → slightly down
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
    _controller.reset();
    _controller.forward();
  }

  Widget get _loader => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo
        SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _opacityAnim,
            child: Image.asset('asset/image/logo.png', height: 150),
          ),
        ),
        const SizedBox(height: 25),
        // Progress bar
        SlideTransition(
          position: _slideAnim,
          child: FadeTransition(
            opacity: _opacityAnim,
            child: const LinearProgressIndicator(
              color: AppColors.primary,
              backgroundColor: Colors.white24,
              minHeight: 3,
            ),
          ),
        ),
      ],
    ),
  );

  Widget get _currentPage {
    if (currentPageIndex == -1) return _loader;
    return _pages[currentPageIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            ScrollHideAppBar(
              title: currentPageIndex == -1 ? '' : _titles[currentPageIndex],
            ),
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
              selectedIndex: selectedIndex,
              onDestinationSelected: (int index) async {
                if (currentPageIndex == index) return;

                setState(() {
                  selectedIndex = index;
                  currentPageIndex = -1;
                });

                _startLoaderAnimation(); // 🔥 Trigger smooth 3-phase logo animation

                await Future.delayed(const Duration(milliseconds: 1000));

                if (mounted) {
                  setState(() {
                    currentPageIndex = index;
                  });
                }
              },
              destinations: const [
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

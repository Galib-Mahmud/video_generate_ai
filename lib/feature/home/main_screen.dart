import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hussein/feature/home/screen/app_drawer_controller.dart';
import 'package:hussein/feature/home/screen/app_drawer_screen.dart';

import '../profile/screen/profile_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  // ✅ Static getter so child screens can access navbar height for bottom padding
  static double get navBarHeight => 120.h;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 3;

  late AnimationController _drawerController;
  late Animation<double> _drawerAnimation;
  bool _isDrawerOpen = false;

  final AppDrawerController _appDrawerCtrl = Get.put(AppDrawerController());

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _drawerAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _drawerController, curve: Curves.easeOutCubic),
    );

    _appDrawerCtrl.setDrawerFunctions(
      open: _openDrawer,
      close: _closeDrawer,
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    _drawerController.forward();
    setState(() {
      _isDrawerOpen = true;
    });
  }

  void _closeDrawer() {
    _drawerController.reverse().then((_) {
      setState(() {
        _isDrawerOpen = false;
      });
    });
  }

  final List<Widget> _pages = [
ProfileScreen(),
ProfileScreen(),
ProfileScreen(),
ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 8 && !_isDrawerOpen) {
          _openDrawer();
        }
        if (details.delta.dx < -8 && _isDrawerOpen) {
          _closeDrawer();
        }
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            // Main Content - NO wrapper, screens handle their own bottom padding
            _pages[_currentIndex],

            // Bottom Navigation Bar (floating)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavigationBar(),
            ),

            // Overlay when drawer is open
            if (_isDrawerOpen)
              AnimatedBuilder(
                animation: _drawerController,
                builder: (context, child) {
                  return GestureDetector(
                    onTap: _closeDrawer,
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx < -8) {
                        _closeDrawer();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black.withOpacity(
                        0.5 * _drawerController.value,
                      ),
                    ),
                  );
                },
              ),

            // Drawer
            AnimatedBuilder(
              animation: _drawerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _drawerAnimation.value * 280.w,
                    0,
                  ),
                  child: child,
                );
              },
              child: CustomDrawer(
                onClose: _closeDrawer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 78.h,
            decoration: BoxDecoration(
              color: const Color(0xFF0D0620),
              borderRadius: BorderRadius.circular(40.r),
              border: Border.all(
                color: const Color(0xFF1E1535),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: const Color(0xFF4EFFEE).withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(width: 20.w),
                _buildNavItem(
                  iconPath: 'assets/images/avatar/Orbit.png',
                  label: 'Orbit',
                  index: 0,
                ),
                SizedBox(width: 20.w),
                _buildNavItem(
                  iconPath: 'assets/images/avatar/layer_1.png',
                  label: 'SOS',
                  index: 1,
                ),
                SizedBox(width: 70.w),
                _buildNavItem(
                  iconPath: 'assets/images/avatar/Journal.png',
                  label: 'Journal',
                  index: 2,
                ),
                _buildNavItem(
                  iconPath: 'assets/images/avatar/dash.png',
                  label: 'Dashboard',
                  index: 3,
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String iconPath,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() {
        _currentIndex = index;

      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 24.w,
              height: 24.h,
              color: isSelected
                  ? const Color(0xFF4EFFEE)
                  : Colors.white.withOpacity(0.4),
            ),
            SizedBox(height: 7.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF4EFFEE)
                    : Colors.white.withOpacity(0.4),
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
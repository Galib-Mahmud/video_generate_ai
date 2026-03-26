import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hussein/feature/home/screen/app_drawer_controller.dart';
import 'package:hussein/feature/home/screen/app_drawer_screen.dart';
import 'package:hussein/feature/home/screen/generate_video.dart';
import 'package:hussein/feature/home/screen/home1.dart';
import 'package:hussein/feature/home/screen/home_screen.dart';
import 'package:hussein/feature/home/screen/video_screen.dart';
import '../color/app_color.dart';
import '../profile/screen/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  static double get navBarHeight => 90.h;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

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
    setState(() => _isDrawerOpen = true);
  }

  void _closeDrawer() {
    _drawerController.reverse().then((_) {
      setState(() => _isDrawerOpen = false);
    });
  }

  final List<Widget> _pages = [
    Home1(),
    HomeScreen(),
    YourVideosScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 8 && !_isDrawerOpen) _openDrawer();
        if (details.delta.dx < -8 && _isDrawerOpen) _closeDrawer();
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            _pages[_currentIndex],

            // Bottom Navigation Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomNavigationBar(),
            ),

            // Dim overlay when drawer is open
            if (_isDrawerOpen)
              AnimatedBuilder(
                animation: _drawerController,
                builder: (context, child) {
                  return GestureDetector(
                    onTap: _closeDrawer,
                    onHorizontalDragUpdate: (details) {
                      if (details.delta.dx < -8) _closeDrawer();
                    },
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black
                          .withOpacity(0.5 * _drawerController.value),
                    ),
                  );
                },
              ),

            // Drawer slide-in
            AnimatedBuilder(
              animation: _drawerAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_drawerAnimation.value * 280.w, 0),
                  child: child,
                );
              },
              child: CustomDrawer(onClose: _closeDrawer),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(
        top: 14.h,
        bottom: MediaQuery.of(context).padding.bottom + 10.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(
            iconPath: 'assets/images/home/home.png',
            label: 'Home',
            index: 0,
          ),_buildNavItem(
            iconPath: 'assets/images/home/generate.png',
            label: 'Generate',
            index: 1,
          ),
          _buildNavItem(
            iconPath: 'assets/images/home/video.png',
            label: 'Videos',
            index: 2,
          ),
          _buildNavItem(
            iconPath: 'assets/images/home/profile.png',
            label: 'Profile',
            index: 3,
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
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon: gradient tint when selected, dim white when not
            isSelected
                ? ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.textGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Image.asset(
                iconPath,
                width: 26.w,
                height: 26.h,
                color: Colors.white,
              ),
            )
                : Image.asset(
              iconPath,
              width: 26.w,
              height: 26.h,
              color: Colors.white.withOpacity(0.45),
            ),

            SizedBox(height: 6.h),

            // Label: gradient when selected, dim when not
            isSelected
                ? ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.textGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
                : Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }


}
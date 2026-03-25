import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../color/app_color.dart';
import '../controller/profile_controller.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onClose;

  const CustomDrawer({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260.w,
      height: double.infinity,
      color: const Color(0xFF080808),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            // ── Hamburger icon (acts as close) ─────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: GestureDetector(
                onTap: onClose,
                behavior: HitTestBehavior.opaque,
                child: Image.asset(
                  'assets/icons/drawer/menu.png',
                  width: 24.w,
                  height: 24.w,
                  color: Colors.white,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.menu,
                    color: Colors.white,
                    size: 24.w,
                  ),
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // ── Menu Items ──────────────────────────────────────
            _buildMenuItem(
              iconPath: 'assets/images/drawer/profile.png',
              label: 'Profile',
              onTap: () {Get.toNamed('/profile');},
            ),
            _buildMenuItem(
              iconPath: 'assets/images/drawer/subscribe.png',
              label: 'Subscription',
              onTap: () {Get.toNamed('/subscribe');},
            ),
            _buildMenuItem(
              iconPath: 'assets/images/drawer/privacy.png',
              label: 'Privacy policy',
              onTap: () {Get.toNamed('/privacy');},
            ),

            const Spacer(),

            // ── Log out ─────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      final profile = Get.put(ProfileController());
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF1A1A1A),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                            side: BorderSide(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          title: Text(
                            'Log out',
                            style: TextStyle(
                                color: Colors.white, fontSize: 16.sp),
                          ),
                          content: Text(
                            'Are you sure you want to log out?',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13.sp,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.back();
                                profile.logout();
                              },
                              child: Text(
                                'Log out',
                                style: TextStyle(
                                  color: Colors.red.shade300,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/drawer/logout.png',
                          width: 20.w,
                          height: 20.w,
                          color: AppColors.cyan,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.logout_rounded,
                            color: AppColors.cyan,
                            size: 20.w,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.textGradient.createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            'Log out',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Underline
                  Container(
                    height: 1,
                    width: 110.w,
                    decoration: BoxDecoration(
                      gradient: AppColors.textGradient,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 22.w,
              height: 22.w,
              color: Colors.white,
              errorBuilder: (_, __, ___) => Icon(
                Icons.circle_outlined,
                color: Colors.white,
                size: 22.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}
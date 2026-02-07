import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';


class CustomDrawer extends StatelessWidget {
  final VoidCallback onClose;

  const CustomDrawer({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280.w,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with logo and close button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/splash/stumble.png',
                    fit: BoxFit.cover,
                  ),
                  // Close button
                  GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.9),
                        size: 24.w,

                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10.h),

            // Profile Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6B4EAA), Color(0xFF9B6BFF)],
                      ),
                      border: Border.all(
                        color: const Color(0xFF4EFFEE),
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/avatar/profile.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28.w,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Name and Email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daniel Jones',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'daniel.jones@example.com',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Badge
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF232244),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium,
                      color: const Color(0xFF4CAF50),
                      size: 16.w,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Founder's Badge",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30.h),

            // Menu Items - All using asset image paths
            _buildMenuItem(
              icon: 'assets/images/icon/video_icon.png',
              label: 'My Videos',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: 'assets/images/icon/dashboard_icon.png',
              label: 'Dashboard',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: 'assets/images/icon/settings_icon.png',
              label: 'Settings',
              onTap: () {

              },
            ),

            const Spacer(),

            // Logout
            _buildMenuItem(
              icon: 'assets/images/icon/logout.png',
              label: 'Log out',
              onTap: () {
                // Handle logout
              },
              isLogout: true,
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              fit: BoxFit.cover,
              color: isLogout ? const Color(0xFFFF5252) : null,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported,
                  color: Colors.white.withOpacity(0.5),
                  size: 24.w,
                );
              },
            ),
            SizedBox(width: 18.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white,
              size: 24.w,
            ),
          ],
        ),
      ),
    );
  }
}
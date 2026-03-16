// lib/feature/profile/screen/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../route/app_route.dart';
import '../../color/app_color.dart';
import '../../home/controller/profile_controller.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController profile = ProfileController.to;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/auth/sign in.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Obx(() {
            if (profile.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.cyan,
                  strokeWidth: 2,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                SizedBox(height: 20.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Control your experience and account settings',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _buildProfileCard(profile),
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 4.h),
                      _buildMenuItem(
                        iconPath: 'assets/images/home/email.png',
                        label: 'Email',
                        subtitle: profile.email.value.isNotEmpty
                            ? profile.email.value
                            : '—',
                        trailing: Icon(
                          Icons.edit_outlined,
                          color: Colors.white.withOpacity(0.5),
                          size: 18.w,
                        ),
                        onTap: () {},
                      ),
                      SizedBox(height: 8.h),
                      _buildMenuItem(
                        iconPath: 'assets/images/drawer/privacy.png',
                        label: 'Privacy policy',
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.white.withOpacity(0.5),
                          size: 22.w,
                        ),
                        onTap: () => Get.toNamed(RouteName.privacy),
                      ),
                      SizedBox(height: 8.h),
                      _buildMenuItem(
                        iconPath: 'assets/images/auth/logout.png',
                        label: 'Log out',
                        labelColor: Colors.red.shade300,
                        onTap: () => _confirmLogout(context, profile),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Icon(Icons.menu, color: Colors.white, size: 22.w),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/auth/logo.png',
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),
          ),
          SizedBox(width: 22.w),
        ],
      ),
    );
  }

  Widget _buildProfileCard(ProfileController profile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52.w,
            height: 52.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.purple, AppColors.cyan],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(2.w),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF0D0D0D),
                ),
                child: Center(
                  child: Text(
                    profile.username.value.isNotEmpty
                        ? profile.username.value[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.textGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    profile.username.value.isNotEmpty
                        ? profile.username.value
                        : 'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${profile.videosCreated.value} videos created',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.more_horiz,
              color: Colors.white.withOpacity(0.6),
              size: 22.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconPath,
    required String label,
    String? subtitle,
    Widget? trailing,
    Color? labelColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        ),
        child: Row(
          children: [
            Image.asset(
              iconPath,
              width: 22.w,
              height: 22.w,
              color: labelColor ?? Colors.white.withOpacity(0.75),
              errorBuilder: (_, __, ___) => Icon(
                Icons.circle_outlined,
                color: labelColor ?? Colors.white.withOpacity(0.75),
                size: 22.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: labelColor ?? Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, ProfileController profile) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        title: Text(
          'Log out',
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
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
  }
}
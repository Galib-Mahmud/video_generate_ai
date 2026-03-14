import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hussein/route/route_name.dart';

import '../../../route/app_route.dart';
import '../../color/app_color.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Bar ────────────────────────────────────────
              _buildTopBar(),


              SizedBox(height: 20.h),

              // ── Page Title ─────────────────────────────────────
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
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // ── Profile Card ───────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildProfileCard(),
              ),

              SizedBox(height: 8.h),

              // ── Menu Items ─────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 4.h),
                    _buildMenuItem(
                      iconPath: 'assets/images/home/email.png',     // 🔁 your path
                      label: 'Email',
                      subtitle: 'andrew_garfield@gmail.com',
                      trailing: Image.asset(
                        'assets/images/home/edit.png',              // 🔁 your path
                        width: 18.w,
                        height: 18.w,
                        color: Colors.white.withOpacity(0.5),
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.edit_outlined,
                          color: Colors.white.withOpacity(0.5),
                          size: 18.w,
                        ),
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
                      onTap: () {
                        // Handle logout
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar: hamburger + logo ──────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {

            },
            child: Image.asset(
              'assets/icons/profile/menu.png',                        // 🔁 your path
              width: 26.w,
              height: 26.w,
              color: Colors.white,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.menu, color: Colors.white, size: 22.w),
            ),
          ),
          Expanded(
            child: Center(
              child: Image.asset(
                'assets/images/auth/logo.png',
                fit: BoxFit.cover,

              ),
            ),
          ),
          SizedBox(width: 22.w), // balance
        ],
      ),
    );
  }

  // ── Profile card ───────────────────────────────────────────────
  Widget _buildProfileCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Row(
        children: [
          // Avatar with AppColors gradient border ring
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
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/profile/profile_picture.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 26.w,
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
                // Name — AppColors gradient
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.textGradient.createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    'Andrew Garfield',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '16 videos created',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),

          // ··· three-dot
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

  // ── Reusable menu row ──────────────────────────────────────────
  Widget _buildMenuItem({
    required String iconPath,
    required String label,
    String? subtitle,
    Widget? trailing,
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
              color: Colors.white.withOpacity(0.75),
              errorBuilder: (_, __, ___) => Icon(
                Icons.circle_outlined,
                color: Colors.white.withOpacity(0.75),
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
                      color: Colors.white,
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
}
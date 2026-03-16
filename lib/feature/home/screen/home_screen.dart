// lib/feature/home/screen/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../route/app_route.dart';
import '../../color/app_color.dart';
import '../controller/home_controller.dart';
import '../controller/video_controller.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController home = HomeController.to;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
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
              _buildTopBar(),
              SizedBox(height: 16.h),
              Expanded(
                child: Obx(() {
                  if (home.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.cyan,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeBanner(),
                        SizedBox(height: 24.h),
                        _buildSectionHeader(),
                        SizedBox(height: 16.h),
                        _buildIndustryList(home),
                        SizedBox(height: 30.h),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
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
                errorBuilder: (_, __, ___) => Text(
                  'NO FACE ADS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 22.w),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Image.asset(
          'assets/images/home/wellcome.png',
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: double.infinity,
            height: 130.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.purple, AppColors.cyan],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Center(
              child: Text(
                'Welcome Banner',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Your Industry',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Choose the category that best fits your business.\nThis helps us tailor your video style and messaging.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndustryList(HomeController home) {
    return Obx(() {
      if (home.industries.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Text(
              'No industries available.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 13.sp,
              ),
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: home.industries.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (_, i) {
          final industry = home.industries[i];
          return Obx(() {
            final bool isSelected = home.selectedIndex.value == i;
            return GestureDetector(
              onTap: () async {
                home.selectIndustry(i);
                // Create project then navigate to video creation flow
                final VideoController vc = VideoController.to;
                vc.resetFlow();
                await vc.createProject(industry.name);
                if (vc.currentProjectId.value.isNotEmpty) {
                  Get.toNamed(RouteName.generate);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: 110.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: isSelected ? AppColors.cyan : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: AppColors.cyan.withOpacity(0.35),
                      blurRadius: 14,
                      spreadRadius: 1,
                    )
                  ]
                      : [],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Fallback gradient background
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1A1A2E),
                              const Color(0xFF16213E),
                            ],
                          ),
                        ),
                      ),
                      // Industry name centered
                      Center(
                        child: Text(
                          industry.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Selected overlay
                      if (isSelected)
                        Container(
                          color: AppColors.cyan.withOpacity(0.15),
                        ),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      );
    });
  }
}
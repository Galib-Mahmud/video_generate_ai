import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../color/app_color.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedIndex;

  // ── Industry categories — provide your own image assets ──
  final List<Map<String, dynamic>> _industries = [
    {
      'image': 'assets/images/home/Frame1.png',
      'id': 0,
    },
    {
      'image': 'assets/images/home/frame2.png',
      'id': 1,
    },
    {
      'image': 'assets/images/home/frame3.png',
      'id': 2,
    },
    {
      'image': 'assets/images/home/frame4.png',
      'id': 3,
    },{
      'image': 'assets/images/home/frame5.png',
      'id': 4,
    },
  ];

  void _onIndustryTapped(int index) {
    setState(() => _selectedIndex = index);
    // TODO: navigate or handle selection
  }

  @override
  Widget build(BuildContext context) {
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

              // ── Scrollable content ───────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome banner (image only — no text overlay)
                      _buildWelcomeBanner(),
                      SizedBox(height: 24.h),

                      // Section title + subtitle
                      _buildSectionHeader(),
                      SizedBox(height: 16.h),

                      // Industry image cards (clickable, no text on image)
                      _buildIndustryList(),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Image.asset(
              'assets/icons/menu.png',
              width: 22.w,
              height: 22.w,
              color: Colors.white,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.menu, color: Colors.white, size: 22.w),
            ),
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

  // ── Welcome banner ─────────────────────────────────────────────
  // Pure image — no text overlay. Replace asset path with your banner image.
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

  // ── Section header ─────────────────────────────────────────────
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
            'Choose the category that best fits your business. This\nhelps us tailor your video style and messaging',
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

  // ── Industry list ──────────────────────────────────────────────
  Widget _buildIndustryList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: _industries.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => _buildIndustryCard(_industries[i], i),
    );
  }

  // ── Industry card — image only, no text, clickable ─────────────
  Widget _buildIndustryCard(Map<String, dynamic> industry, int index) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onIndustryTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 110.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppColors.cyan
                : Colors.transparent,
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
          child: Image.asset(
            industry['image'],
            width: double.infinity,
            height: 110.h,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: double.infinity,
              height: 110.h,
              color: const Color(0xFF1A1A1A),
              child: Icon(
                Icons.image_outlined,
                color: Colors.white.withOpacity(0.2),
                size: 32.w,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
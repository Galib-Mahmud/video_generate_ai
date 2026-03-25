// lib/feature/home/screen/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../color/app_color.dart';
import '../controller/home_controller.dart';
import 'app_drawer_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController _home = HomeController.to;

  @override
  void initState() {
    super.initState();
    // Refresh industries every time this screen becomes active
    // (handles the case where user just logged in)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _home.fetchIndustries();
    });
  }

  // ── Unsplash images keyed by industry name ─────────────────────
  static const Map<String, String> _industryImages = {
    'Digital Marketing':  'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=600&q=80',
    'E-Commerce':         'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=600&q=80',
    'Real Estate':        'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=600&q=80',
    'Travel & Tourism':   'https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=600&q=80',
    'Healthcare':         'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=600&q=80',
    'Education':          'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=600&q=80',
    'Finance & Banking':  'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=600&q=80',
    'Technology':         'https://images.unsplash.com/photo-1518770660439-4636190af475?w=600&q=80',
    'Food & Restaurant':  'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600&q=80',
    'Fitness & Wellness': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&q=80',
    'Fashion & Beauty':   'https://images.unsplash.com/photo-1445205170230-053b83016050?w=600&q=80',
    'Automotive':         'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=600&q=80',
    'Legal Services':     'https://images.unsplash.com/photo-1589829545856-d10d557cf95f?w=600&q=80',
    'Entertainment':      'https://images.unsplash.com/photo-1603190287605-e6ade32fa852?w=600&q=80',
    'SaaS / Software':    'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=600&q=80',
    'Non-Profit':         'https://images.unsplash.com/photo-1559027615-cd4628902d4a?w=600&q=80',
    'Construction':       'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=600&q=80',
    'Consulting':         'https://images.unsplash.com/photo-1552664730-d307ca884978?w=600&q=80',
    'Other':              'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&q=80',
  };

  String _imageFor(String name) =>
      _industryImages[name] ??
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=600&q=80';

  IconData _iconFromString(String icon) {
    switch (icon) {
      case 'megaphone':      return Icons.campaign_outlined;
      case 'shopping-cart':  return Icons.shopping_cart_outlined;
      case 'building':       return Icons.business_outlined;
      case 'plane':          return Icons.flight_outlined;
      case 'heart-pulse':    return Icons.favorite_border;
      case 'graduation-cap': return Icons.school_outlined;
      case 'wallet':         return Icons.account_balance_wallet_outlined;
      case 'cpu':            return Icons.memory_outlined;
      case 'utensils':       return Icons.restaurant_outlined;
      case 'dumbbell':       return Icons.fitness_center_outlined;
      case 'scissors':       return Icons.content_cut_outlined;
      case 'car':            return Icons.directions_car_outlined;
      case 'scale':          return Icons.balance_outlined;
      case 'film':           return Icons.movie_outlined;
      case 'code':           return Icons.code_outlined;
      case 'hand-heart':     return Icons.volunteer_activism_outlined;
      case 'hard-hat':       return Icons.construction_outlined;
      case 'briefcase':      return Icons.work_outline;
      case 'grid':           return Icons.grid_view_outlined;
      default:               return Icons.category_outlined;
    }
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
              Expanded(
                child: Obx(() {
                  if (_home.isLoading.value && _home.industries.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.cyan, strokeWidth: 2),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.cyan,
                    backgroundColor: const Color(0xFF1A1A1A),
                    onRefresh: _home.fetchIndustries,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeBanner(),
                          SizedBox(height: 24.h),
                          _buildSectionHeader(),
                          SizedBox(height: 16.h),
                          _buildIndustryGrid(),
                          SizedBox(height: 30.h),
                        ],
                      ),
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
            onTap: () => Get.find<AppDrawerController>().open(),
            child: Icon(Icons.menu, color: Colors.white, size: 26.w),
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
          SizedBox(width: 26.w),
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
              gradient: const LinearGradient(
                colors: [AppColors.purple, AppColors.cyan],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Create AI Marketing Videos',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 6.h),
                  Text('Pick your industry and generate in minutes',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13.sp)),
                ],
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
          Text('Select Your Industry',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 6.h),
          Text(
            'Choose the category that best fits your business.\nThis helps us tailor your video style and messaging.',
            style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 13.sp,
                height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildIndustryGrid() {
    return Obx(() {
      if (_home.industries.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              children: [
                Icon(Icons.category_outlined,
                    color: Colors.white.withOpacity(0.2), size: 48.w),
                SizedBox(height: 12.h),
                Text('No industries available',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13.sp)),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.25,
          ),
          itemCount: _home.industries.length,
          itemBuilder: (_, i) {
            final industry = _home.industries[i];
            return Obx(() {
              final bool isSelected = _home.selectedIndex.value == i;
              final bool isCreating =
                  _home.isCreatingProject.value && isSelected;

              return GestureDetector(
                onTap: _home.isCreatingProject.value
                    ? null
                    : () => _home.onIndustryTapped(i, industry.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.cyan
                          : Colors.white.withOpacity(0.08),
                      width: isSelected ? 2 : 1,
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
                    borderRadius: BorderRadius.circular(13.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // ── Network image ──────────────────────
                        Image.network(
                          _imageFor(industry.name),
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: const Color(0xFF1A1A1A),
                              child: Center(
                                child: SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: const CircularProgressIndicator(
                                    color: AppColors.cyan,
                                    strokeWidth: 1.5,
                                  ),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF1A1A1A),
                            child: Icon(
                              _iconFromString(industry.icon),
                              color: Colors.white.withOpacity(0.2),
                              size: 32.w,
                            ),
                          ),
                        ),

                        // ── Dark gradient overlay ──────────────
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.05),
                                Colors.black.withOpacity(0.72),
                              ],
                            ),
                          ),
                        ),

                        // ── Selected cyan tint ─────────────────
                        if (isSelected)
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withOpacity(0.12),
                            ),
                          ),

                        // ── Content overlay ────────────────────
                        Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Top-right badge
                              Align(
                                alignment: Alignment.topRight,
                                child: isCreating
                                    ? Container(
                                  width: 24.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black.withOpacity(0.5),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(4.w),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                                    : isSelected
                                    ? Container(
                                  width: 22.w,
                                  height: 22.w,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.cyan,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 13.w,
                                  ),
                                )
                                    : const SizedBox(),
                              ),

                              // Bottom: industry name
                              Text(
                                industry.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.8),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        ),
      );
    });
  }
}
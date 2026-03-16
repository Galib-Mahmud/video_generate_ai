// lib/feature/subscription/screen/subscription_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../color/app_color.dart';
import '../controller/subscription_controller.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SubscriptionController sub = SubscriptionController.to;

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
            children: [
              _buildAppBar(context),
              Expanded(
                child: Obx(() {
                  if (sub.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.cyan,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        children: [
                          SizedBox(height: 8.h),
                          _buildStepIndicator(),
                          SizedBox(height: 28.h),
                          _buildHeading(),
                          SizedBox(height: 28.h),
                          // ── Current subscription badge ──────────────
                          if (sub.currentPlanName.value.isNotEmpty)
                            _buildCurrentPlanBadge(sub),
                          SizedBox(height: 16.h),
                          // ── Plan cards from API ─────────────────────
                          ...sub.plans.asMap().entries.map((e) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 14.h),
                              child: _buildPlanCard(sub, e.value, e.key),
                            );
                          }),
                          SizedBox(height: 16.h),
                          _buildTermsText(),
                          SizedBox(height: 24.h),
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.chevron_left, color: Colors.white, size: 28.w),
            ),
          ),
          Text(
            'Subscription',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanBadge(SubscriptionController sub) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_rounded,
              color: AppColors.cyan, size: 18.w),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Plan: ${sub.currentPlanName.value}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${sub.videosRemaining.value} videos · ${sub.scriptsRemaining.value} scripts remaining',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Column(
      children: [
        Text(
          '1 of 3',
          style: TextStyle(
            color: Colors.white.withOpacity(0.55),
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStep(isActive: false, isDone: true),
            _buildStepLine(),
            _buildStep(isActive: true, isDone: true),
            _buildStepLine(),
            _buildStep(isActive: false, isDone: false),
          ],
        ),
      ],
    );
  }

  Widget _buildStep({required bool isActive, required bool isDone}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: isActive ? 46.w : 42.w,
      height: isActive ? 46.w : 42.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive || isDone
            ? const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFCCCCCC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: isActive || isDone ? null : const Color(0xFF2A2A2A),
        border: Border.all(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.15),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.check,
          color: isDone || isActive ? const Color(0xFF0A0A0A) : Colors.transparent,
          size: 18.w,
        ),
      ),
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 60.w,
      height: 2.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.6),
            Colors.white.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  Widget _buildHeading() {
    return Column(
      children: [
        Text(
          'Unlock Full',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26.sp,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.purple, AppColors.cyan],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                'Video ',
                style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w700),
              ),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.purple, AppColors.cyan],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Icon(Icons.workspace_premium_rounded, size: 26.w),
            ),
            SizedBox(width: 4.w),
            Text(
              ' Creation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanCard(
      SubscriptionController sub,
      PlanModel plan,
      int index,
      ) {
    return Obx(() {
      final bool isSelected = sub.selectedPlanIdx.value == index;
      final bool isPremium  = plan.isPremium;

      return GestureDetector(
        onTap: () => sub.selectPlan(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: isPremium
                ? const Color(0xFF151520)
                : const Color(0xFF111111),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.cyan
                  : isPremium
                  ? const Color(0xFF7B2FF7).withOpacity(0.6)
                  : Colors.white.withOpacity(0.12),
              width: isSelected ? 2 : (isPremium ? 1.5 : 1),
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.cyan.withOpacity(0.2),
                blurRadius: 16,
                spreadRadius: 1,
              )
            ]
                : [],
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.purple, AppColors.cyan],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        isPremium ? 'Best value' : 'Offer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${plan.currency} ${plan.priceMonthly}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.purple, AppColors.cyan],
                      ).createShader(bounds),
                      blendMode: BlendMode.srcIn,
                      child: Text(
                        'monthly',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),

                // Description from API
                Text(
                  plan.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 8.h),

                // Features
                _buildFeatureRow(
                  '${plan.maxVideosPerMonth} videos/month',
                  Icons.videocam_outlined,
                ),
                SizedBox(height: 4.h),
                _buildFeatureRow(
                  '${plan.maxScriptGenerationsPerMonth} AI scripts/month',
                  Icons.edit_outlined,
                ),
                if (plan.hasPriorityProcessing) ...[
                  SizedBox(height: 4.h),
                  _buildFeatureRow('Priority processing', Icons.bolt_outlined),
                ],
                if (!plan.hasWatermark) ...[
                  SizedBox(height: 4.h),
                  _buildFeatureRow('No watermark', Icons.water_drop_outlined),
                ],
                SizedBox(height: 14.h),

                // Choose button
                _buildChooseButton(
                  isPremium: isPremium,
                  isSelected: isSelected,
                  onTap: () => sub.selectPlan(index),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFeatureRow(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.cyan, size: 14.w),
        SizedBox(width: 6.w),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildChooseButton({
    required bool isPremium,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    if (isPremium || isSelected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          height: 46.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.purple, AppColors.cyan],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Center(
            child: Text(
              isSelected ? 'Selected ✓' : 'Choose',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            'Choose',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: TextStyle(
          color: Colors.white.withOpacity(0.45),
          fontSize: 12.sp,
          height: 1.6,
        ),
        children: [
          const TextSpan(text: 'By choosing you agree to our '),
          TextSpan(
            text: 'Terms and\nPrivacy policy',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              decoration: TextDecoration.underline,
              decorationColor: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
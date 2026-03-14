import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../color/app_color.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlan = -1; // -1 = none selected

  final List<Map<String, dynamic>> _plans = [
    {
      'title': 'Free Trial',
      'price': '\$7',
      'period': 'monthly',
      'description': 'Limited exports to 1 export per day',
      'badge': 'Offer',
      'badgeGradient': [Color(0xFF7B2FF7), Color(0xFF00C2CB)],
      'annual': '\$60/yr Standard',
      'isPremium': false,
    },
    {
      'title': 'Standard',
      'price': '\$7',
      'period': 'monthly',
      'description': 'Recommendations, Insights',
      'badge': 'Offer',
      'badgeGradient': [Color(0xFF7B2FF7), Color(0xFF00C2CB)],
      'annual': '\$60/yr Standard',
      'isPremium': false,
    },
    {
      'title': 'Premium',
      'price': '\$12',
      'period': 'monthly',
      'description': 'Recommendations, Insights',
      'badge': 'Best value',
      'badgeGradient': [Color(0xFF7B2FF7), Color(0xFF00C2CB)],
      'annual': '\$96/yr Premium',
      'isPremium': true,
    },
  ];

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
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
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
                        ..._plans.asMap().entries.map(
                              (e) => Padding(
                            padding: EdgeInsets.only(bottom: 14.h),
                            child: _buildPlanCard(e.value, e.key),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildTermsText(),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 28.w,
              ),
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

  // ── Step indicator ─────────────────────────────────────────────
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
          color: isActive
              ? Colors.white
              : Colors.white.withOpacity(0.15),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.check,
          color: isDone || isActive
              ? const Color(0xFF0A0A0A)
              : Colors.transparent,
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

  // ── Heading ────────────────────────────────────────────────────
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
                colors: [Color(0xFF7B2FF7), Color(0xFF00C2CB)],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                'Video ',
                style: TextStyle(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Crown icon
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF7B2FF7), Color(0xFF00C2CB)],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Icon(
                Icons.workspace_premium_rounded,
                size: 26.w,
              ),
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

  // ── Plan card ──────────────────────────────────────────────────
  Widget _buildPlanCard(Map<String, dynamic> plan, int index) {
    final bool isSelected = _selectedIndex == index;
    final bool isPremium = plan['isPremium'] as bool;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isPremium
              ? const Color(0xFF151520)
              : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isPremium
                ? const Color(0xFF7B2FF7).withOpacity(0.6)
                : Colors.white.withOpacity(0.12),
            width: isPremium ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Badge row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: plan['badgeGradient'] as List<Color>,
                      ),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      plan['badge'],
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
                    plan['price'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF7B2FF7), Color(0xFF00C2CB)],
                    ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: Text(
                      plan['period'],
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),

              // Description
              Text(
                plan['description'],
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 14.h),

              // Choose button
              _buildChooseButton(isPremium: isPremium),
              SizedBox(height: 12.h),

              // Annual price
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    children: [
                      const TextSpan(text: 'Annual : '),
                      TextSpan(
                        text: plan['annual'],
                        style: const TextStyle(
                          color: Color(0xFF00C2CB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const TextSpan(text: ' .'),
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

  Widget _buildChooseButton({required bool isPremium}) {
    if (isPremium) {
      return Container(
        height: 46.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7B2FF7), Color(0xFF00C2CB)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30.r),
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
      );
    }

    return Container(
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
    );
  }

  // ── Terms text ─────────────────────────────────────────────────
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

  int get _selectedIndex => _selectedPlan;
  set _selectedIndex(int v) => _selectedPlan = v;
}
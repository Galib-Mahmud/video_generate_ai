import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../color/app_color.dart';


class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

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
            children: [
              // ── AppBar ───────────────────────────────────────
              _buildAppBar(context),

              // ── Scrollable Body ──────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(),
                      SizedBox(height: 28.h),

                      Text(
                        'Fair Use Policy (Unlimited & High-Volume Plans)',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      _buildSection(
                        number: '1.',
                        title: 'Purpose of Fair Use',
                        body:
                        'Flowverse offers high-volume and unlimited subscription plans to support professional creators, choreographers, and studios. This Fair Use Policy exists to ensure platform stability, performance, and equitable access for all users.',
                      ),
                      _buildSection(
                        number: '2.',
                        title: 'Scope',
                        body: 'This policy applies to:',
                        bullets: [
                          'Pro+ Unlimited subscriptions',
                          'Any plan or add-on that includes high-volume or unlimited exports',
                        ],
                      ),
                      _buildSection(
                        number: '3.',
                        title: 'Acceptable Use',
                        body: 'Subscribers may use Flowverse to:',
                        bullets: [
                          'Generate dance videos for personal or professional creative projects',
                          'Create social media content, auditions, showcases, and promotional materials',
                          'Produce client work as part of choreography, instruction, or studio operations',
                          'Revise, iterate, and export multiple versions of the same choreography',
                        ],
                        footer:
                        'Use should reflect human-initiated, creative workflows consistent with individual creators or small teams.',
                      ),
                      _buildSection(
                        number: '4.',
                        title: 'Prohibited Use',
                        body:
                        'The following activities are not permitted under any plan:',
                        bullets: [
                          'Automated, scripted, or programmatic generation of exports',
                          'Use of bots or third-party automation tools',
                          'Resale or sublicensing of Flowverse outputs as a standalone service',
                          'Excessive usage intended to benchmark, stress-test, or reverse engineer the system',
                          'Any activity that interferes with or degrades platform performance',
                        ],
                      ),
                      _buildSection(
                        number: '5.',
                        title: 'Reasonable Usage Thresholds',
                        body:
                        'While Flowverse does not impose hard export caps on unlimited plans, usage significantly exceeding typical creator patterns may be reviewed.\n\nAs general guidance:',
                        bullets: [
                          'Usage above approximately 300 exports per billing cycle may trigger a review for compliance with this policy',
                        ],
                        footer:
                        'Reviews are conducted to understand usage needs and are not punitive by default.',
                      ),
                      _buildSection(
                        number: '6.',
                        title: 'Enforcement & Resolution',
                        body:
                        'If usage appears inconsistent with this policy, Flowverse may:',
                        bullets: [
                          'Contact the account holder to discuss usage patterns',
                          'Recommend an alternative plan or custom enterprise agreement',
                          'Temporarily limit export functionality to protect system stability',
                        ],
                        footer:
                        'Flowverse will make reasonable efforts to notify users before applying any restrictions.',
                      ),
                      _buildSection(
                        number: '7.',
                        title: 'Commitment to Creators',
                        body:
                        'Flowverse is committed to supporting creators at all levels. This policy is designed to balance creative freedom with platform reliability. We aim to resolve usage concerns collaboratively and transparently.',
                      ),
                      _buildSection(
                        number: '8.',
                        title: 'Policy Updates',
                        body:
                        'Flowverse reserves the right to update this Fair Use Policy as the platform evolves. Material changes will be communicated to users in advance when reasonably possible.',
                      ),

                      SizedBox(height: 40.h),
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

  // ── Custom AppBar row ──────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.chevron_left, color: Colors.white, size: 28.w),
          ),
          Expanded(
            child: Text(
              'Privacy policy',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Spacer to keep title truly centered
          SizedBox(width: 28.w),
        ],
      ),
    );
  }

  // ── Hero lock icon card ────────────────────────────────────────
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.textGradient.createShader(bounds),
            blendMode: BlendMode.srcIn,
            child: Icon(Icons.lock_rounded, size: 36.w, color: Colors.white),
          ),
          SizedBox(height: 14.h),
          Text(
            'Your Privacy Matters',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'We respect your privacy and are committed to protecting your data while you create and share dance videos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 13.sp,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ── Numbered policy section ────────────────────────────────────
  Widget _buildSection({
    required String number,
    required String title,
    required String body,
    List<String>? bullets,
    String? footer,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 22.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number $title',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 13.sp,
              height: 1.6,
            ),
          ),
          if (bullets != null) ...[
            SizedBox(height: 8.h),
            ...bullets.map(
                  (item) => Padding(
                padding: EdgeInsets.only(left: 4.w, bottom: 5.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13.sp,
                        height: 1.6,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 13.sp,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (footer != null) ...[
            SizedBox(height: 8.h),
            Text(
              footer,
              style: TextStyle(
                color: Colors.white.withOpacity(0.65),
                fontSize: 13.sp,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
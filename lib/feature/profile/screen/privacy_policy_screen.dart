import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            image: AssetImage('assets/images/auth/sign in.png '), // Set your privacy policy background image here
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Privacy Policy Title Section
                  SizedBox(height: 30.h),
                  Text(
                    'Your Privacy Matters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Privacy policy content
                  _buildPrivacyPolicyContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. Purpose of Fair Use',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'The policy applies to subscribers who use this service for personal, educational, and commercial purposes.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 20.h),
        // Add more sections based on the privacy policy details
      ],
    );
  }
}

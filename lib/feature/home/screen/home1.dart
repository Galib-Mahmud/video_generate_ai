import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

import 'app_drawer_controller.dart';

class Home1 extends StatelessWidget {
  const Home1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 100.h), // 🔥 bottom padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    _buildHeroSection(),
                    SizedBox(height: 20.h),
                    _buildSectionTitle("Step-by-Step Video Guide"),
                    _buildStepCard(
                      1,
                      "Select Industry",
                      "Choose the business category that fits your video.",
                      "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=600",
                    ),
                    _buildStepCard(
                      2,
                      "Add Title & Service",
                      "Enter your video title and describe your service.",
                      "https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=600",
                    ),
                    _buildStepCard(
                      3,
                      "Choose Background",
                      "Pick a background style for your video.",
                      "https://images.unsplash.com/photo-1492724441997-5dc865305da7?w=600",
                    ),
                    _buildStepCard(
                      4,
                      "Select Avatar",
                      "Choose AI avatar (you can preview it here).",
                      "https://images.unsplash.com/photo-1607746882042-944635dfe10e?w=600",
                    ),
                    _buildStepCard(
                      5,
                      "Generate Script",
                      "AI will automatically generate a script for your video.",
                      "https://images.unsplash.com/photo-1455390582262-044cdead277a?w=600",
                    ),
                    _buildStepCard(
                      6,
                      "Finalize Script",
                      "Edit & confirm your script before generating voice.",
                      "https://images.unsplash.com/photo-1517430816045-df4b7de11d1d?w=600",
                    ),
                    _buildStepCard(
                      7,
                      "Generate Voice",
                      "Preview AI voice generated for your script.",
                      "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=600",
                    ),
                    _buildStepCard(
                      8,
                      "Generate Video",
                      "AI will generate the final video with your selected settings.",
                      "https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=600",
                    ),
                    SizedBox(height: 20.h),
                    _buildPreviewSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────── APPBAR ─────────────
  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {   Get.find<AppDrawerController>().open();},
            child: Icon(Icons.menu, color: Colors.white, size: 26.w),
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

  // ───────────── HERO DEMO ─────────────
  Widget _buildHeroSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 170.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          image: const DecorationImage(
            image: NetworkImage(
              "https://images.unsplash.com/photo-1492724441997-5dc865305da7?w=800",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.black.withOpacity(0.5),
              ),
            ),
            Center(
              child: Icon(Icons.play_circle_fill,
                  size: 50, color: Colors.white.withOpacity(0.7)),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Text(
                "Watch Demo 🎬",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ───────────── SECTION TITLE ─────────────
  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ───────────── STEP CARD ─────────────
  Widget _buildStepCard(int step, String title, String desc, String image) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
          color: Colors.white.withOpacity(0.05),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
              child: Image.network(image,
                  height: 140.h, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number circle
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "$step",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Text(desc,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 13.sp)),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ───────────── PREVIEW SECTION ─────────────
  Widget _buildPreviewSection() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Live Generation Preview",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 10.h),
          Container(
            height: 180.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              color: Colors.black,
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(Icons.play_circle_fill,
                      size: 50, color: Colors.white.withOpacity(0.5)),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        color: Colors.cyan,
                        backgroundColor: Colors.white.withOpacity(0.1),
                      ),
                      SizedBox(height: 6.h),
                      Text("Generating video...",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11.sp)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
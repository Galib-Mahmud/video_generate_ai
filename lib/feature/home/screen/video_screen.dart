import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../color/app_color.dart';

class YourVideosScreen extends StatefulWidget {
  const YourVideosScreen({Key? key}) : super(key: key);

  @override
  State<YourVideosScreen> createState() => _YourVideosScreenState();
}

class _YourVideosScreenState extends State<YourVideosScreen> {
  bool _isLoading = false;
  bool _hasVideos = false;

  // ── Demo video data — replace image paths with your actual assets ──
  final List<Map<String, dynamic>> _videos = [
    {
      'thumbnail': 'assets/images/videos/video_thumb_1.png',
      'title': 'Boost Your Productivity with AI',
      'time': '7 min ago',
      'isNew': true,
    },
    {
      'thumbnail': 'assets/images/videos/video_thumb_2.png',
      'title': 'Boost Your Productivity with AI',
      'time': '2 day ago',
      'isNew': false,
    },
  ];

  // Called when "Generate to get started" is tapped
  Future<void> _onGenerateTapped() async {
    setState(() => _isLoading = true);
    // Simulate generation delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
      _hasVideos = true;
    });
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
              SizedBox(height: 20.h),
              _buildPageTitle(),
              SizedBox(height: 24.h),

              // ── Scrollable Body + Button ───────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Content area with fixed height so empty/loader centers
                      SizedBox(
                        height: 400.h,
                        child: _isLoading
                            ? _buildLoader()
                            : _hasVideos
                            ? _buildVideoList()
                            : _buildEmptyState(),
                      ),

                      // Generate button just above bottom — only when empty
                      if (!_isLoading && !_hasVideos) _buildGenerateButton(),
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
              ),
            ),
          ),
          SizedBox(width: 22.w),
        ],
      ),
    );
  }

  // ── Page title ─────────────────────────────────────────────────
  Widget _buildPageTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Videos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Manage, preview, and export your AI-generated\nmarketing videos — all in one place.',
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

  // ── Loading spinner ────────────────────────────────────────────
  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36.w,
            height: 36.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor:
              const AlwaysStoppedAnimation<Color>(AppColors.cyan),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Generating your video...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "You haven't created any videos yet",
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Icon(
            Icons.close,
            color: Colors.white.withOpacity(0.2),
            size: 22.w,
          ),
        ],
      ),
    );
  }

  // ── Video list ─────────────────────────────────────────────────
  Widget _buildVideoList() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      // ⬇ must be false inside SingleChildScrollView
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _videos.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => _buildVideoCard(_videos[i]),
    );
  }

  // ── Video card ─────────────────────────────────────────────────
  Widget _buildVideoCard(Map<String, dynamic> video) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Row(
        children: [
          // Thumbnail + play icon
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14.r),
              bottomLeft: Radius.circular(14.r),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  video['thumbnail'],
                  width: 110.w,
                  height: 90.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 110.w,
                    height: 90.h,
                    color: const Color(0xFF1A1A1A),
                    child: Icon(
                      Icons.image_outlined,
                      color: Colors.white.withOpacity(0.2),
                      size: 28.w,
                    ),
                  ),
                ),
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.45),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 20.w,
                  ),
                ),
              ],
            ),
          ),

          // Info section
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge row
                  Row(
                    children: [
                      if (video['isNew'] == true)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.purple, AppColors.cyan],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'New',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.more_horiz,
                          color: Colors.white.withOpacity(0.5),
                          size: 20.w,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Title
                  Text(
                    video['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Time + Export
                  Row(
                    children: [
                      Text(
                        video['time'],
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11.sp,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.purple, AppColors.cyan],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            'Export',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Generate button ────────────────────────────────────────────
  Widget _buildGenerateButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 30.h),
      child: GestureDetector(
        onTap: _onGenerateTapped,
        child: Container(
          height: 52.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.15),
                blurRadius: 14,
                offset: const Offset(-5, 0),
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.15),
                blurRadius: 14,
                offset: const Offset(5, 0),
              ),
            ],
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.textGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                'Generate to get started',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
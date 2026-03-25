// lib/feature/video/screen/your_videos_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../route/app_route.dart';
import '../../color/app_color.dart';
import '../controller/video_controller.dart';
import 'app_drawer_controller.dart';

class YourVideosScreen extends StatelessWidget {
  const YourVideosScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VideoController vc = VideoController.to;

    // Fetch on open
    WidgetsBinding.instance.addPostFrameCallback((_) => vc.fetchProjects());

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
              Expanded(
                child: Obx(() {
                  // ── Video generation in progress ─────────────
                  if (vc.isGeneratingVideo.value || vc.isPollingVideoStatus.value) {
                    return _VideoGenerationAnimation(
                      step: vc.generationStep.value,
                    );
                  }
                  // ── Loading project list ─────────────────────
                  if (vc.isFetchingProjects.value) {
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
                        SizedBox(
                          height: 400.h,
                          child: vc.projects.isEmpty
                              ? _buildEmptyState()
                              : _buildVideoList(vc),
                        ),
                        if (vc.projects.isEmpty) _buildGenerateButton(vc),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
            Icons.videocam_off_outlined,
            color: Colors.white.withOpacity(0.2),
            size: 32.w,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoList(VideoController vc) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: vc.projects.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) {
        final project = vc.projects[i];
        final bool isNew = i == 0;
        return _buildVideoCard(
          title: project.title,
          time: _formatTime(project.createdAt),
          isNew: isNew,
          status: project.status,
          videoFileUrl: project.videoFileUrl,
        );
      },
    );
  }

  Widget _buildVideoCard({
    required String title,
    required String time,
    required bool isNew,
    required String status,
    String? videoFileUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(14.r),
              bottomLeft: Radius.circular(14.r),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 110.w,
                  height: 90.h,
                  color: const Color(0xFF1A1A1A),
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white.withOpacity(0.2),
                    size: 32.w,
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
          // Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (isNew)
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
                      Icon(
                        Icons.more_horiz,
                        color: Colors.white.withOpacity(0.5),
                        size: 20.w,
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    title.isEmpty ? 'Untitled Video' : title,
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
                  Row(
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11.sp,
                        ),
                      ),
                      const Spacer(),
                      if (status == 'video_completed')
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
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 5.h),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            status.replaceAll('_', ' '),
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
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

  Widget _buildGenerateButton(VideoController vc) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 30.h),
      child: GestureDetector(
        onTap: () => Get.toNamed(RouteName.home),
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

  String _formatTime(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24)   return '${diff.inHours} hr ago';
      return '${diff.inDays} day ago';
    } catch (_) {
      return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────
// VIDEO GENERATION ANIMATION WIDGET
// ─────────────────────────────────────────────────────────────────
class _VideoGenerationAnimation extends StatefulWidget {
  final int step;
  const _VideoGenerationAnimation({Key? key, required this.step})
      : super(key: key);

  @override
  State<_VideoGenerationAnimation> createState() =>
      _VideoGenerationAnimationState();
}

class _VideoGenerationAnimationState extends State<_VideoGenerationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnim;
  late Animation<double> _progressAnim;

  final List<String> _steps = [
    'Initializing...',
    'Creating your project',
    'Generating AI script',
    'Rendering video with avatar',
    'Processing video...',
    'Video complete! 🎉',
  ];

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressAnim = Tween<double>(
      begin: 0,
      end: (widget.step / 5).clamp(0.0, 1.0),
    ).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );

    _progressController.forward();
  }

  @override
  void didUpdateWidget(_VideoGenerationAnimation old) {
    super.didUpdateWidget(old);
    if (old.step != widget.step) {
      _progressAnim = Tween<double>(
        begin: _progressAnim.value,
        end: (widget.step / 5).clamp(0.0, 1.0),
      ).animate(
        CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
      );
      _progressController
        ..reset()
        ..forward();
    }
    // Stop spinning when done
    if (widget.step == 5) {
      _rotateController.stop();
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDone = widget.step == 5;
    final String label = widget.step < _steps.length
        ? _steps[widget.step]
        : _steps.last;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Animated icon ──────────────────────────────────
            ScaleTransition(
              scale: isDone ? const AlwaysStoppedAnimation(1.0) : _pulseAnim,
              child: RotationTransition(
                turns: isDone
                    ? const AlwaysStoppedAnimation(0)
                    : _rotateController,
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.purple, AppColors.cyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isDone
                          ? Icons.check_rounded
                          : Icons.movie_creation_outlined,
                      color: Colors.white,
                      size: 36.w,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 28.h),

            // ── Step label ────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                label,
                key: ValueKey(widget.step),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              isDone
                  ? 'Your video is ready to export!'
                  : 'This may take a few moments...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.45),
                fontSize: 12.sp,
              ),
            ),

            SizedBox(height: 28.h),

            // ── Progress bar ─────────────────────────────────
            AnimatedBuilder(
              animation: _progressAnim,
              builder: (_, __) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        height: 6.h,
                        width: double.infinity,
                        color: Colors.white.withOpacity(0.1),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _progressAnim.value,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.purple, AppColors.cyan],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${(_progressAnim.value * 100).toInt()}%',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: 32.h),

            // ── Step dots ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final bool active   = widget.step > i;
                final bool current  = widget.step == i + 1;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: current ? 20.w : 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    gradient: active || current
                        ? const LinearGradient(
                      colors: [AppColors.purple, AppColors.cyan],
                    )
                        : null,
                    color: active || current
                        ? null
                        : Colors.white.withOpacity(0.2),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
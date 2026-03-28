// lib/feature/video/screen/your_videos_screen.dart

import 'dart:io';
import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import '../../../route/app_route.dart';
import '../../color/app_color.dart';
import '../controller/video_controller.dart';
import '../controller/your_video_controller.dart';
import 'app_drawer_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EXPORT SERVICE
// ─────────────────────────────────────────────────────────────────────────────
class _VideoExportService {
  static Future<void> export({
    required String videoUrl,
    required BuildContext context,
    String fileName = 'exported_video.mp4',
  }) async {
    if (videoUrl.isEmpty) {
      _snack(context, '❌ No video URL found.', Colors.red.shade700);
      return;
    }

    final granted = await _requestPermission();
    if (!granted) {
      _snack(context, '❌ Storage permission denied.', Colors.red.shade700);
      return;
    }

    _snack(context, '⏳ Exporting video…', const Color(0xFF1A1A2E));

    try {
      bool? success;

      if (videoUrl.startsWith('http://') || videoUrl.startsWith('https://')) {
        final tempDir = await getTemporaryDirectory();
        final tempPath = '${tempDir.path}/$fileName';

        await Dio().download(
          videoUrl,
          tempPath,
          onReceiveProgress: (received, total) {
            if (total > 0) {
              debugPrint('Export progress: ${(received / total * 100).toInt()}%');
            }
          },
        );
        success = await GallerySaver.saveVideo(tempPath, toDcim: true);
        try {
          File(tempPath).deleteSync();
        } catch (_) {}
      } else {
        success = await GallerySaver.saveVideo(videoUrl, toDcim: true);
      }

      if (success == true) {
        _snack(context, '✅ Video saved to gallery!', Colors.green.shade700);
      } else {
        throw Exception('GallerySaver returned false');
      }
    } catch (e) {
      debugPrint('❌ Export error: $e');
      _snack(context, '❌ Export failed. Try again.', Colors.red.shade700);
    }
  }

  static Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.videos.isGranted) return true;
      if (await Permission.storage.isGranted) return true;
      final videos = await Permission.videos.request();
      if (videos.isGranted) return true;
      final storage = await Permission.storage.request();
      return storage.isGranted;
    } else if (Platform.isIOS) {
      final result = await Permission.photosAddOnly.request();
      return result.isGranted;
    }
    return true;
  }

  static void _snack(BuildContext context, String msg, Color color) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 3),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class YourVideosScreen extends StatefulWidget {
  const YourVideosScreen({Key? key}) : super(key: key);

  @override
  State<YourVideosScreen> createState() => _YourVideosScreenState();
}

class _YourVideosScreenState extends State<YourVideosScreen> {
  final YourVideosController _yvc = YourVideosController.to;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _yvc.refresh());
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
              SizedBox(height: 16.h),
              Expanded(
                child: Obx(() {
                  final vc = VideoController.to;

                  if (vc.isGeneratingVideo.value ||
                      vc.isPollingVideoStatus.value) {
                    return _VideoGenerationAnimation(
                      step: vc.generationStep.value,
                      videoUrl: vc.videoFileUrl.value,
                      onVideoReady: () => _yvc.refresh(),
                    );
                  }

                  if (_yvc.isFetchingProjects.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.cyan, strokeWidth: 2),
                    );
                  }

                  if (_yvc.projects.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    color: AppColors.cyan,
                    backgroundColor: const Color(0xFF1A1A1A),
                    onRefresh: _yvc.refresh,
                    child: ListView.separated(
                      padding: EdgeInsets.only(
                        left: 16.w,
                        right: 16.w,
                        top: 4.h,
                        bottom: 200.h,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _yvc.projects.length,
                      separatorBuilder: (_, __) => SizedBox(height: 14.h),
                      itemBuilder: (_, i) => _VideoCard(
                        key: ValueKey(_yvc.projects[i].id),
                        project: _yvc.projects[i],
                        isNew: i == 0,
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
            'Preview and export your AI-generated marketing videos.',
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
          Icon(Icons.videocam_off_outlined,
              color: Colors.white.withOpacity(0.15), size: 56.w),
          SizedBox(height: 16.h),
          Text('No videos yet',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 6.h),
          Text('Create your first AI marketing video',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3), fontSize: 13.sp)),
          SizedBox(height: 28.h),
          GestureDetector(
            onTap: () => Get.toNamed(RouteName.home),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.purple, AppColors.cyan]),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Text('Generate a Video',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIDEO CARD
// ─────────────────────────────────────────────────────────────────────────────
class _VideoCard extends StatefulWidget {
  final ProjectModel project;
  final bool isNew;
  const _VideoCard({Key? key, required this.project, required this.isNew})
      : super(key: key);

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  VideoPlayerController? _vpc;
  bool _expanded = false;
  bool _loading = false;
  bool _error = false;
  bool _exporting = false;

  bool get _hasVideo =>
      widget.project.videoFileUrl != null &&
          widget.project.videoFileUrl!.isNotEmpty;

  String get _playableUrl => widget.project.playableUrl;

  @override
  void dispose() {
    _vpc?.dispose();
    super.dispose();
  }

  Future<void> _openPlayer() async {
    if (_loading || !_hasVideo) return;
    setState(() {
      _loading = true;
      _error = false;
    });
    try {
      await _vpc?.dispose();
      _vpc = VideoPlayerController.networkUrl(Uri.parse(_playableUrl));
      await _vpc!.initialize();
      _vpc!.addListener(() {
        if (mounted) setState(() {});
      });
      await _vpc!.play();
      setState(() {
        _expanded = true;
        _loading = false;
      });
    } catch (e) {
      debugPrint('❌ VideoPlayer: $e');
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  void _togglePlay() {
    if (_vpc == null) return;
    _vpc!.value.isPlaying ? _vpc!.pause() : _vpc!.play();
    setState(() {});
  }

  void _close() {
    _vpc?.pause();
    setState(() => _expanded = false);
  }

  Future<void> _handleExport() async {
    if (_exporting) return;
    setState(() => _exporting = true);
    await _VideoExportService.export(
      videoUrl: _playableUrl,
      context: context,
      fileName:
      '${widget.project.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.mp4',
    );
    if (mounted) setState(() => _exporting = false);
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:'
          '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final bool isComplete = widget.project.status == 'video_completed';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: _expanded
              ? AppColors.cyan.withOpacity(0.45)
              : Colors.white.withOpacity(0.08),
          width: _expanded ? 1.5 : 1,
        ),
        boxShadow: _expanded
            ? [
          BoxShadow(
              color: AppColors.cyan.withOpacity(0.15),
              blurRadius: 18,
              spreadRadius: 1)
        ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Column(
          children: [
            if (_expanded && _vpc != null && _vpc!.value.isInitialized)
              _buildPlayer(),
            _buildInfoRow(isComplete),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer() {
    final ctrl = _vpc!;
    final pos = ctrl.value.position;
    final dur = ctrl.value.duration;
    final pct = dur.inMilliseconds > 0
        ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: ctrl.value.aspectRatio.clamp(0.5, 2.2),
          child: VideoPlayer(ctrl),
        ),
        Positioned.fill(
          child: GestureDetector(
            onTap: _togglePlay,
            behavior: HitTestBehavior.opaque,
            child: AnimatedOpacity(
              opacity: ctrl.value.isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    width: 54.w,
                    height: 54.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.55),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.7), width: 1.5),
                    ),
                    child: Icon(
                      ctrl.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 30.w,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 8.h,
          right: 8.w,
          child: GestureDetector(
            onTap: _close,
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.65),
              ),
              child:
              Icon(Icons.close_rounded, color: Colors.white, size: 16.w),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.72),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 2.5.h,
                    thumbShape:
                    RoundSliderThumbShape(enabledThumbRadius: 6.w),
                    overlayShape: SliderComponentShape.noOverlay,
                    activeTrackColor: AppColors.cyan,
                    inactiveTrackColor: Colors.white.withOpacity(0.25),
                    thumbColor: AppColors.cyan,
                  ),
                  child: Slider(
                    value: pct,
                    onChanged: (v) {
                      ctrl.seekTo(Duration(
                          milliseconds:
                          (v * dur.inMilliseconds).round()));
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(pos),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 10.sp)),
                      Text(_fmt(dur),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 10.sp)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(bool isComplete) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        children: [
          // Thumbnail / play button
          GestureDetector(
            onTap: (isComplete && _hasVideo && !_expanded) ? _openPlayer : null,
            child: Container(
              width: 54.w,
              height: 54.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: const Color(0xFF1A1A1A),
                border: Border.all(
                  color: isComplete
                      ? AppColors.cyan.withOpacity(0.3)
                      : Colors.white.withOpacity(0.08),
                ),
              ),
              child: _loading
                  ? Center(
                child: SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                      color: AppColors.cyan, strokeWidth: 2),
                ),
              )
                  : _error
                  ? Icon(Icons.error_outline,
                  color: Colors.red.shade400, size: 22.w)
                  : Icon(
                isComplete
                    ? Icons.play_circle_fill_rounded
                    : Icons.hourglass_top_rounded,
                color: isComplete
                    ? AppColors.cyan
                    : Colors.orange.shade400,
                size: 26.w,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Title + meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.isNew)
                      Container(
                        margin: EdgeInsets.only(right: 6.w),
                        padding: EdgeInsets.symmetric(
                            horizontal: 7.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.purple, AppColors.cyan]),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text('New',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700)),
                      ),
                    Expanded(
                      child: Text(
                        widget.project.title.isEmpty
                            ? 'Untitled Video'
                            : widget.project.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '${widget.project.industry} · ${_fmtTime(widget.project.createdAt)}',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.38),
                      fontSize: 11.sp),
                ),
              ],
            ),
          ),

          SizedBox(width: 10.w),

          // Export button
          if (isComplete)
            GestureDetector(
              onTap: _exporting ? null : _handleExport,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _exporting
                        ? [
                      AppColors.purple.withOpacity(0.5),
                      AppColors.cyan.withOpacity(0.5)
                    ]
                        : [AppColors.purple, AppColors.cyan],
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_exporting)
                      SizedBox(
                        width: 13.w,
                        height: 13.w,
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    else
                      Icon(Icons.download_rounded,
                          color: Colors.white, size: 13.w),
                    SizedBox(width: 4.w),
                    Text(
                      _exporting ? 'Saving…' : 'Export',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              padding:
              EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20.r),
                border:
                Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Text(
                widget.project.status.replaceAll('_', ' '),
                style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }

  String _fmtTime(String iso) {
    try {
      final diff = DateTime.now().difference(DateTime.parse(iso));
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) {
      return '';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIDEO GENERATION ANIMATION
// ─────────────────────────────────────────────────────────────────────────────
class _VideoGenerationAnimation extends StatefulWidget {
  final int step;
  final String videoUrl;
  final VoidCallback? onVideoReady;

  const _VideoGenerationAnimation({
    Key? key,
    required this.step,
    required this.videoUrl,
    this.onVideoReady,
  }) : super(key: key);

  @override
  State<_VideoGenerationAnimation> createState() =>
      _VideoGenerationAnimationState();
}

class _VideoGenerationAnimationState extends State<_VideoGenerationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotateCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _progressCtrl;
  late AnimationController _particleCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _progressAnim;
  bool _notified = false;

  static const _info = [
    ['Starting up…', 'Initializing your project'],
    ['Project created ✓', 'Moving to script generation'],
    ['Writing your script…', 'AI is crafting your message'],
    ['Rendering your video…', 'Avatar & voiceover being merged — ~1 min'],
    ['Processing…', 'Encoding and uploading your video'],
    ['Video is ready! 🎉', 'Your marketing video has been generated'],
  ];

  @override
  void initState() {
    super.initState();
    _rotateCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _particleCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();

    _pulseAnim = Tween<double>(begin: 0.88, end: 1.12).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _progressAnim = Tween<double>(
        begin: 0, end: (widget.step / 5).clamp(0.0, 1.0))
        .animate(
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOut));
    _progressCtrl.forward();
  }

  @override
  void didUpdateWidget(_VideoGenerationAnimation old) {
    super.didUpdateWidget(old);
    if (old.step != widget.step) {
      _progressAnim = Tween<double>(
          begin: _progressAnim.value,
          end: (widget.step / 5).clamp(0.0, 1.0))
          .animate(CurvedAnimation(
          parent: _progressCtrl, curve: Curves.easeOut));
      _progressCtrl
        ..reset()
        ..forward();
    }
    if (widget.step >= 5 && !_notified) {
      _notified = true;
      _rotateCtrl.stop();
      _pulseCtrl.stop();
      _particleCtrl.stop();
      WidgetsBinding.instance
          .addPostFrameCallback((_) => widget.onVideoReady?.call());
    }
  }

  @override
  void dispose() {
    _rotateCtrl.dispose();
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDone = widget.step >= 5;
    final int s = widget.step.clamp(0, _info.length - 1);

    return SizedBox.expand(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(_particleCtrl.value),
              size: MediaQuery.of(context).size,
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon
                  AnimatedBuilder(
                    animation:
                    Listenable.merge([_rotateCtrl, _pulseCtrl]),
                    builder: (_, __) => Transform.scale(
                      scale: isDone ? 1.0 : _pulseAnim.value,
                      child: Transform.rotate(
                        angle: isDone
                            ? 0
                            : _rotateCtrl.value * 2 * math.pi,
                        child: Container(
                          width: 88.w,
                          height: 88.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppColors.purple, AppColors.cyan],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.cyan.withOpacity(0.5),
                                  blurRadius: 32,
                                  spreadRadius: 4),
                            ],
                          ),
                          child: Icon(
                            isDone
                                ? Icons.check_rounded
                                : Icons.movie_creation_outlined,
                            color: Colors.white,
                            size: 40.w,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      _info[s][0],
                      key: ValueKey(widget.step),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      _info[s][1],
                      key: ValueKey('s${widget.step}'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13.sp,
                          height: 1.5),
                    ),
                  ),

                  SizedBox(height: 36.h),

                  // Progress bar
                  AnimatedBuilder(
                    animation: _progressAnim,
                    builder: (_, __) {
                      final pct = _progressAnim.value;
                      return Column(
                        children: [
                          Container(
                            height: 7.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: pct,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(colors: [
                                      AppColors.purple,
                                      AppColors.cyan,
                                    ]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Text(
                            '${(pct * 100).toInt()}%',
                            style: TextStyle(
                                color: AppColors.cyan,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 28.h),

                  // Step dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final bool done = widget.step > i;
                      final bool cur = widget.step == i + 1;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: cur ? 26.w : 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.r),
                          gradient: done || cur
                              ? const LinearGradient(colors: [
                            AppColors.purple,
                            AppColors.cyan,
                          ])
                              : null,
                          color: done || cur
                              ? null
                              : Colors.white.withOpacity(0.15),
                        ),
                      );
                    }),
                  ),

                  SizedBox(height: 36.h),

                  if (!isDone)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.08)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.tips_and_updates_outlined,
                              color: AppColors.cyan, size: 18.w),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Video generation takes about 1–2 minutes. '
                                  'The list below will refresh automatically.',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.55),
                                  fontSize: 11.sp,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTICLE PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;

  static final _pts = List.generate(
    20,
        (i) => _P(
      x: (i * 0.137 + 0.05) % 1.0,
      y: (i * 0.193 + 0.03) % 1.0,
      r: 1.5 + (i % 4) * 1.1,
      speed: 0.10 + (i % 5) * 0.04,
      phase: i * 0.32,
      opacity: 0.12 + (i % 4) * 0.06,
    ),
  );

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _pts) {
      final t = (progress * p.speed + p.phase) % 1.0;
      canvas.drawCircle(
        Offset(p.x * size.width, ((p.y + t) % 1.0) * size.height),
        p.r,
        Paint()
          ..color = AppColors.cyan.withOpacity(p.opacity * (1 - t * 0.6)),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter o) => o.progress != progress;
}

class _P {
  final double x, y, r, speed, phase, opacity;
  const _P({
    required this.x,
    required this.y,
    required this.r,
    required this.speed,
    required this.phase,
    required this.opacity,
  });
}
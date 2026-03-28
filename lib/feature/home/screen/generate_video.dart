// lib/feature/video/screen/video_creation_flow_screen.dart
//
// FLOW:
//   Step 0  _TitleStep          → PATCH title + service_description
//   Step 1  _BackgroundStep     → GET backgrounds → PATCH background
//   Step 2  _AvatarStep         → GET avatars → PATCH avatar_id
//   Step 3  _ScriptStep         → POST generate-script (needs title+desc+avatar)
//                                 PUT  finalize-script
//                                 POST tts  →  play audio
//   Step 4  _PreviewStep        → POST generate-video
//                                 Poll video-status
//                                 Show avatar_preview_video_url while loading
//                                 Show real video + "Video ready" top snackbar

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

import '../../color/app_color.dart';
import '../controller/video_controller.dart';
import 'app_drawer_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FLOW HOST
// ─────────────────────────────────────────────────────────────────────────────
class VideoCreationFlowScreen extends StatefulWidget {
  const VideoCreationFlowScreen({Key? key}) : super(key: key);
  @override
  State<VideoCreationFlowScreen> createState() =>
      _VideoCreationFlowScreenState();
}

class _VideoCreationFlowScreenState extends State<VideoCreationFlowScreen> {
  int _step = 0;

  @override
  void initState() {
    super.initState();
    // Pre-fetch backgrounds & avatars in parallel as soon as we enter
    VideoController.to.fetchBackgrounds();
    VideoController.to.fetchAvatars();
  }

  void _next() { if (_step < 4) setState(() => _step++); }
  void _back() {
    if (_step > 0) setState(() => _step--);
    else Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/auth/sign in.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, anim) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0), end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
            child: _buildStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
    // ── Step 0: Title + Service Description ──────────────────
      case 0:
        return _TitleStep(
          key: const ValueKey(0),
          onContinue: () async {
            final ok = await VideoController.to.patchTitleAndDescription();
            if (ok) _next();
          },
          onBack: _back,
        );

    // ── Step 1: Background ────────────────────────────────────
      case 1:
        return _BackgroundStep(
          key: const ValueKey(1),
          onContinue: _next,
          onBack: _back,
        );

    // ── Step 2: Avatar ────────────────────────────────────────
      case 2:
        return _AvatarStep(
          key: const ValueKey(2),
          onContinue: _next,
          onBack: _back,
        );

    // ── Step 3: Script + TTS ──────────────────────────────────
      case 3:
        return _ScriptStep(
          key: const ValueKey(3),
          onContinue: () async {
            await VideoController.to.finalizeScript();
            _next();
          },
          onBack: _back,
        );

    // ── Step 4: Generate Video + Preview ──────────────────────
      case 4:
        return _PreviewStep(key: const ValueKey(4), onBack: _back);

      default:
        return _TitleStep(key: const ValueKey(0),
            onContinue: _next, onBack: _back);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 0  –  Title + Service Description
// ─────────────────────────────────────────────────────────────────────────────
class _TitleStep extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  const _TitleStep(
      {Key? key, required this.onContinue, required this.onBack})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final vc = VideoController.to;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(
                showBack: true, onBack: onBack,
                showMenu: false, showLogo: true,
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step indicator
                    _StepIndicator(current: 0, total: 4),
                    SizedBox(height: 24.h),

                    _SectionTitle(
                        title: 'Name your video',
                        subtitle:
                        'Give your marketing video a title and describe your service'),
                    SizedBox(height: 20.h),

                    _Label('Video Title'),
                    SizedBox(height: 8.h),
                    _InputField(
                      controller: vc.titleController,
                      hint: 'e.g. Summer Marketing Campaign',
                    ),
                    SizedBox(height: 20.h),

                    _Label('Service Description'),
                    SizedBox(height: 8.h),
                    _InputField(
                      controller: vc.serviceDescController,
                      hint:
                      'e.g. We help brands scale their digital presence through SEO and social media.',
                      maxLines: 4,
                    ),
                    SizedBox(height: 16.h),

                    _HintCard(
                      icon: Icons.auto_awesome,
                      text:
                      'The AI uses your title and description to write a personalised marketing script for you.',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              Obx(() => _BottomButton(
                label: vc.isLoading.value ? 'Saving…' : 'Continue',
                onTap: vc.isLoading.value ? null : onContinue,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1  –  Background  (GET + PATCH)
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundStep extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  const _BackgroundStep(
      {Key? key, required this.onContinue, required this.onBack})
      : super(key: key);

  static const Map<String, String> _imgs = {
    'Modern Office':  'https://images.unsplash.com/photo-1497366216548-37526070297c?w=700&q=80',
    'City Skyline':   'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=700&q=80',
    'White Studio':   'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=700&q=80',
    'Nature Outdoor': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=700&q=80',
    'Coffee Shop':    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=700&q=80',
    'Classroom':      'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=700&q=80',
    'Hospital':       'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=700&q=80',
    'Gym':            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=700&q=80',
    'Tech Startup':   'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=700&q=80',
    'Luxury Interior':'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=700&q=80',
    'Warehouse':      'https://images.unsplash.com/photo-1553413077-190dd305871c?w=700&q=80',
    'Library':        'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=700&q=80',
    'Abstract Gradient':'https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?w=700&q=80',
    'Plain Color':    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=700&q=80',
    'Rooftop':        'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=700&q=80',
  };
  String _img(String n) =>
      _imgs[n] ?? 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=700&q=80';

  @override
  Widget build(BuildContext context) {
    final vc = VideoController.to;
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
              bottom: 110.h + MediaQuery.of(context).padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(showBack: true, onBack: onBack, showLogo: true),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepIndicator(current: 1, total: 4),
                    SizedBox(height: 24.h),
                    _SectionTitle(
                        title: 'Choose a background',
                        subtitle:
                        'Select a scene that matches your industry'),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
              Obx(() {
                if (vc.isFetchingBackgrounds.value) {
                  return SizedBox(
                    height: 200.h,
                    child: const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.cyan, strokeWidth: 2),
                    ),
                  );
                }
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: vc.backgrounds.map((bg) => Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: _buildCard(vc, bg),
                    )).toList(),
                  ),
                );
              }),
            ],
          ),
        ),

        // Pinned Continue button
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: _PinnedButton(
            onContinue: onContinue,
            isLoading: false,
          ),
        ),
      ],
    );
  }

  Widget _buildCard(VideoController vc, BackgroundModel bg) {
    return Obx(() {
      final sel = vc.selectedBackground.value == bg.name;
      return GestureDetector(
        onTap: () => vc.patchBackground(bg.name),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: sel ? AppColors.cyan : Colors.white.withOpacity(0.08),
              width: sel ? 2 : 1,
            ),
            boxShadow: sel
                ? [BoxShadow(
                color: AppColors.cyan.withOpacity(0.3),
                blurRadius: 14, spreadRadius: 1)]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: Column(
              children: [
                SizedBox(
                  height: 110.h, width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(_img(bg.name), fit: BoxFit.cover,
                          loadingBuilder: (_, child, p) => p == null
                              ? child
                              : Container(color: const Color(0xFF1A1A1A)),
                          errorBuilder: (_, __, ___) =>
                              Container(color: const Color(0xFF1A1A1A))),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                      if (sel)
                        DecoratedBox(
                            decoration: BoxDecoration(
                                color: AppColors.cyan.withOpacity(0.12))),
                    ],
                  ),
                ),
                Container(
                  color: const Color(0xFF111111),
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bg.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600)),
                            if (bg.description.isNotEmpty) ...[
                              SizedBox(height: 3.h),
                              Text(bg.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 11.sp)),
                            ],
                          ],
                        ),
                      ),
                      _SelectDot(selected: sel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2  –  Avatar  (GET + PATCH)
// ─────────────────────────────────────────────────────────────────────────────
class _AvatarStep extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  const _AvatarStep(
      {Key? key, required this.onContinue, required this.onBack})
      : super(key: key);
  @override
  State<_AvatarStep> createState() => _AvatarStepState();
}

class _AvatarStepState extends State<_AvatarStep> {
  bool _outfitOpen = false;

  @override
  Widget build(BuildContext context) {
    final vc = VideoController.to;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(showBack: true, onBack: widget.onBack, showLogo: true),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepIndicator(current: 2, total: 4),
                    SizedBox(height: 24.h),

                    _SectionTitle(
                        title: 'Choose your avatar',
                        subtitle:
                        'Select the presenter for your marketing video'),
                    SizedBox(height: 16.h),

                    // Outfit category chips
                    Obx(() => _buildChips(vc)),
                    SizedBox(height: 16.h),

                    // Avatar cards
                    Obx(() => _buildAvatarGrid(vc)),
                    SizedBox(height: 20.h),

                    // Outfit dropdown
                    _Label('Outfit style'),
                    SizedBox(height: 8.h),
                    Obx(() => _buildOutfitDropdown(vc)),
                  ],
                ),
              ),
             SizedBox(height: 60.h),
              Obx(() {
                final busy = vc.isPatchingAvatar.value;
                return _BottomButton(
                  label: busy ? 'Saving avatar…' : 'Continue',
                  onTap: busy || vc.selectedAvatarId.value.isEmpty
                      ? null
                      : widget.onContinue,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChips(VideoController vc) {
    final cats = vc.avatars.keys.toList();
    if (cats.isEmpty) return SizedBox(height: 36.h);
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final active = vc.selectedOutfit.value == cats[i];
          return GestureDetector(
            onTap: () => vc.selectedOutfit.value = cats[i],
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(
                    colors: [AppColors.purple, AppColors.cyan])
                    : null,
                color: active ? null : const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: active
                      ? Colors.transparent
                      : Colors.white.withOpacity(0.12),
                ),
              ),
              child: Text(_cap(cats[i]),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight:
                      active ? FontWeight.w600 : FontWeight.w400)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarGrid(VideoController vc) {
    if (vc.isFetchingAvatars.value) {
      return SizedBox(
        height: 130.h,
        child: const Center(
          child: CircularProgressIndicator(
              color: AppColors.cyan, strokeWidth: 2),
        ),
      );
    }
    final list = vc.avatars[vc.selectedOutfit.value] ?? [];
    if (list.isEmpty) {
      return SizedBox(
        height: 110.h,
        child: Center(
          child: Text('No avatars in this category',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4), fontSize: 13.sp)),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: list.map((avatar) {
          final sel = vc.selectedAvatarId.value == avatar.avatarId;
          return GestureDetector(
            onTap: () => vc.patchAvatar(avatar),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: 12.w),
              width: 100.w,
              height: 120.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: sel ? AppColors.cyan : Colors.white.withOpacity(0.08),
                  width: sel ? 2.5 : 1,
                ),
                boxShadow: sel
                    ? [BoxShadow(
                    color: AppColors.cyan.withOpacity(0.3),
                    blurRadius: 10)]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    avatar.previewImageUrl.isNotEmpty
                        ? Image.network(avatar.previewImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                        loadingBuilder: (_, child, p) =>
                        p == null ? child : _fallback())
                        : _fallback(),
                    // Name tag
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 5.h, horizontal: 6.w),
                        color: Colors.black.withOpacity(0.6),
                        child: Text(avatar.avatarName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    // Selected badge
                    if (sel)
                      Positioned(
                        top: 6.h, right: 6.w,
                        child: Container(
                          width: 22.w, height: 22.w,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.cyan),
                          child: Icon(Icons.check,
                              color: Colors.white, size: 13.w),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _fallback() => Container(
    color: const Color(0xFF1A1A1A),
    child: Icon(Icons.person,
        color: Colors.white.withOpacity(0.2), size: 36.w),
  );

  Widget _buildOutfitDropdown(VideoController vc) {
    final outfits = vc.avatars.keys.toList();
    if (outfits.isEmpty) return const SizedBox();
    return GestureDetector(
      onTap: () => setState(() => _outfitOpen = !_outfitOpen),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(10.r),
              border:
              Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_cap(vc.selectedOutfit.value),
                    style: TextStyle(
                        color: Colors.white, fontSize: 14.sp)),
                Icon(
                  _outfitOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white.withOpacity(0.6),
                  size: 20.w,
                ),
              ],
            ),
          ),
          if (_outfitOpen)
            Container(
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                    color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: outfits.map((o) {
                  final sel = vc.selectedOutfit.value == o;
                  return GestureDetector(
                    onTap: () {
                      vc.selectedOutfit.value = o;
                      setState(() => _outfitOpen = false);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      child: Text(_cap(o),
                          style: TextStyle(
                            color: sel
                                ? AppColors.cyan
                                : Colors.white.withOpacity(0.8),
                            fontSize: 13.sp,
                            fontWeight: sel
                                ? FontWeight.w600
                                : FontWeight.w400,
                          )),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3  –  Script + TTS Audio Preview
// ─────────────────────────────────────────────────────────────────────────────
class _ScriptStep extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  const _ScriptStep(
      {Key? key, required this.onContinue, required this.onBack})
      : super(key: key);
  @override
  State<_ScriptStep> createState() => _ScriptStepState();
}

class _ScriptStepState extends State<_ScriptStep> {
  final AudioPlayer _audio = AudioPlayer();
  bool _isPlaying = false;
  bool _audioReady = false;
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audio.positionStream.listen(
            (p) { if (mounted) setState(() => _pos = p); });
    _audio.durationStream.listen(
            (d) { if (mounted) setState(() => _dur = d ?? Duration.zero); });
    _audio.playerStateStream.listen((s) {
      if (mounted) {
        setState(() => _isPlaying = s.playing);
        if (s.processingState == ProcessingState.completed) {
          setState(() { _isPlaying = false; });
        }
      }
    });
    // Auto-generate script + TTS on entry
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vc = VideoController.to;
      await vc.generateScript();
      if (vc.generatedScript.value.isNotEmpty) {
        await _loadTts();
      }
    });
  }

  Future<void> _loadTts() async {
    setState(() { _audioReady = false; _isPlaying = false;
    _pos = Duration.zero; _dur = Duration.zero; });
    await VideoController.to.generateTts();
    final url = VideoController.to.ttsAudioUrl.value.trim();
    if (url.isEmpty) return;
    try {
      await _audio.stop();
      final d = await _audio.setUrl(url);
      if (mounted) setState(() { _audioReady = true; _dur = d ?? Duration.zero; });
    } catch (e) {
      debugPrint('❌ TTS load: $e');
    }
  }

  Future<void> _togglePlay() async {
    if (!_audioReady) return;
    if (_isPlaying) {
      await _audio.pause();
    } else {
      if (_pos >= _dur && _dur > Duration.zero) {
        await _audio.seek(Duration.zero);
      }
      await _audio.play();
    }
  }

  @override
  void dispose() { _audio.dispose(); super.dispose(); }

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2,'0')}:'
          '${d.inSeconds.remainder(60).toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final vc = VideoController.to;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top -
              MediaQuery.of(context).padding.bottom,
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(showBack: true, onBack: widget.onBack, showLogo: true),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepIndicator(current: 3, total: 4),
                    SizedBox(height: 24.h),
                    _SectionTitle(
                        title: 'Your AI script & voiceover',
                        subtitle:
                        'Edit the script if needed, then listen to the voiceover'),
                    SizedBox(height: 20.h),

                    // ── Script editor ──────────────────────────
                    Obx(() => _buildScriptEditor(vc)),
                    SizedBox(height: 24.h),

                    // ── TTS Player ─────────────────────────────
                    _Label('AI Voiceover Preview'),
                    SizedBox(height: 10.h),
                    Obx(() => _buildTtsPlayer(vc)),
                  ],
                ),
              ),
             SizedBox(height: 40.h),
              Obx(() => _BottomButton(
                label: vc.isLoading.value ? 'Saving…' : 'Continue',
                onTap: vc.isLoading.value ? null : widget.onContinue,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScriptEditor(VideoController vc) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111118),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (vc.isGeneratingScript.value)
            Container(
              height: 80.h,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                        color: AppColors.cyan, strokeWidth: 2),
                    SizedBox(height: 8),
                    Text('Generating your script…',
                        style: TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            TextField(
              controller: vc.scriptController,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13.sp,
                  height: 1.6),
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Script will appear here…',
                hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 13.sp),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () async {
              await vc.generateScript();
              if (vc.generatedScript.value.isNotEmpty) await _loadTts();
            },
            child: Container(
              height: 40.h,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.purple, AppColors.cyan]),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 15.w),
                  SizedBox(width: 6.w),
                  Text('Regenerate Script',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTtsPlayer(VideoController vc) {
    final loading = vc.isGeneratingTts.value;
    final pct = _dur.inMilliseconds > 0
        ? (_pos.inMilliseconds / _dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          // Waveform / play area
          Container(
            width: double.infinity, height: 80.h,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: loading
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24.w, height: 24.w,
                    child: const CircularProgressIndicator(
                        color: AppColors.cyan, strokeWidth: 2),
                  ),
                  SizedBox(height: 8.h),
                  Text('Generating voiceover…',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11.sp)),
                ],
              )
                  : GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 44.w, height: 44.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1.5),
                    color: Colors.black.withOpacity(0.4),
                  ),
                  child: Icon(
                    _isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24.w,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3.h,
              thumbShape:
              RoundSliderThumbShape(enabledThumbRadius: 8.w),
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: AppColors.cyan,
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: AppColors.cyan,
            ),
            child: Slider(
              value: pct.toDouble(),
              onChanged: _audioReady
                  ? (v) => _audio.seek(Duration(
                  milliseconds:
                  (v * _dur.inMilliseconds).round()))
                  : null,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_pos),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11.sp)),
                GestureDetector(
                  onTap: loading ? null : _loadTts,
                  child: Row(
                    children: [
                      Icon(Icons.refresh_rounded,
                          color: AppColors.cyan.withOpacity(0.8),
                          size: 14.w),
                      SizedBox(width: 4.w),
                      Text('Regenerate',
                          style: TextStyle(
                              color: AppColors.cyan.withOpacity(0.8),
                              fontSize: 11.sp)),
                    ],
                  ),
                ),
                Text(_fmt(_dur),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4  –  Generate Video + Preview
// ─────────────────────────────────────────────────────────────────────────────
class _PreviewStep extends StatefulWidget {
  final VoidCallback onBack;
  const _PreviewStep({Key? key, required this.onBack}) : super(key: key);
  @override
  State<_PreviewStep> createState() => _PreviewStepState();
}

class _PreviewStepState extends State<_PreviewStep> {
  VideoPlayerController? _vpc;
  bool _playerReady = false;
  bool _playerError = false;
  bool _videoStarted = false;

  @override
  void initState() {
    super.initState();
    // Kick off video generation as soon as we enter step 4
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vc = VideoController.to;
      if (!_videoStarted &&
          vc.currentProjectId.value.isNotEmpty &&
          !vc.isGeneratingVideo.value &&
          vc.videoStatus.value != 'video_completed') {
        _videoStarted = true;
        await vc.generateVideo();
      }
    });
  }

  Future<void> _initPlayer(String url) async {
    if (url.isEmpty || _playerReady) return;
    try {
      _vpc?.dispose();
      _vpc = VideoPlayerController.networkUrl(Uri.parse(url));
      await _vpc!.initialize();
      _vpc!.addListener(() { if (mounted) setState(() {}); });
      if (mounted) setState(() => _playerReady = true);
    } catch (e) {
      debugPrint('❌ init player: $e');
      if (mounted) setState(() => _playerError = true);
    }
  }

  @override
  void dispose() { _vpc?.dispose(); super.dispose(); }

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2,'0')}:'
          '${d.inSeconds.remainder(60).toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vc = VideoController.to;
      final generating =
          vc.isGeneratingVideo.value || vc.isPollingVideoStatus.value;

      // ── Generating: show avatar preview video + animation ────
      if (generating) {
        return _GenerationAnimation(
          step: vc.generationStep.value,
          avatarVideoUrl: vc.avatarPreviewVideoUrl.value,
        );
      }

      // ── Completed: init player once ───────────────────────────
      if (vc.videoStatus.value == 'video_completed' &&
          !_playerReady && !_playerError) {
        final url = vc.videoUrl.value.isNotEmpty
            ? vc.videoUrl.value
            : vc.videoFileUrl.value;
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _initPlayer(url));
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(showBack: true, onBack: widget.onBack,
                    showLogo: true),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                          title: 'Your marketing video',
                          subtitle:
                          'Your AI-generated video is ready to export'),
                      SizedBox(height: 16.h),
                      _buildStatusBanner(vc),
                      SizedBox(height: 12.h),
                      _buildVideoArea(vc),
                      SizedBox(height: 16.h),
                      _buildMeta(vc),
                    ],
                  ),
                ),
                const Spacer(),

                Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Center(
                    child: Text(
                      'Your video will be saved to your library after export',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 11.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStatusBanner(VideoController vc) {
    final status = vc.videoStatus.value;
    if (status.isEmpty) return const SizedBox();
    final ok = status == 'video_completed';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: ok
            ? Colors.green.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: ok
              ? Colors.green.withOpacity(0.4)
              : Colors.orange.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_outline : Icons.hourglass_top,
            color: ok ? Colors.green : Colors.orange,
            size: 16.w,
          ),
          SizedBox(width: 8.w),
          Text(
            ok
                ? 'Video ready! Tap Export to save.'
                : status.replaceAll('_', ' '),
            style: TextStyle(
                color: ok ? Colors.green : Colors.orange,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoArea(VideoController vc) {
    if (_playerError) {
      return Container(
        height: 220.h,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: Colors.red.shade400, size: 32.w),
              SizedBox(height: 8.h),
              Text('Could not load video',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13.sp)),
            ],
          ),
        ),
      );
    }
    if (!_playerReady || _vpc == null || !_vpc!.value.isInitialized) {
      return Container(
        height: 220.h,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: const Center(
          child: CircularProgressIndicator(
              color: AppColors.cyan, strokeWidth: 2),
        ),
      );
    }

    final ctrl = _vpc!;
    final pos  = ctrl.value.position;
    final dur  = ctrl.value.duration;
    final pct  = dur.inMilliseconds > 0
        ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.r),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: ctrl.value.aspectRatio.clamp(0.5, 2.2),
                  child: VideoPlayer(ctrl),
                ),
                GestureDetector(
                  onTap: () {
                    ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
                    setState(() {});
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedOpacity(
                    opacity: ctrl.value.isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 54.w, height: 54.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.7),
                            width: 1.5),
                      ),
                      child: Icon(
                        ctrl.value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white, size: 30.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              color: const Color(0xFF0E0E0E),
              padding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 10.h),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3.h,
                      thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 7.w),
                      overlayShape: SliderComponentShape.noOverlay,
                      activeTrackColor: AppColors.cyan,
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                      thumbColor: AppColors.cyan,
                    ),
                    child: Slider(
                      value: pct.toDouble(),
                      onChanged: (v) => ctrl.seekTo(Duration(
                          milliseconds:
                          (v * dur.inMilliseconds).round())),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_fmt(pos),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11.sp)),
                      Icon(Icons.fullscreen,
                          color: Colors.white.withOpacity(0.5),
                          size: 20.w),
                      Text(_fmt(dur),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11.sp)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeta(VideoController vc) {
    final title = vc.titleController.text.isNotEmpty
        ? vc.titleController.text
        : '${vc.selectedIndustry.value} Marketing Video';
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600)),
        ),
        Icon(Icons.edit_outlined,
            color: Colors.white.withOpacity(0.5), size: 18.w),
      ],
    );
  }

  Widget _buildExportButton(VideoController vc) {
    final ready = vc.videoStatus.value == 'video_completed';
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: GestureDetector(
        onTap: ready ? () {} : null,
        child: Opacity(
          opacity: ready ? 1.0 : 0.45,
          child: Container(
            height: 52.h, width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                  color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (b) =>
                    const LinearGradient(
                        colors: [AppColors.purple, AppColors.cyan])
                        .createShader(b),
                blendMode: BlendMode.srcIn,
                child: Text(
                  ready ? 'Export Video' : 'Waiting for video…',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GENERATION ANIMATION
// Upper half: avatar_preview_video_url (looping video)
// Lower half: step info + progress bar + dots + tip
// ─────────────────────────────────────────────────────────────────────────────
class _GenerationAnimation extends StatefulWidget {
  final int step;
  final String avatarVideoUrl;
  const _GenerationAnimation(
      {Key? key, required this.step, required this.avatarVideoUrl})
      : super(key: key);
  @override
  State<_GenerationAnimation> createState() =>
      _GenerationAnimationState();
}

class _GenerationAnimationState extends State<_GenerationAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotCtrl;
  late AnimationController _pulCtrl;
  late AnimationController _proCtrl;
  late AnimationController _parCtrl;
  late Animation<double> _pulAnim;
  late Animation<double> _proAnim;

  VideoPlayerController? _avc;
  bool _avReady = false;

  static const _info = [
    ['Starting…',            'Initializing your project'],
    ['Project created ✓',    'Details saved'],
    ['Writing script…',      'AI crafting your message'],
    ['Rendering video…',     'Avatar & voice being merged (~1 min)'],
    ['Encoding…',            'Processing and uploading'],
    ['Done! 🎉',             'Your video has been generated'],
  ];

  @override
  void initState() {
    super.initState();
    _rotCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))..repeat();
    _pulCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _proCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _parCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))..repeat();

    _pulAnim = Tween<double>(begin: 0.88, end: 1.12).animate(
        CurvedAnimation(parent: _pulCtrl, curve: Curves.easeInOut));
    _proAnim = Tween<double>(
        begin: 0, end: (widget.step / 5).clamp(0.0, 1.0))
        .animate(CurvedAnimation(
        parent: _proCtrl, curve: Curves.easeOut));
    _proCtrl.forward();

    if (widget.avatarVideoUrl.isNotEmpty) _loadAvatarVideo();
  }

  Future<void> _loadAvatarVideo() async {
    try {
      _avc = VideoPlayerController.networkUrl(
          Uri.parse(widget.avatarVideoUrl));
      await _avc!.initialize();
      _avc!.setLooping(true);
      _avc!.play();
      if (mounted) setState(() => _avReady = true);
    } catch (e) {
      debugPrint('❌ avatar preview video: $e');
    }
  }

  @override
  void didUpdateWidget(_GenerationAnimation old) {
    super.didUpdateWidget(old);
    if (old.step != widget.step) {
      _proAnim = Tween<double>(
          begin: _proAnim.value,
          end: (widget.step / 5).clamp(0.0, 1.0))
          .animate(CurvedAnimation(
          parent: _proCtrl, curve: Curves.easeOut));
      _proCtrl..reset()..forward();
    }
    if (widget.step >= 5) {
      _rotCtrl.stop(); _pulCtrl.stop(); _parCtrl.stop();
      _avc?.pause();
    }
  }

  @override
  void dispose() {
    _rotCtrl.dispose(); _pulCtrl.dispose();
    _proCtrl.dispose(); _parCtrl.dispose();
    _avc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.step >= 5;
    final s = widget.step.clamp(0, _info.length - 1);

    return SizedBox.expand(
      child: Stack(
        children: [
          // Particles background
          AnimatedBuilder(
            animation: _parCtrl,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(_parCtrl.value),
              size: MediaQuery.of(context).size,
            ),
          ),

          Column(
            children: [
              // ── TOP: Avatar preview video ────────────────────
              Expanded(
                flex: 5,
                child: _avReady && !isDone
                    ? Container(
                  margin: EdgeInsets.fromLTRB(
                      16.w, 20.h, 16.w, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                        color: AppColors.cyan.withOpacity(0.35),
                        width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        VideoPlayer(_avc!),
                        // "Avatar Preview" badge
                        Positioned(
                          top: 10.h, left: 10.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius:
                              BorderRadius.circular(20.r),
                              border: Border.all(
                                  color: AppColors.cyan
                                      .withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_circle_outline,
                                    color: AppColors.cyan,
                                    size: 12.w),
                                SizedBox(width: 4.w),
                                Text('Avatar Preview',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.sp,
                                        fontWeight:
                                        FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    : Center(child: _buildIcon(isDone)),
              ),

              // ── BOTTOM: Progress + info ───────────────────────
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 28.w, vertical: 16.h),
                    child: Column(
                      children: [
                        // Title
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(_info[s][0],
                              key: ValueKey(widget.step),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700)),
                        ),
                        SizedBox(height: 6.h),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(_info[s][1],
                              key: ValueKey('s${widget.step}'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 13.sp,
                                  height: 1.4)),
                        ),
                        SizedBox(height: 24.h),

                        // Progress bar
                        AnimatedBuilder(
                          animation: _proAnim,
                          builder: (_, __) {
                            final pct = _proAnim.value;
                            return Column(
                              children: [
                                Container(
                                  height: 7.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius:
                                    BorderRadius.circular(10.r),
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(10.r),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: pct,
                                      child: Container(
                                        decoration:
                                        const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.purple,
                                              AppColors.cyan,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text('${(pct * 100).toInt()}%',
                                    style: TextStyle(
                                        color: AppColors.cyan,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w700)),
                              ],
                            );
                          },
                        ),

                        SizedBox(height: 20.h),

                        // Step dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final done = widget.step > i;
                            final cur  = widget.step == i + 1;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: cur ? 26.w : 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.r),
                                gradient: done || cur
                                    ? const LinearGradient(colors: [
                                  AppColors.purple, AppColors.cyan,
                                ])
                                    : null,
                                color: done || cur
                                    ? null
                                    : Colors.white.withOpacity(0.15),
                              ),
                            );
                          }),
                        ),

                        SizedBox(height: 20.h),

                        if (!isDone)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.tips_and_updates_outlined,
                                    color: AppColors.cyan, size: 16.w),
                                SizedBox(width: 10.w),
                                Expanded(
                                  child: Text(
                                    'Video generation takes ~1–2 minutes. '
                                        'Watch your avatar preview above!',
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(bool isDone) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotCtrl, _pulCtrl]),
      builder: (_, __) => Transform.scale(
        scale: isDone ? 1.0 : _pulAnim.value,
        child: Transform.rotate(
          angle: isDone ? 0 : _rotCtrl.value * 2 * math.pi,
          child: Container(
            width: 80.w, height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppColors.purple, AppColors.cyan],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(color: AppColors.cyan.withOpacity(0.5),
                    blurRadius: 28, spreadRadius: 3),
              ],
            ),
            child: Icon(
              isDone ? Icons.check_rounded : Icons.movie_creation_outlined,
              color: Colors.white, size: 36.w,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PARTICLE PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;
  static final _pts = List.generate(20, (i) => _P(
    x: (i * 0.137 + 0.05) % 1.0, y: (i * 0.193 + 0.03) % 1.0,
    r: 1.5 + (i % 4) * 1.1, speed: 0.10 + (i % 5) * 0.04,
    phase: i * 0.32, opacity: 0.12 + (i % 4) * 0.06,
  ));
  _ParticlePainter(this.progress);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _pts) {
      final t = (progress * p.speed + p.phase) % 1.0;
      canvas.drawCircle(
        Offset(p.x * size.width, ((p.y + t) % 1.0) * size.height), p.r,
        Paint()..color = AppColors.cyan.withOpacity(p.opacity * (1 - t * 0.6)),
      );
    }
  }
  @override bool shouldRepaint(_ParticlePainter o) => o.progress != progress;
}
class _P {
  final double x, y, r, speed, phase, opacity;
  const _P({required this.x, required this.y, required this.r,
    required this.speed, required this.phase, required this.opacity});
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final bool showBack, showMenu, showLogo;
  final VoidCallback? onBack, onMenuTap;
  const _TopBar({Key? key, required this.showBack,
    this.showMenu = false, this.showLogo = false,
    this.onBack, this.onMenuTap}) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
    child: Row(
      children: [
        if (showBack)
          GestureDetector(onTap: onBack,
              child: Icon(Icons.chevron_left, color: Colors.white, size: 28.w)),
        if (showMenu)
          GestureDetector(onTap: onMenuTap,
              child: Icon(Icons.menu, color: Colors.white, size: 26.w)),
        if (showLogo) Expanded(child: Center(
          child: Image.asset('assets/images/auth/logo.png',
              errorBuilder: (_, __, ___) => Text('NO FACE ADS',
                  style: TextStyle(color: Colors.white, fontSize: 15.sp,
                      fontWeight: FontWeight.w700, letterSpacing: 1.2))),
        )),
        if (showLogo) SizedBox(width: 22.w),
      ],
    ),
  );
}

class _StepIndicator extends StatelessWidget {
  final int current, total;
  const _StepIndicator({Key? key, required this.current, required this.total})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final done = i < current;
        final active = i == current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3.h,
            margin: EdgeInsets.only(right: i < total - 1 ? 4.w : 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.r),
              gradient: done || active
                  ? const LinearGradient(
                  colors: [AppColors.purple, AppColors.cyan])
                  : null,
              color: done || active ? null : Colors.white.withOpacity(0.15),
            ),
          ),
        );
      }),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title; final String? subtitle;
  const _SectionTitle({Key? key, required this.title, this.subtitle})
      : super(key: key);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(color: Colors.white, fontSize: 18.sp,
          fontWeight: FontWeight.w700)),
      if (subtitle != null) ...[
        SizedBox(height: 4.h),
        Text(subtitle!, style: TextStyle(
            color: Colors.white.withOpacity(0.45), fontSize: 13.sp, height: 1.5)),
      ],
    ],
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(color: Colors.white.withOpacity(0.7),
          fontSize: 13.sp, fontWeight: FontWeight.w600));
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _InputField({Key? key, required this.controller,
    required this.hint, this.maxLines = 1}) : super(key: key);
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.white.withOpacity(0.1)),
    ),
    child: TextField(
      controller: controller, maxLines: maxLines,
      style: TextStyle(color: Colors.white, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13.sp),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      ),
    ),
  );
}

class _HintCard extends StatelessWidget {
  final IconData icon; final String text;
  const _HintCard({Key? key, required this.icon, required this.text})
      : super(key: key);
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: AppColors.cyan.withOpacity(0.07),
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: AppColors.cyan.withOpacity(0.2)),
    ),
    child: Row(children: [
      Icon(icon, color: AppColors.cyan, size: 16.w),
      SizedBox(width: 10.w),
      Expanded(child: Text(text, style: TextStyle(
          color: Colors.white.withOpacity(0.75), fontSize: 12.sp, height: 1.5))),
    ]),
  );
}

class _SelectDot extends StatelessWidget {
  final bool selected;
  const _SelectDot({Key? key, required this.selected}) : super(key: key);
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: 24.w, height: 24.w,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: selected
          ? const LinearGradient(colors: [AppColors.purple, AppColors.cyan])
          : null,
      border: Border.all(
        color: selected ? Colors.transparent : Colors.white.withOpacity(0.2),
        width: 1.5,
      ),
    ),
    child: selected ? Icon(Icons.check, color: Colors.white, size: 14.w) : null,
  );
}

class _BottomButton extends StatelessWidget {
  final String label; final VoidCallback? onTap;
  const _BottomButton({Key? key, required this.label, required this.onTap})
      : super(key: key);
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
    child: GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          height: 52.h, width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                  colors: [AppColors.purple, AppColors.cyan]).createShader(b),
              blendMode: BlendMode.srcIn,
              child: Text(label, style: TextStyle(
                  color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    ),
  );
}

class _PinnedButton extends StatelessWidget {
  final VoidCallback onContinue;
  final bool isLoading;
  const _PinnedButton(
      {Key? key, required this.onContinue, required this.isLoading})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Colors.transparent, const Color(0xFF0A0A0A).withOpacity(0.97)],
      ),
    ),
    padding: EdgeInsets.fromLTRB(
        16.w, 24.h, 16.w,
        MediaQuery.of(context).padding.bottom + 16.h),
    child: GestureDetector(
      onTap: isLoading ? null : onContinue,
      child: AnimatedOpacity(
        opacity: isLoading ? 0.6 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 52.h,
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(30.r),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                width: 20.w, height: 20.w,
                child: const CircularProgressIndicator(
                    color: AppColors.cyan, strokeWidth: 2))
                : ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                  colors: [AppColors.purple, AppColors.cyan])
                  .createShader(b),
              blendMode: BlendMode.srcIn,
              child: Text('Continue',
                  style: TextStyle(
                      color: Colors.white, fontSize: 15.sp,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    ),
  );
}
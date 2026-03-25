// lib/feature/video/screen/video_creation_flow_screen.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../color/app_color.dart';
import '../controller/video_controller.dart';
import 'app_drawer_controller.dart';

class VideoCreationFlowScreen extends StatefulWidget {
  const VideoCreationFlowScreen({Key? key}) : super(key: key);

  @override
  State<VideoCreationFlowScreen> createState() =>
      _VideoCreationFlowScreenState();
}

class _VideoCreationFlowScreenState
    extends State<VideoCreationFlowScreen> {
  int _step = 0;

  @override
  void initState() {
    super.initState();
    final vc = VideoController.to;
    vc.fetchAvatars();
    vc.fetchBackgrounds();
    // NOTE: generateScript is NOT called here anymore.
    // It's called only AFTER updateProjectDetails() succeeds in Step 1.
  }

  void _next() {
    if (_step < 3) setState(() => _step++);
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
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
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                  parent: animation, curve: Curves.easeOutCubic));
              return SlideTransition(position: offset, child: child);
            },
            child: _buildCurrentStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0:
      // Step 1: Avatar + Title + Service Description
      // On continue:
      //   1. PATCH title, service_description, avatar_id
      //   2. POST generate-script
      //   3. Navigate to voiceover
        return _AvatarStep(
          key: const ValueKey(0),
          onContinue: () async {
            final vc = VideoController.to;
            final ok = await vc.updateProjectDetails();
            if (!ok) return; // validation failed, stay on step
            await vc.generateScript();
            if (vc.generatedScript.value.isNotEmpty) {
              _next();
            }
          },
        );
      case 1:
      // Step 2: Voiceover preview + script review
        return _VoiceoverStep(
            key: const ValueKey(1),
            onContinue: () async {
              await VideoController.to.finalizeScript();
              _next();
            },
            onBack: _back);
      case 2:
      // Step 3: Background selection
        return _BackgroundStep(
          key: const ValueKey(2),
          onContinue: () async {
            await VideoController.to.generateVideo();
            _next();
          },
          onBack: _back,
        );
      case 3:
      // Step 4: Preview + Export (or generation animation)
        return _PreviewStep(key: const ValueKey(3), onBack: _back);
      default:
        return _AvatarStep(key: const ValueKey(0), onContinue: _next);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 — Avatar + Title + Service Description
// ─────────────────────────────────────────────────────────────────────────────
class _AvatarStep extends StatefulWidget {
  final VoidCallback onContinue;
  const _AvatarStep({Key? key, required this.onContinue}) : super(key: key);

  @override
  State<_AvatarStep> createState() => _AvatarStepState();
}

class _AvatarStepState extends State<_AvatarStep> {
  bool _outfitDropdownOpen = false;

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
                  showBack: false,
                  showMenu: true,
                  showLogo: true,
                  onMenuTap: () =>
                      Get.find<AppDrawerController>().open()),
              Obx(() => _buildCategoryChips(vc)),
              SizedBox(height: 20.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Title field ───────────────────────────
                    _SectionTitle(
                        title: 'Video Title',
                        subtitle: 'Give your marketing video a name'),
                    SizedBox(height: 10.h),
                    _buildInputField(
                      controller: vc.titleController,
                      hint: 'e.g. Summer Marketing Campaign',
                    ),
                    SizedBox(height: 20.h),

                    // ── Service Description field ─────────────
                    _SectionTitle(
                        title: 'Service Description',
                        subtitle:
                        'Describe what you offer — the AI uses this to write your script'),
                    SizedBox(height: 10.h),
                    _buildInputField(
                      controller: vc.serviceDescController,
                      hint:
                      'e.g. We help brands scale their digital presence through SEO and social media.',
                      maxLines: 3,
                    ),
                    SizedBox(height: 24.h),

                    // ── Avatar ────────────────────────────────
                    _SectionTitle(
                        title: 'Choose your avatar',
                        subtitle:
                        'These avatars are generated exclusively for you'),
                    SizedBox(height: 16.h),
                    Obx(() => _buildAvatarRow(vc)),
                    SizedBox(height: 24.h),

                    _SectionTitle(
                        title: "Choose your avatar's outfit",
                        subtitle: null),
                    SizedBox(height: 10.h),
                    Obx(() => _buildOutfitDropdown(vc)),
                    SizedBox(height: 16.h),

                    // ── Hint about script generation ──────────
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                            color: AppColors.cyan.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome,
                              color: AppColors.cyan, size: 16.w),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'Fill in the title, description and select an avatar, '
                                  'then tap Continue to generate your AI script.',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12.sp,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),

              Obx(() => _BottomButton(
                label: vc.isLoading.value || vc.isGeneratingScript.value
                    ? 'Generating script...'
                    : 'Continue',
                onTap:
                vc.isLoading.value || vc.isGeneratingScript.value
                    ? null
                    : widget.onContinue,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: Colors.white, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.3), fontSize: 13.sp),
          border: InputBorder.none,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(VideoController vc) {
    final categories = vc.avatars.keys.toList();
    if (categories.isEmpty) return SizedBox(height: 36.h);
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final bool active = vc.selectedOutfit.value == categories[i];
          return GestureDetector(
            onTap: () => vc.selectedOutfit.value = categories[i],
            child: Container(
              padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
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
              child: Text(
                _capitalize(categories[i]),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight:
                  active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarRow(VideoController vc) {
    if (vc.isFetchingAvatars.value) {
      return SizedBox(
        height: 110.h,
        child: const Center(
          child: CircularProgressIndicator(
              color: AppColors.cyan, strokeWidth: 2),
        ),
      );
    }
    final avatarList = vc.avatars[vc.selectedOutfit.value] ?? [];
    if (avatarList.isEmpty) {
      return SizedBox(
        height: 110.h,
        child: Center(
          child: Text('No avatars for this outfit',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13.sp)),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: avatarList.take(6).map((avatar) {
          final bool selected =
              vc.selectedAvatarId.value == avatar.avatarId;
          return GestureDetector(
            onTap: () => vc.updateAvatar(avatar.avatarId),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: 10.w),
              width: 100.w,
              height: 110.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: selected
                      ? AppColors.cyan
                      : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    avatar.previewImageUrl.isNotEmpty
                        ? Image.network(
                      avatar.previewImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _avatarFallback(),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return _avatarFallback();
                      },
                    )
                        : _avatarFallback(),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 4.h, horizontal: 4.w),
                        color: Colors.black.withOpacity(0.55),
                        child: Text(
                          avatar.avatarName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    if (selected)
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.cyan),
                          child: Icon(Icons.check,
                              color: Colors.white, size: 12.w),
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

  Widget _avatarFallback() => Container(
    color: const Color(0xFF1A1A1A),
    child: Icon(Icons.person,
        color: Colors.white.withOpacity(0.2), size: 36.w),
  );

  Widget _buildOutfitDropdown(VideoController vc) {
    final outfits = vc.avatars.keys.toList();
    if (outfits.isEmpty) return const SizedBox();
    return GestureDetector(
      onTap: () =>
          setState(() => _outfitDropdownOpen = !_outfitDropdownOpen),
      child: Column(
        children: [
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_capitalize(vc.selectedOutfit.value),
                    style: TextStyle(
                        color: Colors.white, fontSize: 14.sp)),
                Icon(
                  _outfitDropdownOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white.withOpacity(0.6),
                  size: 20.w,
                ),
              ],
            ),
          ),
          if (_outfitDropdownOpen)
            Container(
              margin: EdgeInsets.only(top: 2.h),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(10.r),
                border:
                Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: outfits.map((o) {
                  final bool sel = vc.selectedOutfit.value == o;
                  return GestureDetector(
                    onTap: () {
                      vc.selectedOutfit.value = o;
                      setState(() => _outfitDropdownOpen = false);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 12.h),
                      child: Text(
                        _capitalize(o),
                        style: TextStyle(
                          color: sel
                              ? AppColors.cyan
                              : Colors.white.withOpacity(0.8),
                          fontSize: 13.sp,
                          fontWeight: sel
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 — Voiceover + Script Preview
// ─────────────────────────────────────────────────────────────────────────────
class _VoiceoverStep extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  const _VoiceoverStep(
      {Key? key, required this.onContinue, required this.onBack})
      : super(key: key);

  @override
  State<_VoiceoverStep> createState() => _VoiceoverStepState();
}

class _VoiceoverStepState extends State<_VoiceoverStep> {
  double _sliderValue = 0.0;
  bool _isPlaying = false;

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
              _TopBar(showBack: true, onBack: widget.onBack),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                        title: 'AI voiceover',
                        subtitle:
                        'This voiceover will be used in your final marketing video'),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              color: AppColors.cyan, size: 14.w),
                          SizedBox(width: 6.w),
                          Text(
                            'Optimized for short-form ads (15–30 seconds)',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildWaveformPlayer(),
                    SizedBox(height: 28.h),
                    _SectionTitle(
                        title: 'Your AI Script',
                        subtitle: 'Edit before finalizing if needed'),
                    SizedBox(height: 12.h),
                    _buildScriptEditor(vc),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              Obx(() => _BottomButton(
                label: vc.isLoading.value
                    ? 'Saving script...'
                    : 'Continue',
                onTap: vc.isLoading.value ? null : widget.onContinue,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaveformPlayer() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0E0E0E),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 80.h,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: GestureDetector(
                onTap: () => setState(() => _isPlaying = !_isPlaying),
                child: Container(
                  width: 44.w,
                  height: 44.w,
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
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: Colors.white,
            ),
            child: Slider(
                value: _sliderValue,
                onChanged: (v) => setState(() => _sliderValue = v)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('00:00',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 11.sp)),
                Text('00:30',
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
          TextField(
            controller: vc.scriptController,
            style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13.sp,
                height: 1.6),
            maxLines: null,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Your script will appear here...',
              hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 13.sp),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: vc.generateScript,
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
                  Icon(Icons.refresh_rounded,
                      color: Colors.white, size: 15.w),
                  SizedBox(width: 6.w),
                  Text('Regenerate',
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
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3 — Choose Background (network images from Unsplash)
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundStep extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  const _BackgroundStep(
      {Key? key, required this.onContinue, required this.onBack})
      : super(key: key);

  static const Map<String, String> _bgImages = {
    'Modern Office':     'https://images.unsplash.com/photo-1497366216548-37526070297c?w=700&q=80',
    'City Skyline':      'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?w=700&q=80',
    'White Studio':      'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=700&q=80',
    'Nature Outdoor':    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=700&q=80',
    'Coffee Shop':       'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=700&q=80',
    'Classroom':         'https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=700&q=80',
    'Hospital':          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=700&q=80',
    'Gym':               'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=700&q=80',
    'Tech Startup':      'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=700&q=80',
    'Luxury Interior':   'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=700&q=80',
    'Warehouse':         'https://images.unsplash.com/photo-1553413077-190dd305871c?w=700&q=80',
    'Rooftop':           'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=700&q=80',
    'Library':           'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=700&q=80',
    'Abstract Gradient': 'https://images.unsplash.com/photo-1558591710-4b4a1ae0f04d?w=700&q=80',
    'Plain Color':       'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=700&q=80',
  };

  String _imageFor(String name) =>
      _bgImages[name] ??
          'https://images.unsplash.com/photo-1497366216548-37526070297c?w=700&q=80';

  @override
  Widget build(BuildContext context) {
    final vc = VideoController.to;
    // Extra bottom padding so Continue button is visible above bottom nav
    final double bottomPad =
        MediaQuery.of(context).padding.bottom + 100.h;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(showBack: true, onBack: onBack),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _SectionTitle(
              title: 'Choose background',
              subtitle: 'Select a background that matches your industry',
            ),
          ),
          SizedBox(height: 16.h),

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
                children: vc.backgrounds.map((bg) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _buildBgCard(vc, bg),
                  );
                }).toList(),
              ),
            );
          }),

          // Extra space so Continue clears bottom nav
          SizedBox(height: bottomPad),
        ],
      ),
    );
  }

  Widget _buildBgCard(VideoController vc, BackgroundModel bg) {
    return Obx(() {
      final bool selected = vc.selectedBackground.value == bg.name;
      return GestureDetector(
        onTap: () => vc.updateBackground(bg.name),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: selected
                  ? AppColors.cyan
                  : Colors.white.withOpacity(0.08),
              width: selected ? 2 : 1,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                  color: AppColors.cyan.withOpacity(0.3),
                  blurRadius: 14,
                  spreadRadius: 1)
            ]
                : [],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: Column(
              children: [
                // ── Network image ───────────────────────────
                SizedBox(
                  height: 120.h,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _imageFor(bg.name),
                        fit: BoxFit.cover,
                        loadingBuilder: (_, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFF1A1A1A),
                            child: const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.cyan,
                                  strokeWidth: 1.5),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF1A1A1A),
                          child: Icon(Icons.image_outlined,
                              color: Colors.white.withOpacity(0.15),
                              size: 32.w),
                        ),
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.45)
                            ],
                          ),
                        ),
                      ),
                      if (selected)
                        DecoratedBox(
                          decoration: BoxDecoration(
                              color: AppColors.cyan.withOpacity(0.12)),
                        ),
                    ],
                  ),
                ),

                // ── Info row ────────────────────────────────
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
                                      color:
                                      Colors.white.withOpacity(0.4),
                                      fontSize: 11.sp)),
                            ],
                          ],
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: selected
                              ? const LinearGradient(
                            colors: [
                              AppColors.purple,
                              AppColors.cyan
                            ],
                          )
                              : null,
                          border: Border.all(
                            color: selected
                                ? Colors.transparent
                                : Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                        ),
                        child: selected
                            ? Icon(Icons.check,
                            color: Colors.white, size: 14.w)
                            : null,
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
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4 — Preview / Generation Animation
// ─────────────────────────────────────────────────────────────────────────────
class _PreviewStep extends StatefulWidget {
  final VoidCallback onBack;
  const _PreviewStep({Key? key, required this.onBack}) : super(key: key);

  @override
  State<_PreviewStep> createState() => _PreviewStepState();
}

class _PreviewStepState extends State<_PreviewStep> {
  double _sliderValue = 0.0;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vc = VideoController.to;

      // ── Show animation while video is processing ───────────
      if (vc.isGeneratingVideo.value || vc.isPollingVideoStatus.value) {
        return _VideoGenerationAnimation(step: vc.generationStep.value);
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
                _TopBar(showBack: true, onBack: widget.onBack),
                SizedBox(height: 24.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionTitle(
                          title: 'Preview marketing video',
                          subtitle:
                          'Your AI-generated marketing video is ready'),
                      SizedBox(height: 16.h),
                      Obx(() => _buildStatusBanner(vc)),
                      SizedBox(height: 12.h),
                      _buildVideoPlayer(),
                      SizedBox(height: 16.h),
                      Obx(() => _buildVideoTitle(vc)),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),
                Obx(() => _buildExportButton(vc)),
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Center(
                    child: Text(
                      'Your video will be saved to your library after export',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 11.sp,
                          height: 1.5),
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
    final bool isComplete = status == 'video_completed';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isComplete
            ? Colors.green.withOpacity(0.12)
            : Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isComplete
              ? Colors.green.withOpacity(0.4)
              : Colors.orange.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isComplete
                ? Icons.check_circle_outline
                : Icons.hourglass_top,
            color: isComplete ? Colors.green : Colors.orange,
            size: 16.w,
          ),
          SizedBox(width: 8.w),
          Text(
            isComplete
                ? 'Video ready! You can now export.'
                : 'Status: ${status.replaceAll("_", " ")}',
            style: TextStyle(
              color: isComplete ? Colors.green : Colors.orange,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
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
                Container(
                  width: double.infinity,
                  height: 220.h,
                  color: const Color(0xFF1A1A1A),
                  child: Icon(Icons.movie_outlined,
                      color: Colors.white.withOpacity(0.1), size: 60.w),
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _isPlaying = !_isPlaying),
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.7),
                          width: 1.5),
                    ),
                    child: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28.w,
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
                      activeTrackColor: Colors.white,
                      inactiveTrackColor:
                      Colors.white.withOpacity(0.2),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                        value: _sliderValue,
                        onChanged: (v) =>
                            setState(() => _sliderValue = v)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('00:00',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11.sp)),
                      Icon(Icons.fullscreen,
                          color: Colors.white.withOpacity(0.5),
                          size: 20.w),
                      Text('00:30',
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

  Widget _buildVideoTitle(VideoController vc) {
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
    final bool isReady = vc.videoStatus.value == 'video_completed';
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: GestureDetector(
        onTap: isReady ? () {} : null,
        child: Opacity(
          opacity: isReady ? 1.0 : 0.45,
          child: Container(
            height: 52.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(30.r),
              border:
              Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.purple, AppColors.cyan],
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  isReady ? 'Export Video' : 'Waiting for video...',
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
// VIDEO GENERATION ANIMATION  🎬
// ─────────────────────────────────────────────────────────────────────────────
class _VideoGenerationAnimation extends StatefulWidget {
  final int step;
  const _VideoGenerationAnimation({Key? key, required this.step})
      : super(key: key);

  @override
  State<_VideoGenerationAnimation> createState() =>
      _VideoGenerationAnimationState();
}

class _VideoGenerationAnimationState
    extends State<_VideoGenerationAnimation>
    with TickerProviderStateMixin {

  late AnimationController _rotateCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _progressCtrl;
  late AnimationController _particleCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _progressAnim;

  static const List<Map<String, String>> _stepInfo = [
    {'title': 'Starting up…',            'sub': 'Initializing your project'},
    {'title': 'Project created ✓',       'sub': 'Moving to script generation'},
    {'title': 'Writing your script…',    'sub': 'AI is crafting your message'},
    {'title': 'Rendering your video…',   'sub': 'Avatar & voiceover are being merged — this takes ~1 min'},
    {'title': 'Processing & encoding…',  'sub': 'Almost there! Your video is being encoded'},
    {'title': 'Your video is ready! 🎉', 'sub': 'Tap Export to save your video'},
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
        .animate(CurvedAnimation(
        parent: _progressCtrl, curve: Curves.easeOut));

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
    if (widget.step == 5) {
      _rotateCtrl.stop();
      _pulseCtrl.stop();
      _particleCtrl.stop();
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
    final bool isDone = widget.step == 5;
    final int s = widget.step.clamp(0, _stepInfo.length - 1);
    final info = _stepInfo[s];

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // ── Particles ────────────────────────────────────────
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              painter: _ParticlePainter(_particleCtrl.value),
              size: Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height),
            ),
          ),

          // ── Main content ──────────────────────────────────────
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Rotating icon ────────────────────────────
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
                              BoxShadow(
                                  color:
                                  AppColors.purple.withOpacity(0.35),
                                  blurRadius: 20,
                                  spreadRadius: 2),
                            ],
                          ),
                          child: Center(
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
                  ),

                  SizedBox(height: 32.h),

                  // ── Title ─────────────────────────────────────
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      info['title']!,
                      key: ValueKey(widget.step),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      info['sub']!,
                      key: ValueKey('sub${widget.step}'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 13.sp,
                        height: 1.5,
                      ),
                    ),
                  ),

                  SizedBox(height: 36.h),

                  // ── Progress bar ──────────────────────────────
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
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.purple,
                                        AppColors.cyan
                                      ],
                                    ),
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
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 28.h),

                  // ── Step dots ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      final bool done = widget.step > i;
                      final bool cur = widget.step == i + 1;
                      return AnimatedContainer(
                        duration:
                        const Duration(milliseconds: 300),
                        margin:
                        EdgeInsets.symmetric(horizontal: 4.w),
                        width: cur ? 26.w : 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(4.r),
                          gradient: done || cur
                              ? const LinearGradient(colors: [
                            AppColors.purple,
                            AppColors.cyan
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

                  // ── Tip card ───────────────────────────────────
                  if (!isDone)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius:
                        BorderRadius.circular(12.r),
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
                                  'You can view the result in Your Videos once it\'s done.',
                              style: TextStyle(
                                  color:
                                  Colors.white.withOpacity(0.55),
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

// ── Particle painter ──────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final double progress;

  static final List<_Particle> _pts = List.generate(
    20,
        (i) => _Particle(
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
      final x = p.x * size.width;
      final y = ((p.y + t) % 1.0) * size.height;
      canvas.drawCircle(
        Offset(x, y),
        p.r,
        Paint()
          ..color =
          AppColors.cyan.withOpacity(p.opacity * (1 - t * 0.6))
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.progress != progress;
}

class _Particle {
  final double x, y, r, speed, phase, opacity;
  const _Particle(
      {required this.x,
        required this.y,
        required this.r,
        required this.speed,
        required this.phase,
        required this.opacity});
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool showBack;
  final bool showMenu;
  final bool showLogo;
  final VoidCallback? onBack;
  final VoidCallback? onMenuTap;

  const _TopBar({
    Key? key,
    required this.showBack,
    this.showMenu = false,
    this.showLogo = false,
    this.onBack,
    this.onMenuTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: Row(
        children: [
          if (showBack)
            GestureDetector(
              onTap: onBack,
              child: Icon(Icons.chevron_left,
                  color: Colors.white, size: 28.w),
            ),
          if (showMenu)
            GestureDetector(
              onTap: onMenuTap,
              child: Icon(Icons.menu, color: Colors.white, size: 26.w),
            ),
          if (showLogo)
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/auth/logo.png',
                  errorBuilder: (_, __, ___) => Text(
                    'NO FACE ADS',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2),
                  ),
                ),
              ),
            ),
          if (showLogo) SizedBox(width: 22.w),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionTitle({Key? key, required this.title, this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700)),
        if (subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(subtitle!,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 12.sp,
                  height: 1.5)),
        ],
      ],
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _BottomButton(
      {Key? key, required this.label, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
      child: GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.5 : 1.0,
          child: Container(
            height: 52.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(30.r),
              border:
              Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.purple, AppColors.cyan],
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(label,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// lib/feature/video/screen/video_creation_flow_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../color/app_color.dart';
import '../controller/video_controller.dart';

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
    final vc = VideoController.to;
    vc.fetchAvatars();
    vc.fetchBackgrounds();
    // Generate script as soon as we enter (project already created on HomeScreen)
    vc.generateScript();
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
                parent: animation,
                curve: Curves.easeOutCubic,
              ));
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
        return _AvatarStep(
          key: const ValueKey(0),
          onContinue: () async {
            // Finalize script before moving to voiceover
            await VideoController.to.finalizeScript();
            _next();
          },
        );
      case 1:
        return _VoiceoverStep(
          key: const ValueKey(1),
          onContinue: _next,
          onBack: _back,
        );
      case 2:
        return _BackgroundStep(
          key: const ValueKey(2),
          onContinue: () async {
            // Generate video then go to preview
            await VideoController.to.generateVideo();
            _next();
          },
          onBack: _back,
        );
      case 3:
        return _PreviewStep(key: const ValueKey(3), onBack: _back);
      default:
        return _AvatarStep(
          key: const ValueKey(0),
          onContinue: _next,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 — Choose Avatar + Script
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
    final VideoController vc = VideoController.to;

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
              const _TopBar(showBack: false, showMenu: true, showLogo: true),

              // ── Outfit category chips (from API avatar keys) ──────
              Obx(() => _buildCategoryChips(vc)),
              SizedBox(height: 20.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      title: 'Choose your avatar',
                      subtitle: 'These avatars are generated exclusively for you',
                    ),
                    SizedBox(height: 16.h),

                    // ── Avatar row (from API) ─────────────────────
                    Obx(() => _buildAvatarRow(vc)),
                    SizedBox(height: 24.h),

                    _SectionTitle(
                      title: "Choose your avatar's outfit",
                      subtitle: null,
                    ),
                    SizedBox(height: 10.h),

                    // ── Outfit dropdown ───────────────────────────
                    Obx(() => _buildOutfitDropdown(vc)),
                    SizedBox(height: 24.h),

                    _SectionTitle(
                      title: 'AI script generator',
                      subtitle: 'You can edit this script before continuing',
                    ),
                    SizedBox(height: 12.h),

                    // ── Script box ────────────────────────────────
                    Obx(() => _buildScriptBox(vc)),
                  ],
                ),
              ),
              SizedBox(height: 15.h),

              // ── Continue button ───────────────────────────────────
              Obx(() => _BottomButton(
                label: vc.isLoading.value ? 'Saving...' : 'Continue',
                onTap: vc.isLoading.value ? null : widget.onContinue,
              )),
            ],
          ),
        ),
      ),
    );
  }

  // Category chips = outfit categories from API avatar map keys
  Widget _buildCategoryChips(VideoController vc) {
    final categories = vc.avatars.keys.toList();
    if (categories.isEmpty) {
      // Fallback while loading
      return SizedBox(height: 36.h);
    }
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
              child: Text(
                _capitalize(categories[i]),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
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
          child: CircularProgressIndicator(color: AppColors.cyan, strokeWidth: 2),
        ),
      );
    }

    final avatarList = vc.avatars[vc.selectedOutfit.value] ?? [];
    if (avatarList.isEmpty) {
      return SizedBox(
        height: 110.h,
        child: Center(
          child: Text(
            'No avatars for this outfit',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13.sp,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: avatarList.take(5).map((avatar) {
          final bool selected = vc.selectedAvatarId.value == avatar.avatarId;
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
                  color: selected ? AppColors.cyan : Colors.transparent,
                  width: 2.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Network image from API
                    avatar.previewImageUrl.isNotEmpty
                        ? Image.network(
                      avatar.previewImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return _avatarFallback();
                      },
                    )
                        : _avatarFallback(),
                    // Name label at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 4.h, horizontal: 4.w),
                        color: Colors.black.withOpacity(0.5),
                        child: Text(
                          avatar.avatarName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    // Selected checkmark
                    if (selected)
                      Positioned(
                        top: 6.h,
                        right: 6.w,
                        child: Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.cyan,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12.w,
                          ),
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

  Widget _avatarFallback() {
    return Container(
      color: const Color(0xFF1A1A1A),
      child: Icon(
        Icons.person,
        color: Colors.white.withOpacity(0.2),
        size: 36.w,
      ),
    );
  }

  Widget _buildOutfitDropdown(VideoController vc) {
    final outfits = vc.avatars.keys.toList();
    if (outfits.isEmpty) return const SizedBox();

    return GestureDetector(
      onTap: () => setState(() => _outfitDropdownOpen = !_outfitDropdownOpen),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _capitalize(vc.selectedOutfit.value),
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                ),
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
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: outfits.map((o) {
                  final bool selected = vc.selectedOutfit.value == o;
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
                          color: selected
                              ? AppColors.cyan
                              : Colors.white.withOpacity(0.8),
                          fontSize: 13.sp,
                          fontWeight: selected
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

  Widget _buildScriptBox(VideoController vc) {
    if (vc.isGeneratingScript.value) {
      return Container(
        height: 100.h,
        decoration: BoxDecoration(
          color: const Color(0xFF111118),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.cyan,
            strokeWidth: 2,
          ),
        ),
      );
    }

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
          // Editable script text field
          TextField(
            controller: vc.scriptController,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13.sp,
              height: 1.6,
            ),
            maxLines: null,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: vc.generatedScript.value.isNotEmpty
                  ? null
                  : 'Generating script...',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 13.sp,
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          SizedBox(height: 14.h),
          // Regenerate button
          GestureDetector(
            onTap: vc.generateScript,
            child: Container(
              height: 44.h,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.purple, AppColors.cyan]),
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 16.w),
                  SizedBox(width: 6.w),
                  Text(
                    'Regenerate script',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
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

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 — AI Voiceover (TTS preview)
// ─────────────────────────────────────────────────────────────────────────────
class _VoiceoverStep extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  const _VoiceoverStep({
    Key? key,
    required this.onContinue,
    required this.onBack,
  }) : super(key: key);

  @override
  State<_VoiceoverStep> createState() => _VoiceoverStepState();
}

class _VoiceoverStepState extends State<_VoiceoverStep> {
  double _sliderValue = 0.0;
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final VideoController vc = VideoController.to;

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
                      'This voiceover will be used in your final marketing video',
                    ),
                    SizedBox(height: 16.h),
                    // Info chip
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(30.r),
                        border:
                        Border.all(color: Colors.white.withOpacity(0.12)),
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
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildWaveformPlayer(),
                    SizedBox(height: 28.h),
                    _SectionTitle(title: 'Script preview', subtitle: null),
                    SizedBox(height: 12.h),
                    // Show finalized script from controller
                    Obx(() => _buildScriptPreview(vc)),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              _BottomButton(label: 'Continue', onTap: widget.onContinue),
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
          // Waveform / play area
          Container(
            width: double.infinity,
            height: 90.h,
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
                        color: Colors.white.withOpacity(0.6), width: 1.5),
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
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.w),
              overlayShape: SliderComponentShape.noOverlay,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: _sliderValue,
              onChanged: (v) => setState(() => _sliderValue = v),
            ),
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

  Widget _buildScriptPreview(VideoController vc) {
    final script = vc.finalizedScript.value.isNotEmpty
        ? vc.finalizedScript.value
        : vc.generatedScript.value;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111118),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        script.isNotEmpty ? script : 'No script generated yet.',
        style: TextStyle(
          color: Colors.white.withOpacity(0.75),
          fontSize: 13.sp,
          height: 1.6,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3 — Choose Background (from API)
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundStep extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  const _BackgroundStep({
    Key? key,
    required this.onContinue,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VideoController vc = VideoController.to;

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

              // ── Background list from API ────────────────────────
              Obx(() {
                if (vc.isFetchingBackgrounds.value) {
                  return SizedBox(
                    height: 200.h,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.cyan,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: vc.backgrounds.asMap().entries.map((e) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildBgCard(vc, e.value, e.key),
                      );
                    }).toList(),
                  ),
                );
              }),

              SizedBox(height: 15.h),

              // ── Continue — call API to save background ──────────
              Obx(() => _BottomButton(
                label: vc.isLoading.value ? 'Saving...' : 'Continue',
                onTap: vc.isLoading.value ? null : onContinue,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBgCard(VideoController vc, BackgroundModel bg, int index) {
    final bool selected = vc.selectedBackground.value == bg.name;
    return GestureDetector(
      onTap: () => vc.updateBackground(bg.name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AppColors.cyan : Colors.white.withOpacity(0.08),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: AppColors.cyan.withOpacity(0.3),
              blurRadius: 12,
            )
          ]
              : [],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            children: [
              // Icon
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  gradient: selected
                      ? const LinearGradient(
                      colors: [AppColors.purple, AppColors.cyan])
                      : null,
                  color: selected ? null : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: selected ? Colors.white : Colors.white.withOpacity(0.4),
                  size: 20.w,
                ),
              ),
              SizedBox(width: 14.w),
              // Name + description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bg.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      bg.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              // Selected indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: selected
                      ? const LinearGradient(
                      colors: [AppColors.purple, AppColors.cyan])
                      : null,
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : Colors.white.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? Icon(Icons.check, color: Colors.white, size: 13.w)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4 — Preview + Export
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
    final VideoController vc = VideoController.to;

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
                      'This is how your final AI-generated marketing video will look and sound',
                    ),
                    SizedBox(height: 16.h),

                    // ── Video status banner ───────────────────────
                    Obx(() => _buildStatusBanner(vc)),
                    SizedBox(height: 12.h),

                    _buildVideoPlayer(),
                    SizedBox(height: 16.h),

                    // ── Video title from controller ───────────────
                    Obx(() => _buildVideoTitle(vc)),
                  ],
                ),
              ),
              SizedBox(height: 30.h),

              // ── Export button ─────────────────────────────────
              Obx(() => _buildExportButton(vc)),

              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Center(
                  child: Text(
                    'Your video will be saved to your library\nafter export',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.35),
                      fontSize: 11.sp,
                      height: 1.5,
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
            isComplete ? Icons.check_circle_outline : Icons.hourglass_top,
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
                  child: Icon(
                    Icons.movie_outlined,
                    color: Colors.white.withOpacity(0.1),
                    size: 60.w,
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _isPlaying = !_isPlaying),
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.7), width: 1.5),
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
              padding:
              EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3.h,
                      thumbShape:
                      RoundSliderThumbShape(enabledThumbRadius: 7.w),
                      overlayShape: SliderComponentShape.noOverlay,
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: _sliderValue,
                      onChanged: (v) => setState(() => _sliderValue = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('00:00',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11.sp)),
                      GestureDetector(
                        onTap: () {},
                        child: Icon(
                          Icons.fullscreen,
                          color: Colors.white.withOpacity(0.5),
                          size: 20.w,
                        ),
                      ),
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
        : vc.selectedIndustry.value.isNotEmpty
        ? vc.selectedIndustry.value
        : 'My Marketing Video';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Icon(Icons.edit_outlined,
            color: Colors.white.withOpacity(0.5), size: 18.w),
      ],
    );
  }

  Widget _buildExportButton(VideoController vc) {
    final bool isReady = vc.videoStatus.value == 'video_completed';
    final bool isProcessing =
        vc.isGeneratingVideo.value || vc.isPollingVideoStatus.value;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: GestureDetector(
        onTap: isReady && !isProcessing ? () {} : null,
        child: Opacity(
          opacity: isReady ? 1.0 : 0.45,
          child: Container(
            height: 52.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: isProcessing
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: const CircularProgressIndicator(
                      color: AppColors.cyan,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Processing video...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              )
                  : ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.purple, AppColors.cyan],
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  isReady ? 'Export' : 'Waiting for video...',
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
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final bool showBack;
  final bool showMenu;
  final bool showLogo;
  final VoidCallback? onBack;

  const _TopBar({
    Key? key,
    required this.showBack,
    this.showMenu = false,
    this.showLogo = false,
    this.onBack,
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
              child: Icon(Icons.chevron_left, color: Colors.white, size: 28.w),
            ),
          if (showMenu)
            GestureDetector(
              onTap: () {},
              child: Icon(Icons.menu, color: Colors.white, size: 22.w),
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
                      letterSpacing: 1.2,
                    ),
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
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(
            subtitle!,
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _BottomButton({Key? key, required this.label, required this.onTap})
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
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.purple, AppColors.cyan],
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  label,
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
      ),
    );
  }
}
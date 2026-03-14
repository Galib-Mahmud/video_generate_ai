import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../color/app_color.dart';

class VideoCreationFlowScreen extends StatefulWidget {
  const VideoCreationFlowScreen({Key? key}) : super(key: key);

  @override
  State<VideoCreationFlowScreen> createState() =>
      _VideoCreationFlowScreenState();
}

class _VideoCreationFlowScreenState extends State<VideoCreationFlowScreen> {
  int _step = 0;

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
              final offsetAnimation = Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));
              return SlideTransition(position: offsetAnimation, child: child);
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
        return _AvatarStep(key: const ValueKey(0), onContinue: _next);
      case 1:
        return _VoiceoverStep(key: const ValueKey(1), onContinue: _next, onBack: _back);
      case 2:
        return _BackgroundStep(key: const ValueKey(2), onContinue: _next, onBack: _back);
      case 3:
        return _PreviewStep(key: const ValueKey(3), onBack: _back);
      default:
        return _AvatarStep(key: const ValueKey(0), onContinue: _next);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 — Choose Avatar
// ─────────────────────────────────────────────────────────────────────────────
class _AvatarStep extends StatefulWidget {
  final VoidCallback onContinue;
  const _AvatarStep({Key? key, required this.onContinue}) : super(key: key);

  @override
  State<_AvatarStep> createState() => _AvatarStepState();
}

class _AvatarStepState extends State<_AvatarStep> {
  int _selectedAvatar = 1;
  String _selectedOutfit = 'Business';
  bool _outfitDropdownOpen = false;

  final List<String> _outfits = ['Business', 'Casual', 'Sports', 'Formal', 'Creative'];
  final List<String> _categories = ['Health & Fitness', 'Real estate & Local Services', 'Beauty'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(showBack: false, showMenu: true, showLogo: true),
              _buildCategoryChips(),
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
                    _buildAvatarRow(),
                    SizedBox(height: 24.h),
                    _SectionTitle(title: "Choose your avatar's outfit", subtitle: null),
                    SizedBox(height: 10.h),
                    _buildOutfitDropdown(),
                    SizedBox(height: 24.h),
                    _SectionTitle(
                      title: 'AI script generator',
                      subtitle: 'You can edit this script before continuing',
                    ),
                    SizedBox(height: 12.h),
                    _buildScriptBox(),
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

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final bool active = i == 0;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: active
                  ? const LinearGradient(colors: [Color(0xFF7B2FF7), Color(0xFF00C2CB)])
                  : null,
              color: active ? null : const Color(0xFF1C1C1C),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: active ? Colors.transparent : Colors.white.withOpacity(0.12),
              ),
            ),
            child: Text(
              _categories[i],
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarRow() {
    return Row(
      children: List.generate(3, (i) {
        final bool selected = _selectedAvatar == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedAvatar = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsets.only(right: 10.w),
            width: 100.w,
            height: 110.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: selected ? const Color(0xFF00C2CB) : Colors.transparent,
                width: 2.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(
                'assets/images/avatars/avatar_${i + 1}.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1A1A1A),
                  child: Icon(Icons.person, color: Colors.white.withOpacity(0.2), size: 36.w),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOutfitDropdown() {
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
                Text(_selectedOutfit, style: TextStyle(color: Colors.white, fontSize: 14.sp)),
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
                children: _outfits.map((o) {
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedOutfit = o;
                      _outfitDropdownOpen = false;
                    }),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Text(
                        o,
                        style: TextStyle(
                          color: _selectedOutfit == o
                              ? const Color(0xFF00C2CB)
                              : Colors.white.withOpacity(0.8),
                          fontSize: 13.sp,
                          fontWeight: _selectedOutfit == o ? FontWeight.w600 : FontWeight.w400,
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

  Widget _buildScriptBox() {
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
          Text(
            'Ready to transform your fitness journey?At PowerFlex Gym, we help you train smarter, feel stronger, and reach your goals faster.Join a community built around real results and expert guidance.Start today — your strongest self begins here.',
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13.sp, height: 1.6),
          ),
          SizedBox(height: 14.h),
          Container(
            height: 44.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7B2FF7), Color(0xFF00C2CB)]),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit_outlined, color: Colors.white, size: 16.w),
                SizedBox(width: 6.w),
                Text('Edit script',
                    style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 — AI Voiceover
// ─────────────────────────────────────────────────────────────────────────────
class _VoiceoverStep extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  const _VoiceoverStep({Key? key, required this.onContinue, required this.onBack}) : super(key: key);

  @override
  State<_VoiceoverStep> createState() => _VoiceoverStepState();
}

class _VoiceoverStepState extends State<_VoiceoverStep> {
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
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
                      subtitle: 'This voiceover will be used in your final marketing video',
                    ),
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161616),
                        borderRadius: BorderRadius.circular(30.r),
                        border: Border.all(color: Colors.white.withOpacity(0.12)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: const Color(0xFF00C2CB), size: 14.w),
                          SizedBox(width: 6.w),
                          Text(
                            'Optimized for short-form ads (15–30 seconds)',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildWaveformPlayer(),
                    SizedBox(height: 28.h),
                    _SectionTitle(title: 'Script preview', subtitle: null),
                    SizedBox(height: 12.h),
                    _buildScriptPreview(),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.asset(
              'assets/images/home/waveform.png',
              width: double.infinity,
              height: 90.h,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 90.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
                      color: Colors.black.withOpacity(0.4),
                    ),
                    child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24.w),
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
            child: Slider(value: _sliderValue, onChanged: (v) => setState(() => _sliderValue = v)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('00:15', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11.sp)),
                Text('00:30', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScriptPreview() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111118),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Text(
        'Ready to transform your fitness journey?At PowerFlex Gym, we help you train smarter, feel stronger, and reach your goals faster.Join a community built around real results and expert guidance.Start today — your strongest self begins here.',
        style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13.sp, height: 1.6),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3 — Choose Background
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundStep extends StatefulWidget {
  final VoidCallback onContinue;
  final VoidCallback onBack;
  const _BackgroundStep({Key? key, required this.onContinue, required this.onBack}) : super(key: key);

  @override
  State<_BackgroundStep> createState() => _BackgroundStepState();
}

class _BackgroundStepState extends State<_BackgroundStep> {
  int _selectedBg = 0;

  final List<Map<String, String>> _backgrounds = [
    {'image': 'assets/images/home/background1.png'},
    {'image': 'assets/images/home/background2.png'},
    {'image': 'assets/images/home/background3.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TopBar(showBack: true, onBack: widget.onBack),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _SectionTitle(
                  title: 'Choose background',
                  subtitle: 'Select a background that matches your industry',
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: List.generate(_backgrounds.length, (i) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildBgCard(_backgrounds[i], i),
                    );
                  }),
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

  Widget _buildBgCard(Map<String, String> bg, int index) {
    final bool selected = _selectedBg == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedBg = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 130.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? const Color(0xFF00C2CB) : Colors.transparent,
            width: 2,
          ),
          boxShadow: selected
              ? [BoxShadow(color: const Color(0xFF00C2CB).withOpacity(0.3), blurRadius: 12)]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Image.asset(
            bg['image']!,
            width: double.infinity,
            height: 130.h,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF1A1A1A),
              child: Icon(Icons.image_outlined, color: Colors.white.withOpacity(0.2), size: 32.w),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4 — Preview Marketing Video
// ─────────────────────────────────────────────────────────────────────────────
class _PreviewStep extends StatefulWidget {
  final VoidCallback onBack;
  const _PreviewStep({Key? key, required this.onBack}) : super(key: key);

  @override
  State<_PreviewStep> createState() => _PreviewStepState();
}

class _PreviewStepState extends State<_PreviewStep> {
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
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
                      subtitle: 'This is how your final AI-generated marketing video will look and sound',
                    ),
                    SizedBox(height: 16.h),
                    _buildVideoPlayer(),
                    SizedBox(height: 16.h),
                    _buildVideoTitle(),
                  ],
                ),
              ),
              SizedBox(height: 30.h),

              // Export button
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
                child: GestureDetector(
                  onTap: () {},
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
                          colors: [Color(0xFF7B2FF7), Color(0xFF00C2CB)],
                        ).createShader(bounds),
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          'Export',
                          style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Center(
                  child: Text(
                    'Your video will be saved to your library\nafter export',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 11.sp, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
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
                Image.asset(
                  'assets/images/videos/preview_thumb.png',
                  width: double.infinity,
                  height: 220.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: double.infinity,
                    height: 220.h,
                    color: const Color(0xFF1A1A1A),
                    child: Icon(Icons.image_outlined, color: Colors.white.withOpacity(0.15), size: 40.w),
                  ),
                ),
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                    border: Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
                  ),
                  child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28.w),
                ),
              ],
            ),
            Container(
              color: const Color(0xFF0E0E0E),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3.h,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7.w),
                      overlayShape: SliderComponentShape.noOverlay,
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white.withOpacity(0.2),
                      thumbColor: Colors.white,
                    ),
                    child: Slider(value: _sliderValue, onChanged: (v) => setState(() => _sliderValue = v)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('00:15', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11.sp)),
                      GestureDetector(
                        onTap: () {},
                        child: Icon(Icons.fullscreen, color: Colors.white.withOpacity(0.5), size: 20.w),
                      ),
                      Text('00:30', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11.sp)),
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

  Widget _buildVideoTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Boost Your Productivity with AI',
          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        Icon(Icons.edit_outlined, color: Colors.white.withOpacity(0.5), size: 18.w),
      ],
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
              child: Image.asset(
                'assets/icons/menu.png',
                width: 22.w,
                height: 22.w,
                color: Colors.white,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.menu, color: Colors.white, size: 22.w),
              ),
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

  const _SectionTitle({Key? key, required this.title, this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 17.sp, fontWeight: FontWeight.w700),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 4.h),
          Text(
            subtitle!,
            style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12.sp, height: 1.5),
          ),
        ],
      ],
    );
  }
}

class _BottomButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _BottomButton({Key? key, required this.label, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 28.h),
      child: GestureDetector(
        onTap: onTap,
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
                colors: [Color(0xFF7B2FF7), Color(0xFF00C2CB)],
              ).createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
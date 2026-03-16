// custom_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../color/app_color.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1.0,
        child: Container(
          height: 46.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(23.r),
            boxShadow: [
              // White glow on the left side
              BoxShadow(
                color: Colors.white.withOpacity(0.25),
                blurRadius: 16.r,
                spreadRadius: 0,
                offset: Offset(-6.w, 0),
              ),
              // White glow on the right side
              BoxShadow(
                color: Colors.white.withOpacity(0.25),
                blurRadius: 16.r,
                spreadRadius: 0,
                offset: Offset(6.w, 0),
              ),
              // Subtle overall glow
              BoxShadow(
                color: Colors.white.withOpacity(0.08),
                blurRadius: 20.r,
                spreadRadius: 1,
                offset: Offset.zero,
              ),
            ],
          ),
          child: Center(
            child: ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.textGradient.createShader(bounds),
              blendMode: BlendMode.srcIn,
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white, // overridden by ShaderMask
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
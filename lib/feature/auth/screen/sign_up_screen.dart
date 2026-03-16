// lib/feature/auth/screen/sign_up_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controller/auth_controller.dart';
import '../widget/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthController _auth = AuthController.to;
  bool _obscurePassword     = true;
  bool _obscureRePassword   = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),
                        Center(child: Image.asset('assets/images/auth/logo.png')),
                        SizedBox(height: 30.h),
                        Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        _buildTextField(
                          controller: _auth.usernameController,
                          hintText: 'Username',
                          isPassword: false,
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _auth.emailController,
                          hintText: 'Email',
                          isPassword: false,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _auth.passwordController,
                          hintText: 'Password',
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onToggleVisibility: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _auth.rePasswordController,
                          hintText: 'Re-type your password',
                          isPassword: true,
                          obscureText: _obscureRePassword,
                          onToggleVisibility: () =>
                              setState(() => _obscureRePassword = !_obscureRePassword),
                        ),
                        SizedBox(height: 80.h),
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12.sp,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'By clicking the "sign up" button, you accept the terms\nof the ',
                                ),
                                TextSpan(
                                  text: 'Privacy Policy.',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12.5.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Obx(() => CustomButton(
                      text: _auth.isLoading.value ? 'Creating account...' : 'Sign up',
                      onTap: _auth.isLoading.value ? null : _auth.register,
                    )),
                    SizedBox(height: 24.h),
                    _buildOrDivider(),
                    SizedBox(height: 24.h),
                    _buildSocialRow(),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool isPassword,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(32.r),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white, fontSize: 16.sp),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          suffixIcon: isPassword
              ? IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.white.withOpacity(0.4),
              size: 22.sp,
            ),
          )
              : null,
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 2, color: Colors.white.withOpacity(0.2))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text('or', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14.sp)),
        ),
        Expanded(child: Container(height: 2, color: Colors.white.withOpacity(0.2))),
      ],
    );
  }

  Widget _buildSocialRow() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 52.h,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(32.r)),
              child: Center(child: Image.asset('assets/images/auth/google.png')),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              height: 52.h,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(32.r)),
              child: Center(child: Image.asset('assets/images/auth/apple.png')),
            ),
          ),
        ),
      ],
    );
  }
}
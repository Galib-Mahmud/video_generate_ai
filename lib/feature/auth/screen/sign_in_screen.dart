// lib/feature/auth/screen/sign_in_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../route/app_route.dart';
import '../../../route/route_name.dart';
import '../controller/auth_controller.dart';
import '../widget/custom_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthController _auth = AuthController.to;
  bool _obscurePassword = true;

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
                        Center(
                          child: Image.asset('assets/images/auth/logo.png'),
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        // Email or Username
                        _buildTextField(
                          controller: _auth.signInEmailController,
                          hintText: 'Email or Username',
                          isPassword: false,
                        ),
                        SizedBox(height: 16.h),
                        // Password
                        _buildTextField(
                          controller: _auth.signInPasswordController,
                          hintText: 'Password',
                          isPassword: true,
                          obscureText: _obscurePassword,
                          onToggleVisibility: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        SizedBox(height: 16.h),
                        Center(
                          child: TextButton(
                            onPressed: () => Get.toNamed(RouteName.forgetPassword),
                            child: Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16.sp,
                                letterSpacing: 0.9,
                              ),
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
                    // Sign In Button
                    Obx(() => CustomButton(
                      text: _auth.isLoading.value ? 'Signing in...' : 'Sign in',
                      onTap: _auth.isLoading.value ? null : _auth.login,
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
                          "Don't you have an account? ",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 15.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(RouteName.signUp),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
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
          child: _buildSocialButton(
            iconPath: 'assets/images/auth/google.png',
            onTap: () {},
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildSocialButton(
            iconPath: 'assets/images/auth/apple.png',
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({required String iconPath, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52.h,
        child: Center(child: Image.asset(iconPath)),
      ),
    );
  }
}
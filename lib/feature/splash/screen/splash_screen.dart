import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../route/app_route.dart';
import '../../../route/route_name.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentPage = 0;

  void _onNextTap() {
    if (_currentPage < 1) {  // 2 pages ache, 1 hole porer screen e jabe
      setState(() {
        _currentPage++;
      });
    } else {
       Get.toNamed(RouteName.signIn); // Last screen e chole gele sign in screen e jabe
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              _currentPage == 0 ?  'assets/images/splash/s.png' : 'assets/images/splash/Splashs.png',
              fit: BoxFit.cover,
            ),
          ),




          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end, // Button ke niche ragbe
                children: [
                  // Next/Finish Button
                  GestureDetector(
                    onTap: _onNextTap,
                    child: Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                _currentPage == 1 ? 'Finish' : 'Next',  // Last page e Finish, ar onno page e Next
                                style: TextStyle(
                                  color: const Color(0xFF4EFFEE),
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(4.w),
                            width: 48.w,
                            height: 48.w,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4EFFEE),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h), // To keep space between the button and bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

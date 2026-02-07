import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hussein/route/route_name.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/auth/sign in.png'), // Set your profile background image here
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                // Profile Header Section
                SizedBox(height: 30.h),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 35.r,
                      backgroundImage: AssetImage('assets/images/profile/profile_picture.png'), // Profile picture
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      'Andrew Garfield',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  '16 videos created',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 30.h),

                // Profile options (Email, Privacy Policy, etc.)
                _buildProfileOption('Email', 'andrew_garfield@gmail.com'),
                _buildProfileOption('Privacy Policy', 'Privacy Details'),
                _buildProfileOption('Log out', 'Logout Action'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(String title, String subtitle) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16.sp,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.6),
              size: 20.sp,
            ),
          ],
        ),
        Divider(
          color: Colors.white.withOpacity(0.2),
          thickness: 1,
          height: 20.h,
        ),
      ],
    );
  }
}

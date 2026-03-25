// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hussein/core/local_storage/user_info.dart';
import 'package:hussein/route/app_route.dart';
import 'package:hussein/route/route_name.dart';
import 'package:hussein/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await UserInfo.init();

  final bool isAuthenticated = await UserInfo.isLoggedIn();

  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatefulWidget {
  final bool isAuthenticated;
  const MyApp({super.key, this.isAuthenticated = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String get initialRoute {
    return widget.isAuthenticated ? RouteName.main : RouteName.splash;
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          initialRoute: initialRoute,
          getPages: AppRoute.pages,
          builder: (context, child) {
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
              child: child ?? const SizedBox(),
            );
          },
        );
      },
    );
  }
}
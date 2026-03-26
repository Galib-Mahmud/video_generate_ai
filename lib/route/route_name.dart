import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:hussein/feature/splash/screen/splash_screen.dart';

import '../feature/auth/screen/forgot_pass_otp_screen.dart';
import '../feature/auth/screen/forgot_password_screen.dart';
import '../feature/auth/screen/reset_password_screen.dart';
import '../feature/auth/screen/sign_in_screen.dart';
import '../feature/auth/screen/sign_up_screen.dart';
import '../feature/home/main_screen.dart';
import '../feature/home/screen/app_drawer_screen.dart';
import '../feature/home/screen/generate_video.dart';
import '../feature/home/screen/home1.dart';
import '../feature/home/screen/home_screen.dart';
import '../feature/home/screen/subscription_screen.dart';
import '../feature/home/screen/video_screen.dart';
import '../feature/profile/screen/privacy_policy_screen.dart';
import '../feature/profile/screen/profile_screen.dart';
import 'app_route.dart';

class AppRoute {
  static final List<GetPage> pages = [
    GetPage(
      name: RouteName.splash,
      page: () => SplashScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: RouteName.splash,
      page: () => SplashScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: RouteName.signIn,
      page: () => SignInScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: RouteName.signUp,
      page: () => SignUpScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: RouteName.forgetPassword,
      page: () => ForgetPasswordScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: RouteName.forgotPassOtp,
      page: () => ForgetPasswordOtpScreen(),
      transition: Transition.noTransition,
    ),GetPage(
      name: RouteName.resetPassword,
      page: () => ResetPasswordScreen(),
      transition: Transition.noTransition,
    ),
    GetPage(
      name: RouteName.main,
      page: () => MainScreen(),
      transition: Transition.noTransition,
    ), GetPage(
      name: RouteName.privacy,
      page: () => PrivacyPolicyScreen(),
      transition: Transition.noTransition,
    ),GetPage(
      name: RouteName.profile,
      page: () => ProfileScreen(),
      transition: Transition.noTransition,
    ),GetPage(
      name: RouteName.video,
      page: () => YourVideosScreen(),
      transition: Transition.noTransition,
    ),GetPage(
      name: RouteName.drawer,
      page: () => CustomDrawer(onClose: () {  },),
      transition: Transition.noTransition,
    ),GetPage(
      name: RouteName.home,
      page: () => HomeScreen(),
      transition: Transition.noTransition,
    ),GetPage(
      name: RouteName.subscribe,
      page: () => SubscriptionScreen(),
      transition: Transition.noTransition,
    ),GetPage(
      name: RouteName.generate,
      page: () => VideoCreationFlowScreen(),
      transition: Transition.noTransition,
    ),GetPage(
      name: RouteName.home1,
      page: () => Home1(),
      transition: Transition.noTransition,
    ),
  ];
}

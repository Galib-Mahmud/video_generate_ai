// lib/feature/auth/controller/auth_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/endpoint/api_client.dart';
import '../../../core/endpoint/api_endpoint.dart';
import '../../../core/local_storage/user_info.dart';
import '../../../route/app_route.dart';
import '../../../route/route_name.dart';

class AuthController extends GetxController {

  // ─── permanent: true ──────────────────────────────────────────────
  // Tells GetX to NEVER delete this controller from memory, even when
  // Get.offAllNamed() clears the entire route stack.
  // Without this, GetX calls onDelete() → dispose() runs on all
  // TextEditingControllers → the new route tries to render a TextField
  // with a disposed controller → crash.
  static AuthController get to => Get.put(AuthController(), permanent: true);

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final RxBool isLoading = false.obs;

  // OTP flow type: 'register' | 'forgot_password'
  final RxString otpFlowType = 'register'.obs;

  // ─── OTP Timer ────────────────────────────────────────────────────
  final RxInt otpTimerSeconds = 60.obs;
  final RxBool canResend      = false.obs;
  Timer? _otpTimer;

  // ─── SignUp Controllers ───────────────────────────────────────────
  final usernameController   = TextEditingController();
  final emailController      = TextEditingController();
  final passwordController   = TextEditingController();
  final rePasswordController = TextEditingController();

  // ─── SignIn Controllers ───────────────────────────────────────────
  final signInEmailController    = TextEditingController();
  final signInPasswordController = TextEditingController();

  // ─── Forgot Password Controllers ─────────────────────────────────
  final forgotEmailController        = TextEditingController();
  final newPasswordController        = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  // ─── OTP Controllers ─────────────────────────────────────────────
  final List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());

  // ─────────────────────────────────────────────────────────────────
  // OTP TIMER
  // ─────────────────────────────────────────────────────────────────
  void startOtpTimer() {
    _otpTimer?.cancel();
    otpTimerSeconds.value = 60;
    canResend.value = false;

    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpTimerSeconds.value > 0) {
        otpTimerSeconds.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  String get otpTimerLabel {
    final m = (otpTimerSeconds.value ~/ 60).toString().padLeft(1, '0');
    final s = (otpTimerSeconds.value % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ─────────────────────────────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────────────────────────────
  Future<void> register() async {
    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        rePasswordController.text.isEmpty) {
      _showError('Please fill all required fields');
      return;
    }
    if (passwordController.text != rePasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    isLoading.value = true;
    try {
      await _apiClient.post(
        ApiEndpoint.signup,
        body: {
          'username'        : usernameController.text.trim(),
          'email'           : emailController.text.trim(),
          'password'        : passwordController.text,
          'password_confirm': rePasswordController.text,
        },
        requiresAuth: false,
      );
      await UserInfo.setUserEmail(emailController.text.trim());
      otpFlowType.value = 'register';
      _clearOtpFields();
      startOtpTimer();
      Get.toNamed(RouteName.forgotPassOtp);
    } on HttpException catch (e) {
      final parsed = _tryParseBody(e.body);
      _showError(_extractMessage(parsed) ?? e.message);
    } catch (e) {
      print('❌ Register error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // VERIFY OTP
  // ─────────────────────────────────────────────────────────────────
  Future<void> verifyOtp() async {
    if (otpFlowType.value == 'register') {
      await _verifyRegistrationOtp();
    } else if (otpFlowType.value == 'forgot_password') {
      await _verifyForgotPasswordOtp();
    }
  }

  Future<void> _verifyRegistrationOtp() async {
    final code = _getOtpCode();
    if (code.length < 6) {
      _showError('Please enter the complete 6-digit code');
      return;
    }
    isLoading.value = true;
    try {
      final email = await UserInfo.getUserEmail();
      await _apiClient.post(
        ApiEndpoint.verifyOtp,
        body: {'email': email, 'otp': code},
        requiresAuth: false,
      );
      _otpTimer?.cancel();
      Get.offAllNamed(RouteName.signIn);
      _showSuccess('Account verified! Please sign in.');
    } on HttpException catch (e) {
      final parsed = _tryParseBody(e.body);
      _showError(_extractMessage(parsed) ?? e.message);
    } catch (e) {
      print('❌ VerifyOTP error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // RESEND OTP
  // ─────────────────────────────────────────────────────────────────
  Future<void> resendOtp() async {
    if (!canResend.value) return;
    if (otpFlowType.value == 'register') {
      await _resendRegistrationOtp();
    } else if (otpFlowType.value == 'forgot_password') {
      await _resendForgotPasswordOtp();
    }
  }

  Future<void> _resendRegistrationOtp() async {
    final email = await UserInfo.getUserEmail();
    if (email == null) return;
    isLoading.value = true;
    try {
      await _apiClient.post(
        ApiEndpoint.resendOtp,
        body: {'email': email},
        requiresAuth: false,
      );
      startOtpTimer();
      _showSuccess('A new code has been sent to your email');
    } on HttpException catch (e) {
      final parsed = _tryParseBody(e.body);
      _showError(_extractMessage(parsed) ?? e.message);
    } catch (e) {
      print('❌ ResendOTP error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────────────────────────────
  Future<void> login() async {
    if (signInEmailController.text.trim().isEmpty ||
        signInPasswordController.text.isEmpty) {
      _showError('Please enter your email/username and password');
      return;
    }
    isLoading.value = true;
    try {
      final response = await _apiClient.post(
        ApiEndpoint.login,
        body: {
          'email_or_username': signInEmailController.text.trim(),
          'password'         : signInPasswordController.text,
        },
        requiresAuth: false,
      );
      if (response != null) {
        // API returns: { "tokens": { "access": "...", "refresh": "..." }, "user": {...} }
        final tokens = response['tokens'] as Map<String, dynamic>? ?? {};
        await UserInfo.setAccessToken(tokens['access'] ?? '');
        await UserInfo.setRefreshToken(tokens['refresh'] ?? '');
      }
      // Wait one frame so SharedPreferences write is fully flushed
      // before GetX builds the next route and controllers call APIs.
      await Future.delayed(Duration.zero);
      Get.offAllNamed(RouteName.main);
    } on UnauthorizedException catch (e) {
      final parsed = _tryParseBody(e.body);
      _showError(_extractMessage(parsed) ?? 'Invalid email or password');
    } on HttpException catch (e) {
      final parsed = _tryParseBody(e.body);
      _showError(_extractMessage(parsed) ?? e.message);
    } catch (e) {
      print('❌ Login error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────────────────────────────
  Future<void> forgotPassword() async {
    if (forgotEmailController.text.trim().isEmpty) {
      _showError('Please enter your email address');
      return;
    }
    isLoading.value = true;
    try {
      await _apiClient.post(
        ApiEndpoint.forgotPassword,
        body: {'email': forgotEmailController.text.trim()},
        requiresAuth: false,
      );
      await UserInfo.setForgotPasswordEmail(forgotEmailController.text.trim());
      otpFlowType.value = 'forgot_password';
      _clearOtpFields();
      startOtpTimer();
      Get.toNamed(RouteName.forgotPassOtp);
    } on HttpException catch (e) {
      final parsed = _tryParseBody(e.body);
      _showError(_extractMessage(parsed) ?? e.message);
    } catch (e) {
      print('❌ ForgotPassword error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _verifyForgotPasswordOtp() async {
    final code = _getOtpCode();
    if (code.length < 6) {
      _showError('Please enter the complete 6-digit code');
      return;
    }
    isLoading.value = true;
    try {
      final email = await UserInfo.getForgotPasswordEmail();
      final response = await _apiClient.post(
        ApiEndpoint.verifyResetOtp,
        body: {'email': email, 'otp': code},
        requiresAuth: false,
      );
      if (response != null && response['token'] != null) {
        await UserInfo.setResetToken(response['token'].toString());
      }
      _otpTimer?.cancel();
      Get.toNamed(RouteName.resetPassword);
    } on HttpException catch (e) {
      final parsed = _tryParseBody(e.body);
      _showError(_extractMessage(parsed) ?? e.message);
    } catch (e) {
      print('❌ VerifyForgotOTP error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _resendForgotPasswordOtp() async {
    final email = await UserInfo.getForgotPasswordEmail();
    if (email == null) return;
    isLoading.value = true;
    try {
      await _apiClient.post(
        ApiEndpoint.forgotPassword,
        body: {'email': email},
        requiresAuth: false,
      );
      startOtpTimer();
      _showSuccess('A new code has been sent to your email');
    } on HttpException catch (e) {
      final parsed = _tryParseBody(e.body);
      _showError(_extractMessage(parsed) ?? e.message);
    } catch (e) {
      print('❌ ResendForgotOTP error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // RESET PASSWORD
  // ─────────────────────────────────────────────────────────────────
  Future<void> resetPassword() async {
    if (newPasswordController.text.isEmpty ||
        confirmNewPasswordController.text.isEmpty) {
      _showError('Please fill in all fields');
      return;
    }
    if (newPasswordController.text != confirmNewPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }
    if (newPasswordController.text.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }
    isLoading.value = true;
    try {
      final token = await UserInfo.getResetToken();
      await _apiClient.post(
        ApiEndpoint.resetPassword,
        body: {
          'token'           : token,
          'password'        : newPasswordController.text,
          'password_confirm': confirmNewPasswordController.text,
        },
        requiresAuth: false,
      );
      await UserInfo.clearForgotPasswordEmail();
      await UserInfo.clearResetToken();
      _showSuccess('Password reset successfully. Please sign in.');
      Get.offAllNamed(RouteName.signIn);
    } on HttpException catch (e) {
      final parsed = _tryParseBody(e.body);
      _showError(_extractMessage(parsed) ?? e.message);
    } catch (e) {
      print('❌ ResetPassword error: $e');
      _showError('Something went wrong. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    await UserInfo.clearAll();
    Get.offAllNamed(RouteName.signIn);
  }

  // ─────────────────────────────────────────────────────────────────
  // PARSERS
  // ─────────────────────────────────────────────────────────────────
  Map<String, dynamic>? _tryParseBody(String? body) {
    if (body == null || body.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return null;
  }

  String? _extractMessage(Map<String, dynamic>? body) {
    if (body == null) return null;
    if (body.containsKey('detail')) return body['detail'].toString();
    for (final entry in body.entries) {
      final val = entry.value;
      if (val is Map && val.containsKey('message')) return val['message'].toString();
      if (val is List && val.isNotEmpty) return val.first.toString();
      if (val is String) return val;
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────
  String _getOtpCode() => otpControllers.map((c) => c.text).join('');

  void _clearOtpFields() {
    for (var c in otpControllers) c.clear();
  }

  // ─────────────────────────────────────────────────────────────────
  // SNACKBARS
  // ─────────────────────────────────────────────────────────────────
  void _showError(String message) {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 50),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 50),
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showInfo(String message) {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // onClose — only cancel the timer, NEVER dispose controllers
  // ─────────────────────────────────────────────────────────────────
  // Because permanent: true keeps this controller alive for the entire
  // app session, disposing controllers here would cause them to be
  // "used after dispose" the next time any auth screen renders.
  @override
  void onClose() {
    _otpTimer?.cancel();
    super.onClose();
  }
}
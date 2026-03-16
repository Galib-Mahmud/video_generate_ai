// lib/core/local_storage/user_info.dart

import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  static SharedPreferences? _prefs;

  // ── Call once in main() BEFORE runApp() ───────────────────────────
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _p {
    assert(_prefs != null, 'UserInfo.init() must be called before use');
    return _prefs!;
  }

  // ======= Access Token ======= //
  static Future<void> setAccessToken(String token) async {
    await _p.setString('access', token);
  }

  static String? getAccessTokenSync() {
    return _p.getString('access');
  }

  static Future<String?> getAccessToken() async {
    return _p.getString('access');
  }

  // ======= Refresh Token ======= //
  static Future<void> setRefreshToken(String token) async {
    await _p.setString('refresh', token);
  }

  static Future<String?> getRefreshToken() async {
    return _p.getString('refresh');
  }

  // ======= isLoggedIn ======= //
  static Future<bool> isLoggedIn() async {
    final token = _p.getString('access');
    return token != null && token.isNotEmpty;
  }

  // ======= User Email ======= //
  static Future<void> setUserEmail(String email) async {
    await _p.setString('user_email', email);
  }

  static Future<String?> getUserEmail() async {
    return _p.getString('user_email');
  }

  // ======= Forgot Password Email ======= //
  static Future<void> setForgotPasswordEmail(String email) async {
    await _p.setString('forgot_password_email', email);
  }

  static Future<String?> getForgotPasswordEmail() async {
    return _p.getString('forgot_password_email');
  }

  static Future<void> clearForgotPasswordEmail() async {
    await _p.remove('forgot_password_email');
  }

  // ======= Reset Token ======= //
  static Future<void> setResetToken(String token) async {
    await _p.setString('reset_token', token);
  }

  static Future<String?> getResetToken() async {
    return _p.getString('reset_token');
  }

  static Future<void> clearResetToken() async {
    await _p.remove('reset_token');
  }

  // ======= Onboarding ======= //
  static Future<void> setOnboardingCompleted(bool value) async {
    await _p.setBool('onboarding_completed', value);
  }

  static Future<bool> getOnboardingCompleted() async {
    return _p.getBool('onboarding_completed') ?? false;
  }

  // ======= Clear All (logout) ======= //
  static Future<void> clearAll() async {
    await _p.clear();
  }
}
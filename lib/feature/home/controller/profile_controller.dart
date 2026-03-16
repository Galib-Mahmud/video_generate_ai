// lib/feature/profile/controller/profile_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/endpoint/api_client.dart';
import '../../../core/endpoint/api_endpoint.dart';
import '../../../core/local_storage/user_info.dart';
import '../../../route/app_route.dart';
import '../../../route/route_name.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.put(ProfileController(), permanent: true);

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final RxBool isLoading = false.obs;

  // ── Profile fields ─────────────────────────────────────────────
  final RxString username       = ''.obs;
  final RxString email          = ''.obs;
  final RxInt    videosCreated  = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  // ─── Fetch profile ────────────────────────────────────────────
  // GET /api/v1/auth/profile/
  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(
        ApiEndpoint.profile,
        requiresAuth: true,
      );
      if (response != null) {
        username.value      = response['username'] ?? '';
        email.value         = response['email'] ?? '';
        videosCreated.value = response['videos_created'] ?? 0;
      }
    } on HttpException catch (e) {
      _showError(e.message);
    } catch (e) {
      print('❌ FetchProfile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Logout ───────────────────────────────────────────────────
  Future<void> logout() async {
    await UserInfo.clearAll();
    Get.offAllNamed(RouteName.signIn);
  }

  void _showError(String message) {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
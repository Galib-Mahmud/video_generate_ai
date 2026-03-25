// lib/feature/home/controller/home_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/endpoint/api_client.dart';
import '../../../core/endpoint/api_endpoint.dart';
import '../../../route/app_route.dart';
import '../controller/video_controller.dart';
import '../../../route/route_name.dart';

class IndustryModel {
  final int id;
  final String name;
  final String icon;

  IndustryModel({required this.id, required this.name, required this.icon});

  factory IndustryModel.fromJson(Map<String, dynamic> json) => IndustryModel(
    id: json['id'],
    name: json['name'],
    icon: json['icon'] ?? '',
  );
}

class HomeController extends GetxController {
  static HomeController get to => Get.put(HomeController(), permanent: true);

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final RxBool isLoading         = false.obs;
  final RxBool isCreatingProject = false.obs;
  final RxInt  selectedIndex     = (-1).obs;

  final RxList<IndustryModel> industries = <IndustryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchIndustries();
  }

  // ─── Fetch Industries ─────────────────────────────────────────
  // GET /api/v1/videogen/options/industries/
  Future<void> fetchIndustries() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(
        ApiEndpoint.industries,
        requiresAuth: true,
      );
      if (response is List) {
        industries.value =
            response.map((e) => IndustryModel.fromJson(e)).toList();
      }
    } on HttpException catch (e) {
      _showError(e.message);
    } catch (e) {
      print('❌ FetchIndustries error: $e');
      _showError('Failed to load industries.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Tap industry → create project → navigate ─────────────────
  // Full flow:
  // 1. POST /api/v1/videogen/projects/create/  { industry }
  // 2. Store project ID in VideoController
  // 3. Navigate to video creation flow
  Future<void> onIndustryTapped(int index, String industryName) async {
    if (isCreatingProject.value) return;
    selectedIndex.value    = index;
    isCreatingProject.value = true;

    try {
      final vc = VideoController.to;
      vc.resetFlow();
      await vc.createProject(industryName);

      if (vc.currentProjectId.value.isNotEmpty) {
        Get.toNamed(RouteName.generate);
      } else {
        selectedIndex.value = -1;
        _showError('Failed to create project. Please try again.');
      }
    } catch (e) {
      print('❌ onIndustryTapped error: $e');
      selectedIndex.value = -1;
      _showError('Something went wrong. Please try again.');
    } finally {
      isCreatingProject.value = false;
    }
  }

  void selectIndustry(int index) => selectedIndex.value = index;

  void _showError(String message) {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text(message,
                    style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
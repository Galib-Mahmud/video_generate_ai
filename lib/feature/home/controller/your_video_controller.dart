// lib/feature/video/controller/your_videos_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/endpoint/api_client.dart';
import '../../../core/endpoint/api_endpoint.dart';
import 'video_controller.dart';

class YourVideosController extends GetxController {
  static YourVideosController get to =>
      Get.put(YourVideosController(), permanent: true);

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final RxBool isFetchingProjects = false.obs;
  final RxList<ProjectModel> projects = <ProjectModel>[].obs;

  // Which project card is expanded / playing
  final RxString playingProjectId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  // ─── Fetch project list ───────────────────────────────────────
  // GET /api/v1/videogen/projects/
  Future<void> fetchProjects() async {
    isFetchingProjects.value = true;
    try {
      final response = await _apiClient.get(
        ApiEndpoint.projectList,
        requiresAuth: true,
      );
      if (response != null && response['results'] is List) {
        projects.value = (response['results'] as List)
            .map((e) => ProjectModel.fromJson(e))
            .toList();
      }
    } on HttpException catch (e) {
      _showError(e.message);
    } catch (e) {
      debugPrint('❌ YourVideos FetchProjects error: $e');
    } finally {
      isFetchingProjects.value = false;
    }
  }

  /// Call this after a new video completes so the list refreshes.
  Future<void> refresh() => fetchProjects();

  void togglePlay(String projectId) {
    if (playingProjectId.value == projectId) {
      playingProjectId.value = '';
    } else {
      playingProjectId.value = projectId;
    }
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
// lib/feature/video/controller/video_controller.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/endpoint/api_client.dart';
import '../../../core/endpoint/api_endpoint.dart';

// ─── Models ───────────────────────────────────────────────────────

class BackgroundModel {
  final int id;
  final String name;
  final String description;
  final String icon;

  BackgroundModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });

  factory BackgroundModel.fromJson(Map<String, dynamic> json) =>
      BackgroundModel(
        id: json['id'],
        name: json['name'],
        description: json['description'] ?? '',
        icon: json['icon'] ?? '',
      );
}

class AvatarModel {
  final String avatarId;
  final String avatarName;
  final String gender;
  final String outfitCategory;
  final String previewImageUrl;
  final String previewVideoUrl;

  AvatarModel({
    required this.avatarId,
    required this.avatarName,
    required this.gender,
    required this.outfitCategory,
    required this.previewImageUrl,
    required this.previewVideoUrl,
  });

  factory AvatarModel.fromJson(Map<String, dynamic> json) => AvatarModel(
    avatarId: json['avatar_id'] ?? '',
    avatarName: json['avatar_name'] ?? '',
    gender: json['gender'] ?? '',
    outfitCategory: json['outfit_category'] ?? '',
    previewImageUrl: json['preview_image_url'] ?? '',
    previewVideoUrl: json['preview_video_url'] ?? '',
  );
}

class ProjectModel {
  final String id;
  final String title;
  final String industry;
  final String status;
  final String avatarName;
  final String avatarOutfit;
  final String? videoFileUrl;
  final String createdAt;

  ProjectModel({
    required this.id,
    required this.title,
    required this.industry,
    required this.status,
    required this.avatarName,
    required this.avatarOutfit,
    this.videoFileUrl,
    required this.createdAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    industry: json['industry'] ?? '',
    status: json['status'] ?? '',
    avatarName: json['avatar_name'] ?? '',
    avatarOutfit: json['avatar_outfit'] ?? '',
    videoFileUrl: json['video_file_url'],
    createdAt: json['created_at'] ?? '',
  );
}

// ─── Controller ───────────────────────────────────────────────────

class VideoController extends GetxController {
  static VideoController get to =>
      Get.put(VideoController(), permanent: true);

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  // ── Loading states ─────────────────────────────────────────────
  final RxBool isLoading             = false.obs;
  final RxBool isGeneratingScript    = false.obs;
  final RxBool isGeneratingVideo     = false.obs;
  final RxBool isPollingVideoStatus  = false.obs;
  final RxBool isFetchingAvatars     = false.obs;
  final RxBool isFetchingBackgrounds = false.obs;
  final RxBool isFetchingProjects    = false.obs;

  // ── Current project ────────────────────────────────────────────
  final RxString currentProjectId  = ''.obs;
  final RxString generatedScript   = ''.obs;
  final RxString finalizedScript   = ''.obs;
  final RxString videoStatus       = ''.obs;
  final RxString videoUrl          = ''.obs;
  final RxString videoFileUrl      = ''.obs;

  // ── Generation animation step ──────────────────────────────────
  // 0=idle 1=project_created 2=script_generating 3=video_rendering
  // 4=polling 5=complete
  final RxInt generationStep = 0.obs;

  // ── Selected values ────────────────────────────────────────────
  final RxString selectedIndustry   = ''.obs;
  final RxString selectedAvatarId   = ''.obs;
  final RxString selectedBackground = ''.obs;
  final RxString selectedOutfit     = 'business'.obs;

  // ── Data lists ─────────────────────────────────────────────────
  final RxList<BackgroundModel> backgrounds = <BackgroundModel>[].obs;
  final RxMap<String, List<AvatarModel>> avatars =
      <String, List<AvatarModel>>{}.obs;
  final RxList<ProjectModel> projects = <ProjectModel>[].obs;

  // ── Text controllers ───────────────────────────────────────────
  // titleController & serviceDescController are used in Step 1 (Avatar step)
  // so the user fills in title + service description before generate-script.
  final titleController       = TextEditingController();
  final serviceDescController = TextEditingController();
  final scriptController      = TextEditingController();

  Timer? _pollingTimer;

  // ─────────────────────────────────────────────────────────────
  // STEP 1: CREATE PROJECT
  // POST /api/v1/videogen/projects/create/
  // body: { industry }
  // ─────────────────────────────────────────────────────────────
  Future<void> createProject(String industry) async {
    isLoading.value = true;
    generationStep.value = 1;
    try {
      final response = await _apiClient.post(
        ApiEndpoint.createProject,
        body: {'industry': industry},
        requiresAuth: true,
      );
      if (response != null) {
        currentProjectId.value = response['id'] ?? '';
        selectedIndustry.value = industry;
      }
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
      generationStep.value = 0;
    } catch (e) {
      print('❌ CreateProject error: $e');
      _showError('Failed to create project.');
      generationStep.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 2: UPDATE PROJECT — title + service_description + avatar
  // PATCH /api/v1/videogen/projects/{id}/update/
  //
  // IMPORTANT: The API requires title, service_description AND avatar_id
  // before generate-script will work. This method saves all three.
  // Call this before generateScript().
  // ─────────────────────────────────────────────────────────────
  Future<bool> updateProjectDetails() async {
    if (currentProjectId.value.isEmpty) return false;

    final title = titleController.text.trim();
    final desc  = serviceDescController.text.trim();
    final avatarId = selectedAvatarId.value;

    // Validate required fields
    if (title.isEmpty) {
      _showError('Please enter a video title');
      return false;
    }
    if (desc.isEmpty) {
      _showError('Please describe your service');
      return false;
    }
    if (avatarId.isEmpty) {
      _showError('Please select an avatar');
      return false;
    }

    isLoading.value = true;
    try {
      await _apiClient.patch(
        ApiEndpoint.updateProject(currentProjectId.value),
        body: {
          'title'              : title,
          'service_description': desc,
          'avatar_id'          : avatarId,
        },
        requiresAuth: true,
      );
      return true;
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
      return false;
    } catch (e) {
      print('❌ UpdateProjectDetails error: $e');
      _showError('Failed to save project details.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // UPDATE BACKGROUND ONLY
  // PATCH /api/v1/videogen/projects/{id}/update/
  // body: { background }
  // ─────────────────────────────────────────────────────────────
  Future<void> updateBackground(String background) async {
    if (currentProjectId.value.isEmpty) return;
    // Optimistic update — update UI first, then save
    selectedBackground.value = background;
    try {
      await _apiClient.patch(
        ApiEndpoint.updateProject(currentProjectId.value),
        body: {'background': background},
        requiresAuth: true,
      );
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
    } catch (e) {
      print('❌ UpdateBackground error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // UPDATE AVATAR
  // PATCH /api/v1/videogen/projects/{id}/update/
  // body: { avatar_id }
  // ─────────────────────────────────────────────────────────────
  Future<void> updateAvatar(String avatarId) async {
    selectedAvatarId.value = avatarId; // optimistic update
    if (currentProjectId.value.isEmpty) return;
    try {
      await _apiClient.patch(
        ApiEndpoint.updateProject(currentProjectId.value),
        body: {'avatar_id': avatarId},
        requiresAuth: true,
      );
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
    } catch (e) {
      print('❌ UpdateAvatar error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 3: GENERATE AI SCRIPT
  // POST /api/v1/videogen/projects/{id}/generate-script/
  //
  // Prerequisite: title, service_description, avatar_id must be set.
  // Call updateProjectDetails() before this.
  // ─────────────────────────────────────────────────────────────
  Future<void> generateScript() async {
    if (currentProjectId.value.isEmpty) return;
    isGeneratingScript.value = true;
    generationStep.value = 2;
    try {
      final response = await _apiClient.post(
        ApiEndpoint.generateScript(currentProjectId.value),
        requiresAuth: true,
      );
      if (response != null) {
        generatedScript.value = response['generated_script'] ?? '';
        scriptController.text = generatedScript.value;
      }
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
      generationStep.value = 0;
    } catch (e) {
      print('❌ GenerateScript error: $e');
      _showError('Failed to generate script.');
      generationStep.value = 0;
    } finally {
      isGeneratingScript.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 4: FINALIZE SCRIPT
  // PUT /api/v1/videogen/projects/{id}/finalize-script/
  // body: { finalized_script }
  // ─────────────────────────────────────────────────────────────
  Future<void> finalizeScript() async {
    if (currentProjectId.value.isEmpty) return;
    isLoading.value = true;
    try {
      final script = scriptController.text.trim().isNotEmpty
          ? scriptController.text.trim()
          : generatedScript.value;
      await _apiClient.put(
        ApiEndpoint.finalizeScript(currentProjectId.value),
        body: {'finalized_script': script},
        requiresAuth: true,
      );
      finalizedScript.value = script;
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
    } catch (e) {
      print('❌ FinalizeScript error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 5: GENERATE VIDEO
  // POST /api/v1/videogen/projects/{id}/generate-video/
  // ─────────────────────────────────────────────────────────────
  Future<void> generateVideo() async {
    if (currentProjectId.value.isEmpty) return;
    isGeneratingVideo.value = true;
    generationStep.value = 3;
    try {
      await _apiClient.post(
        ApiEndpoint.generateVideo(currentProjectId.value),
        requiresAuth: true,
      );
      _startPolling();
    } on HttpException catch (e) {
      _showError(_extractMessage(e.body) ?? e.message);
      isGeneratingVideo.value = false;
      generationStep.value = 0;
    } catch (e) {
      print('❌ GenerateVideo error: $e');
      _showError('Failed to start video generation.');
      isGeneratingVideo.value = false;
      generationStep.value = 0;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // POLLING: VIDEO STATUS
  // GET /api/v1/videogen/projects/{id}/video-status/
  // ─────────────────────────────────────────────────────────────
  void _startPolling() {
    generationStep.value = 4;
    isPollingVideoStatus.value = true;
    _pollingTimer?.cancel();
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 5), (_) async {
          await _checkVideoStatus();
        });
  }

  Future<void> _checkVideoStatus() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoint.videoStatus(currentProjectId.value),
        requiresAuth: true,
      );
      if (response != null) {
        videoStatus.value = response['status'] ?? '';
        if (videoStatus.value == 'video_completed') {
          videoUrl.value     = response['video_url'] ?? '';
          videoFileUrl.value = response['video_file_url'] ?? '';
          _pollingTimer?.cancel();
          isPollingVideoStatus.value = false;
          isGeneratingVideo.value    = false;
          generationStep.value       = 5;
          fetchProjects();
        }
      }
    } catch (e) {
      print('❌ Polling error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // FETCH OPTIONS
  // ─────────────────────────────────────────────────────────────
  Future<void> fetchBackgrounds() async {
    isFetchingBackgrounds.value = true;
    try {
      final response = await _apiClient.get(
        ApiEndpoint.backgrounds,
        requiresAuth: true,
      );
      if (response is List) {
        backgrounds.value =
            response.map((e) => BackgroundModel.fromJson(e)).toList();
      }
    } catch (e) {
      print('❌ FetchBackgrounds error: $e');
    } finally {
      isFetchingBackgrounds.value = false;
    }
  }

  Future<void> fetchAvatars() async {
    isFetchingAvatars.value = true;
    try {
      final response = await _apiClient.get(
        ApiEndpoint.avatars,
        requiresAuth: true,
      );
      if (response is Map<String, dynamic>) {
        final Map<String, List<AvatarModel>> parsed = {};
        response.forEach((category, list) {
          if (list is List) {
            parsed[category] =
                list.map((e) => AvatarModel.fromJson(e)).toList();
          }
        });
        avatars.value = parsed;
      }
    } catch (e) {
      print('❌ FetchAvatars error: $e');
    } finally {
      isFetchingAvatars.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // FETCH PROJECT LIST
  // GET /api/v1/videogen/projects/
  // ─────────────────────────────────────────────────────────────
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
      print('❌ FetchProjects error: $e');
    } finally {
      isFetchingProjects.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // RESET
  // ─────────────────────────────────────────────────────────────
  void resetFlow() {
    currentProjectId.value   = '';
    generatedScript.value    = '';
    finalizedScript.value    = '';
    videoStatus.value        = '';
    videoUrl.value           = '';
    videoFileUrl.value       = '';
    generationStep.value     = 0;
    selectedIndustry.value   = '';
    selectedAvatarId.value   = '';
    selectedBackground.value = '';
    selectedOutfit.value     = 'business';
    titleController.clear();
    serviceDescController.clear();
    scriptController.clear();
    _pollingTimer?.cancel();
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────
  String? _extractMessage(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('detail'))
          return decoded['detail'].toString();
        for (final entry in decoded.entries) {
          final val = entry.value;
          if (val is List && val.isNotEmpty) return val.first.toString();
          if (val is String) return val;
        }
      }
    } catch (_) {}
    return null;
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
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }
}
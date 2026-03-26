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
  BackgroundModel({required this.id, required this.name,
    required this.description, required this.icon});
  factory BackgroundModel.fromJson(Map<String, dynamic> j) => BackgroundModel(
      id: j['id'], name: j['name'],
      description: j['description'] ?? '', icon: j['icon'] ?? '');
}

class AvatarModel {
  final String avatarId;
  final String avatarName;
  final String gender;
  final String outfitCategory;
  final String previewImageUrl;
  final String previewVideoUrl;
  final String VoiceId;
  AvatarModel({required this.avatarId, required this.avatarName,
    required this.gender, required this.outfitCategory,
    required this.previewImageUrl, required this.previewVideoUrl,this.VoiceId='',});
  factory AvatarModel.fromJson(Map<String, dynamic> j) => AvatarModel(
      avatarId: j['avatar_id'] ?? '', avatarName: j['avatar_name'] ?? '',
      gender: j['gender'] ?? '', outfitCategory: j['outfit_category'] ?? '',
      previewImageUrl: j['preview_image_url'] ?? '',
      previewVideoUrl: j['preview_video_url'] ?? '');
}

class ProjectModel {
  final String id;
  final String title;
  final String industry;
  final String status;
  final String avatarName;
  final String avatarOutfit;
  final String? videoFileUrl;
  final String videoUrl;
  final String createdAt;
  ProjectModel({required this.id, required this.title,
    required this.industry, required this.status,
    required this.avatarName, required this.avatarOutfit,
    this.videoFileUrl, this.videoUrl = '', required this.createdAt, required VoiceId});
  factory ProjectModel.fromJson(Map<String, dynamic> j) => ProjectModel(
      id: j['id'] ?? '', title: j['title'] ?? '',
      industry: j['industry'] ?? '', status: j['status'] ?? '',
      avatarName: j['avatar_name'] ?? '', avatarOutfit: j['avatar_outfit'] ?? '',
      videoFileUrl: j['video_file_url'],
      VoiceId: j['voice_id'] ?? '',
      videoUrl: j['video_url'] ?? '', createdAt: j['created_at'] ?? '');
  String get playableUrl {
    if (videoUrl.isNotEmpty) return videoUrl;
    if (videoFileUrl != null && videoFileUrl!.isNotEmpty) return videoFileUrl!;
    return '';
  }
}

// ─── Controller ───────────────────────────────────────────────────

class VideoController extends GetxController {
  static VideoController get to => Get.put(VideoController(), permanent: true);

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  // ── Loading states ─────────────────────────────────────────────
  final RxBool isLoading             = false.obs;
  final RxBool isGeneratingScript    = false.obs;
  final RxBool isGeneratingVideo     = false.obs;
  final RxBool isPollingVideoStatus  = false.obs;
  final RxBool isFetchingAvatars     = false.obs;
  final RxBool isFetchingBackgrounds = false.obs;
  final RxBool isFetchingProjects    = false.obs;
  final RxBool isGeneratingTts       = false.obs;
  final RxBool isPatchingBackground  = false.obs;
  final RxBool isPatchingAvatar      = false.obs;

  // ── Project state ──────────────────────────────────────────────
  final RxString currentProjectId    = ''.obs;
  final RxString VoiceId    = ''.obs;

  final RxString generatedScript     = ''.obs;
  final RxString finalizedScript     = ''.obs;
  final RxString videoStatus         = ''.obs;
  final RxString videoUrl            = ''.obs;
  final RxString videoFileUrl        = ''.obs;
  final RxString ttsAudioUrl         = ''.obs;

  // ── Avatar preview (from PATCH avatar response) ────────────────
  final RxString avatarPreviewVideoUrl = ''.obs;
  final RxString avatarPreviewImageUrl = ''.obs;

  // ── Generation step for animation ─────────────────────────────
  // 0=idle 1=project 2=script 3=rendering 4=polling 5=complete
  final RxInt generationStep = 0.obs;

  // ── Selected values ────────────────────────────────────────────
  final RxString selectedIndustry   = ''.obs;
  final RxString selectedAvatarId   = ''.obs;
  final RxString selectedBackground = ''.obs;
  final RxString selectedOutfit     = 'business'.obs;
  final RxString selectedVoiceId    = ''.obs;

  // ── Data ───────────────────────────────────────────────────────
  final RxList<BackgroundModel> backgrounds = <BackgroundModel>[].obs;
  final RxMap<String, List<AvatarModel>> avatars =
      <String, List<AvatarModel>>{}.obs;
  final RxList<ProjectModel> projects = <ProjectModel>[].obs;

  // ── Text controllers ───────────────────────────────────────────
  final titleController       = TextEditingController();
  final serviceDescController = TextEditingController();
  final scriptController      = TextEditingController();

  Timer? _pollingTimer;

  // ═══════════════════════════════════════════════════════════════
  // STEP 1  –  POST /api/v1/videogen/projects/create/
  //            body: { industry }
  // ═══════════════════════════════════════════════════════════════
  Future<void> createProject(String industry) async {
    isLoading.value = true;
    generationStep.value = 1;
    try {
      final res = await _apiClient.post(
        ApiEndpoint.createProject,
        body: {'industry': industry},
        requiresAuth: true,
      );
      if (res != null) {
        currentProjectId.value = res['id'] ?? '';
        selectedIndustry.value = industry;
      }
    } on HttpException catch (e) {
      _showError(_msg(e.body) ?? e.message);
      generationStep.value = 0;
    } catch (e) {
      debugPrint('❌ createProject: $e');
      _showError('Failed to create project.');
      generationStep.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 2  –  PATCH title + service_description
  //            PATCH /api/v1/videogen/projects/{id}/update/
  // ═══════════════════════════════════════════════════════════════
  Future<bool> patchTitleAndDescription() async {
    if (currentProjectId.value.isEmpty) return false;
    final title = titleController.text.trim();
    final desc  = serviceDescController.text.trim();
    if (title.isEmpty) { _showError('Please enter a video title'); return false; }
    if (desc.isEmpty)  { _showError('Please describe your service'); return false; }

    isLoading.value = true;
    try {
      await _apiClient.patch(
        ApiEndpoint.updateProject(currentProjectId.value),
        body: {'title': title, 'service_description': desc},
        requiresAuth: true,
      );
      return true;
    } on HttpException catch (e) {
      _showError(_msg(e.body) ?? e.message);
      return false;
    } catch (e) {
      debugPrint('❌ patchTitleAndDescription: $e');
      _showError('Failed to save title/description.');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 3  –  GET /api/v1/videogen/options/backgrounds/
  // ═══════════════════════════════════════════════════════════════
  Future<void> fetchBackgrounds() async {
    isFetchingBackgrounds.value = true;
    try {
      final res = await _apiClient.get(ApiEndpoint.backgrounds, requiresAuth: true);
      if (res is List) {
        backgrounds.value = res.map((e) => BackgroundModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('❌ fetchBackgrounds: $e');
    } finally {
      isFetchingBackgrounds.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 4  –  PATCH background
  //            PATCH /api/v1/videogen/projects/{id}/update/
  //            body: { background }
  // ═══════════════════════════════════════════════════════════════
  Future<void> patchBackground(String background) async {
    selectedBackground.value = background; // optimistic UI
    if (currentProjectId.value.isEmpty) return;
    isPatchingBackground.value = true;
    try {
      await _apiClient.patch(
        ApiEndpoint.updateProject(currentProjectId.value),
        body: {'background': background},
        requiresAuth: true,
      );
    } on HttpException catch (e) {
      _showError(_msg(e.body) ?? e.message);
    } catch (e) {
      debugPrint('❌ patchBackground: $e');
    } finally {
      isPatchingBackground.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 5  –  GET /api/v1/videogen/options/avatars/
  // ═══════════════════════════════════════════════════════════════
  Future<void> fetchAvatars() async {
    isFetchingAvatars.value = true;
    try {
      final res = await _apiClient.get(ApiEndpoint.avatars, requiresAuth: true);
      if (res is Map<String, dynamic>) {
        final Map<String, List<AvatarModel>> parsed = {};
        res.forEach((cat, list) {
          if (list is List) {
            parsed[cat] = list.map((e) => AvatarModel.fromJson(e)).toList();
          }
        });
        avatars.value = parsed;
        // Auto-select first avatar for a better UX
        if (parsed.isNotEmpty && selectedAvatarId.value.isEmpty) {
          final first = parsed.values.first.first;
          selectedAvatarId.value      = first.avatarId;
          avatarPreviewImageUrl.value = first.previewImageUrl;
          avatarPreviewVideoUrl.value = first.previewVideoUrl;
        }
      }
    } catch (e) {
      debugPrint('❌ fetchAvatars: $e');
    } finally {
      isFetchingAvatars.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 6  –  PATCH avatar_id
  //            PATCH /api/v1/videogen/projects/{id}/update/
  //            body: { avatar_id }
  //            → stores avatar_preview_video_url for loading screen
  // ═══════════════════════════════════════════════════════════════
  Future<void> patchAvatar(AvatarModel avatar) async {
    // Optimistic update — store preview URLs immediately
    selectedAvatarId.value      = avatar.avatarId;
    avatarPreviewImageUrl.value = avatar.previewImageUrl;
    avatarPreviewVideoUrl.value = avatar.previewVideoUrl;

    if (currentProjectId.value.isEmpty) return;
    isPatchingAvatar.value = true;
    try {
      await _apiClient.patch(
        ApiEndpoint.updateProject(currentProjectId.value),
        body: {'avatar_id': avatar.avatarId},
        requiresAuth: true,
      );
    } on HttpException catch (e) {
      _showError(_msg(e.body) ?? e.message);
    } catch (e) {
      debugPrint('❌ patchAvatar: $e');
    } finally {
      isPatchingAvatar.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 7  –  POST /api/v1/videogen/projects/{id}/generate-script/
  //            Prereq: title, service_description, avatar_id must be set
  // ═══════════════════════════════════════════════════════════════
  // In VideoController — update generateScript() to save voice_id from response

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

        // ✅ Save voice_id from project object in the response
        // Response structure: { generated_script, project: { voice_id, ... } }
        final project = response['project'];
        if (project is Map<String, dynamic>) {
          final voiceId = project['voice_id'] ?? '';
          if (voiceId.toString().isNotEmpty) {
            selectedVoiceId.value = voiceId.toString();
            debugPrint('✅ voice_id saved from script response: $voiceId');
          }
        }
      }
    } on HttpException catch (e) {
      _showError((e.body) ?? e.message);
      generationStep.value = 0;
    } catch (e) {
      debugPrint('❌ GenerateScript error: $e');
      _showError('Failed to generate script.');
      generationStep.value = 0;
    } finally {
      isGeneratingScript.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 8  –  PUT /api/v1/videogen/projects/{id}/finalize-script/
  //            body: { finalized_script }
  // ═══════════════════════════════════════════════════════════════
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
      _showError(_msg(e.body) ?? e.message);
    } catch (e) {
      debugPrint('❌ finalizeScript: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 9  –  POST /api/v1/videogen/tts/
  //            body: { project_id, voice_id? }
  //            → ttsAudioUrl.value contains audio_url for playback
  // ═══════════════════════════════════════════════════════════════
  Future<void> generateTts() async {
    if (currentProjectId.value.isEmpty) return;
    isGeneratingTts.value = true;
    ttsAudioUrl.value = '';
    try {
      print("DEBUG VoiceId: ${selectedVoiceId.value}");
      final body = <String,dynamic>{'project_id': currentProjectId.value,'voice_id':selectedVoiceId.value};


      final res = await _apiClient.post(
        ApiEndpoint.ttsPreview,
        body: body,
        requiresAuth: true,
      );
      if (res != null) {
        ttsAudioUrl.value = res['audio_url'] ?? '';
      }
    } on HttpException catch (e) {
      _showError(_msg(e.body) ?? e.message);
    } catch (e) {
      debugPrint('❌ generateTts: $e');
      _showError('Failed to generate voiceover preview.');
    } finally {
      isGeneratingTts.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 10  –  POST /api/v1/videogen/projects/{id}/generate-video/
  //             Re-finalizes script first to avoid 400 errors
  // ═══════════════════════════════════════════════════════════════
  Future<void> generateVideo() async {
    if (currentProjectId.value.isEmpty) return;

    // Re-finalize to be safe (background PATCH can clear it server-side)
    if (finalizedScript.value.isNotEmpty) {
      try {
        await _apiClient.put(
          ApiEndpoint.finalizeScript(currentProjectId.value),
          body: {'finalized_script': finalizedScript.value},
          requiresAuth: true,
        );
      } catch (_) {} // non-fatal
    }

    isGeneratingVideo.value = true;
    generationStep.value = 3;
    try {
      await _apiClient.post(
        ApiEndpoint.generateVideo(currentProjectId.value),
        requiresAuth: true,
      );
      _startPolling();
    } on HttpException catch (e) {
      _showError(_msg(e.body) ?? e.message);
      isGeneratingVideo.value = false;
      generationStep.value = 0;
    } catch (e) {
      debugPrint('❌ generateVideo: $e');
      _showError('Failed to start video generation.');
      isGeneratingVideo.value = false;
      generationStep.value = 0;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // POLLING  –  GET /api/v1/videogen/projects/{id}/video-status/
  //             Fires every 5 seconds until video_completed
  // ═══════════════════════════════════════════════════════════════
  void _startPolling() {
    generationStep.value = 4;
    isPollingVideoStatus.value = true;
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _checkVideoStatus();
    });
  }

  Future<void> _checkVideoStatus() async {
    try {
      final res = await _apiClient.get(
        ApiEndpoint.videoStatus(currentProjectId.value),
        requiresAuth: true,
      );
      if (res != null) {
        videoStatus.value = res['status'] ?? '';
        if (videoStatus.value == 'video_completed') {
          final vUrl  = res['video_url'] ?? '';
          final vFile = res['video_file_url'] ?? '';
          videoUrl.value     = vUrl.isNotEmpty ? vUrl : vFile;
          videoFileUrl.value = vFile;
          _pollingTimer?.cancel();
          isPollingVideoStatus.value = false;
          isGeneratingVideo.value    = false;
          generationStep.value       = 5;
          fetchProjects();
          // ── Top snackbar: "Your video is now ready" ─────────
          _showVideoReadySnackbar();
        }
      }
    } catch (e) {
      debugPrint('❌ polling: $e');
    }
  }

  void _showVideoReadySnackbar() {
    Get.snackbar(
      '🎉 Video Ready!',
      'Your marketing video has been generated successfully.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF111111),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF00C2CB)),
      shouldIconPulse: false,
      borderColor: const Color(0xFF00C2CB),
      borderWidth: 1,
    );
  }

  // ─── Fetch project list ────────────────────────────────────────
  Future<void> fetchProjects() async {
    isFetchingProjects.value = true;
    try {
      final res = await _apiClient.get(ApiEndpoint.projectList, requiresAuth: true);
      if (res != null && res['results'] is List) {
        projects.value = (res['results'] as List)
            .map((e) => ProjectModel.fromJson(e))
            .toList();
      }
    } on HttpException catch (e) {
      _showError(e.message);
    } catch (e) {
      debugPrint('❌ fetchProjects: $e');
    } finally {
      isFetchingProjects.value = false;
    }
  }

  // ─── Reset ────────────────────────────────────────────────────
  void resetFlow() {
    currentProjectId.value      = '';
    generatedScript.value       = '';
    finalizedScript.value       = '';
    videoStatus.value           = '';
    videoUrl.value              = '';
    videoFileUrl.value          = '';
    ttsAudioUrl.value           = '';
    avatarPreviewVideoUrl.value = '';
    avatarPreviewImageUrl.value = '';
    generationStep.value        = 0;
    selectedIndustry.value      = '';
    selectedAvatarId.value      = '';
    selectedBackground.value    = '';
    selectedVoiceId.value       = '';
    selectedOutfit.value        = 'business';
    titleController.clear();
    serviceDescController.clear();
    scriptController.clear();
    _pollingTimer?.cancel();
  }

  // ─── Helpers ──────────────────────────────────────────────────
  String? _msg(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      final d = jsonDecode(body);
      if (d is Map<String, dynamic>) {
        if (d.containsKey('detail')) return d['detail'].toString();
        for (final e in d.entries) {
          final v = e.value;
          if (v is List && v.isNotEmpty) return v.first.toString();
          if (v is String) return v;
        }
      }
    } catch (_) {}
    return null;
  }

  void _showError(String message) {
    final ctx = Get.context;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }
}
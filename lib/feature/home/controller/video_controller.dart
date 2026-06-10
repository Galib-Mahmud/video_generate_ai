// lib/feature/video/controller/video_controller.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

// ✅ NEW — uploaded background image (from /backgrounds/uploaded/)
class UploadedBackgroundModel {
  final int id;
  final String imageUrl;
  final String name;
  final String createdAt;
  UploadedBackgroundModel({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.createdAt,
  });
  factory UploadedBackgroundModel.fromJson(Map<String, dynamic> j) =>
      UploadedBackgroundModel(
        id: j['id'] ?? 0,
        // backend returns both `image` and `image_url` — prefer image_url
        imageUrl: (j['image_url'] ?? j['image'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        createdAt: (j['created_at'] ?? '').toString(),
      );
}

class AvatarModel {
  final String avatarId;
  final String avatarName;
  final String gender;
  final String outfitCategory;
  final String previewImageUrl;
  final String previewVideoUrl;
  final String voiceId;
  AvatarModel({required this.avatarId, required this.avatarName,
    required this.gender, required this.outfitCategory,
    required this.previewImageUrl, required this.previewVideoUrl,
    this.voiceId = ''});
  factory AvatarModel.fromJson(Map<String, dynamic> j) => AvatarModel(
      avatarId: j['avatar_id'] ?? '', avatarName: j['avatar_name'] ?? '',
      gender: j['gender'] ?? '', outfitCategory: j['outfit_category'] ?? '',
      previewImageUrl: j['preview_image_url'] ?? '',
      previewVideoUrl: j['preview_video_url'] ?? '',
      voiceId: (j['default_voice_id'] ?? j['suggested_voice_id'] ?? '')
          .toString());
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
  final String voiceId;
  final String createdAt;
  final bool isRegeneration;
  ProjectModel({required this.id, required this.title,
    required this.industry, required this.status,
    required this.avatarName, required this.avatarOutfit,
    this.videoFileUrl, this.videoUrl = '', this.voiceId = '',
    required this.createdAt, this.isRegeneration = false});
  factory ProjectModel.fromJson(Map<String, dynamic> j) => ProjectModel(
      id: j['id'] ?? '', title: j['title'] ?? '',
      industry: j['industry'] ?? '', status: j['status'] ?? '',
      avatarName: j['avatar_name'] ?? '', avatarOutfit: j['avatar_outfit'] ?? '',
      videoFileUrl: j['video_file_url'],
      voiceId: (j['voice_id'] ?? '').toString(),
      videoUrl: j['video_url'] ?? '',
      createdAt: j['created_at'] ?? '',
      isRegeneration: j['is_regeneration'] == true);
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
  final RxBool isUploadingBackground = false.obs; // ✅ NEW
  final RxBool isRegenerating        = false.obs; // ✅ NEW

  // ── Project state ──────────────────────────────────────────────
  final RxString currentProjectId    = ''.obs;

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
  final RxList<UploadedBackgroundModel> uploadedBackgrounds =
      <UploadedBackgroundModel>[].obs; // ✅ NEW
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
  // Preset backgrounds (existing) — GET /options/backgrounds/
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
  // ✅ NEW  –  GET /api/v1/videogen/options/backgrounds/uploaded/
  //           User's previously uploaded background images
  // ═══════════════════════════════════════════════════════════════
  Future<void> fetchUploadedBackgrounds() async {
    try {
      final res = await _apiClient.get(
        ApiEndpoint.uploadedBackgrounds,
        requiresAuth: true,
      );
      if (res is List) {
        uploadedBackgrounds.value = res
            .map((e) => UploadedBackgroundModel.fromJson(e))
            .toList();
      } else if (res is Map<String, dynamic> && res['results'] is List) {
        // safety: in case backend paginates this endpoint
        uploadedBackgrounds.value = (res['results'] as List)
            .map((e) => UploadedBackgroundModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      debugPrint('❌ fetchUploadedBackgrounds: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ NEW  –  POST /api/v1/videogen/options/backgrounds/upload/
  //           multipart/form-data → image (file), name (optional)
  //           On success: adds to list + auto-selects it for the
  //           current project (PATCH background = image_url)
  // ═══════════════════════════════════════════════════════════════
  Future<bool> uploadBackground(File imageFile, {String? name}) async {
    isUploadingBackground.value = true;
    try {
      final res = await _apiClient.multipart(
        ApiEndpoint.uploadBackground,
        method: 'POST',
        fields: {
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        },
        files: {'image': imageFile},
        requiresAuth: true,
      );
      if (res != null) {
        final bg = UploadedBackgroundModel.fromJson(
            Map<String, dynamic>.from(res));
        uploadedBackgrounds.insert(0, bg); // show newest first
        // auto-select the freshly uploaded image as the project background
        if (bg.imageUrl.isNotEmpty) {
          await patchBackground(bg.imageUrl);
        }
        return true;
      }
      return false;
    } on HttpException catch (e) {
      _showError(_msg(e.body) ?? e.message);
      return false;
    } catch (e) {
      debugPrint('❌ uploadBackground: $e');
      _showError('Failed to upload background image.');
      return false;
    } finally {
      isUploadingBackground.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // PATCH background — preset name, #hex color, OR image URL
  // (uploaded backgrounds use their image_url here)
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
  // GET /api/v1/videogen/options/avatars/
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
  // PATCH avatar_id
  // ═══════════════════════════════════════════════════════════════
  Future<void> patchAvatar(AvatarModel avatar) async {
    // Optimistic update — store preview URLs immediately
    selectedAvatarId.value      = avatar.avatarId;
    avatarPreviewImageUrl.value = avatar.previewImageUrl;
    avatarPreviewVideoUrl.value = avatar.previewVideoUrl;
    if (avatar.voiceId.isNotEmpty) selectedVoiceId.value = avatar.voiceId;

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
  // POST /generate-script/
  // ═══════════════════════════════════════════════════════════════
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

        // Save voice_id from project object in the response
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
      _showError(_msg(e.body) ?? e.message);
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
  // PUT /finalize-script/
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
  // POST /tts/
  // ═══════════════════════════════════════════════════════════════
  Future<void> generateTts() async {
    if (currentProjectId.value.isEmpty) return;
    isGeneratingTts.value = true;
    ttsAudioUrl.value = '';
    try {
      final body = <String, dynamic>{
        'project_id': currentProjectId.value,
        if (selectedVoiceId.value.isNotEmpty) 'voice_id': selectedVoiceId.value,
      };
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
  // POST /generate-video/
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
  // ✅ NEW  –  POST /api/v1/videogen/projects/{id}/regenerate/
  //           Re-renders a completed video with identical settings.
  //           Backend returns a NEW project (is_regeneration: true,
  //           status: video_processing) — we switch currentProjectId
  //           to the new project and start polling it.
  //           Counts against the regeneration quota (403 → paywall).
  // ═══════════════════════════════════════════════════════════════
  Future<bool> regenerateProject(String projectId) async {
    if (projectId.isEmpty || isRegenerating.value) return false;
    isRegenerating.value = true;
    try {
      final res = await _apiClient.post(
        ApiEndpoint.regenerateProject(projectId),
        requiresAuth: true,
      );
      if (res != null) {
        final newId = (res['id'] ?? '').toString();
        if (newId.isEmpty) {
          _showError('Regeneration failed: no project returned.');
          return false;
        }
        // Reset video state and point at the NEW regenerated project
        currentProjectId.value = newId;
        videoStatus.value      = (res['status'] ?? 'video_processing').toString();
        videoUrl.value         = '';
        videoFileUrl.value     = '';
        isGeneratingVideo.value = true;
        generationStep.value    = 3;
        _startPolling();
        return true;
      }
      return false;
    } on ForbiddenException catch (e) {
      // quota exhausted / no subscription
      _showError(_msg(e.body) ??
          'Regeneration quota exhausted. Please upgrade your plan.');
      return false;
    } on HttpException catch (e) {
      _showError(_msg(e.body) ?? e.message);
      return false;
    } catch (e) {
      debugPrint('❌ regenerateProject: $e');
      _showError('Failed to regenerate video.');
      return false;
    } finally {
      isRegenerating.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // POLLING  –  GET /video-status/ every 5 seconds
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
          _stopPolling(step: 5);
          fetchProjects();
          _showVideoReadySnackbar();
        } else if (videoStatus.value == 'video_failed') {
          // ✅ stop polling on failure too — was previously polling forever
          _stopPolling(step: 0);
          _showError((res['message'] ?? 'Video generation failed.').toString());
          fetchProjects();
        }
      }
    } catch (e) {
      debugPrint('❌ polling: $e');
    }
  }

  void _stopPolling({required int step}) {
    _pollingTimer?.cancel();
    isPollingVideoStatus.value = false;
    isGeneratingVideo.value    = false;
    generationStep.value       = step;
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
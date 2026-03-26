// lib/core/endpoint/api_endpoint.dart

class ApiEndpoint {
  static const String baseUrl = "https://heygen.dsrt321.online";

  // ─── Auth - Registration ───────────────────────────────────────────
  static const String signup      = "/api/v1/auth/signup/";
  static const String verifyOtp   = "/api/v1/auth/verify-otp/";
  static const String resendOtp   = "/api/v1/auth/resend-otp/";

  // ─── Auth - Login ──────────────────────────────────────────────────
  static const String login       = "/api/v1/auth/login/";

  // ─── Auth - Forgot Password ────────────────────────────────────────
  static const String forgotPassword      = "/api/v1/auth/forgot-password/";
  static const String verifyResetOtp      = "/api/v1/auth/verify-reset-otp/";
  static const String resetPassword       = "/api/v1/auth/reset-password/";

  // ─── Auth - Profile ────────────────────────────────────────────────
  static const String profile     = "/api/v1/auth/profile/";

  // ─── Video Gen - Options ───────────────────────────────────────────
  static const String industries  = "/api/v1/videogen/options/industries/";
  static const String backgrounds = "/api/v1/videogen/options/backgrounds/";
  static const String avatars     = "/api/v1/videogen/options/avatars/";
  static String avatarById(String avatarId) => "/api/v1/videogen/options/avatars/$avatarId/";

  // ─── Video Gen - Projects ──────────────────────────────────────────
  static const String createProject  = "/api/v1/videogen/projects/create/";
  static const String projectList    = "/api/v1/videogen/projects/";
  static String projectDetail(String id)        => "/api/v1/videogen/projects/$id/";
  static String updateProject(String id)        => "/api/v1/videogen/projects/$id/update/";
  static String generateScript(String id)       => "/api/v1/videogen/projects/$id/generate-script/";
  static String finalizeScript(String id)       => "/api/v1/videogen/projects/$id/finalize-script/";
  static String generateVideo(String id)        => "/api/v1/videogen/projects/$id/generate-video/";
  static String videoStatus(String id)          => "/api/v1/videogen/projects/$id/video-status/";

  // ─── Video Gen - TTS ──────────────────────────────────────────────
  static const String ttsPreview   = "/api/v1/videogen/tts/";


  // ─── Subscriptions ─────────────────────────────────────────────────
  static const String mySubscription    = "/api/v1/subscriptions/me/";
  static const String subscriptionPlans = "/api/v1/subscriptions/plans/";
  static const String verifyPurchase    = "/api/v1/subscriptions/verify-purchase/";
  static const String cancelSubscription= "/api/v1/subscriptions/cancel/";
}
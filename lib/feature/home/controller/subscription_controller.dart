// lib/feature/subscription/controller/subscription_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/endpoint/api_client.dart';
import '../../../core/endpoint/api_endpoint.dart';

class PlanModel {
  final int id;
  final String name;
  final String planType;
  final String priceMonthly;
  final String currency;
  final int maxVideosPerMonth;
  final int maxScriptGenerationsPerMonth;
  final bool hasPriorityProcessing;
  final bool hasWatermark;
  final String description;
  final String appleProductId;
  final String googleProductId;

  PlanModel({
    required this.id,
    required this.name,
    required this.planType,
    required this.priceMonthly,
    required this.currency,
    required this.maxVideosPerMonth,
    required this.maxScriptGenerationsPerMonth,
    required this.hasPriorityProcessing,
    required this.hasWatermark,
    required this.description,
    required this.appleProductId,
    required this.googleProductId,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) => PlanModel(
    id: json['id'],
    name: json['name'] ?? '',
    planType: json['plan_type'] ?? '',
    priceMonthly: json['price_monthly'] ?? '0.00',
    currency: json['currency'] ?? 'GBP',
    maxVideosPerMonth: json['max_videos_per_month'] ?? 0,
    maxScriptGenerationsPerMonth: json['max_script_generations_per_month'] ?? 0,
    hasPriorityProcessing: json['has_priority_processing'] ?? false,
    hasWatermark: json['has_watermark'] ?? true,
    description: json['description'] ?? '',
    appleProductId: json['apple_product_id'] ?? '',
    googleProductId: json['google_product_id'] ?? '',
  );

  bool get isPremium => planType == 'pro';
  bool get isFree    => planType == 'free_trial';
}

class SubscriptionController extends GetxController {
  static SubscriptionController get to => Get.put(SubscriptionController(), permanent: true);

  final ApiClient _apiClient = ApiClient(baseUrl: ApiEndpoint.baseUrl);

  final RxBool isLoading        = false.obs;
  final RxBool isPurchasing     = false.obs;
  final RxInt  selectedPlanIdx  = (-1).obs;

  final RxList<PlanModel> plans = <PlanModel>[].obs;

  // Current subscription info
  final RxString currentPlanName        = ''.obs;
  final RxString subscriptionStatus     = ''.obs;
  final RxInt    videosRemaining        = 0.obs;
  final RxInt    scriptsRemaining       = 0.obs;
  final RxBool   trialExhausted         = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
    fetchMySubscription();
  }

  // ─── Fetch available plans ────────────────────────────────────
  // GET /api/v1/subscriptions/plans/
  Future<void> fetchPlans() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.get(
        ApiEndpoint.subscriptionPlans,
        requiresAuth: true,
      );
      if (response != null && response['results'] is List) {
        plans.value =
            (response['results'] as List).map((e) => PlanModel.fromJson(e)).toList();
      }
    } on HttpException catch (e) {
      _showError(e.message);
    } catch (e) {
      print('❌ FetchPlans error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Fetch my subscription ────────────────────────────────────
  // GET /api/v1/subscriptions/me/
  Future<void> fetchMySubscription() async {
    try {
      final response = await _apiClient.get(
        ApiEndpoint.mySubscription,
        requiresAuth: true,
      );
      if (response != null) {
        currentPlanName.value    = response['plan']?['name'] ?? '';
        subscriptionStatus.value = response['status'] ?? '';
        videosRemaining.value    = response['videos_remaining'] ?? 0;
        scriptsRemaining.value   = response['scripts_remaining'] ?? 0;
        trialExhausted.value     = response['trial_exhausted'] ?? false;
      }
    } catch (e) {
      print('❌ FetchMySubscription error: $e');
    }
  }

  // ─── Verify IAP purchase ──────────────────────────────────────
  // POST /api/v1/subscriptions/verify-purchase/
  // body: { platform, product_id, purchase_token, transaction_id }
  Future<void> verifyPurchase({
    required String platform,
    required String productId,
    required String purchaseToken,
    required String transactionId,
  }) async {
    isPurchasing.value = true;
    try {
      await _apiClient.post(
        ApiEndpoint.verifyPurchase,
        body: {
          'platform'      : platform,
          'product_id'    : productId,
          'purchase_token': purchaseToken,
          'transaction_id': transactionId,
        },
        requiresAuth: true,
      );
      await fetchMySubscription();
      _showSuccess('Subscription activated successfully!');
    } on HttpException catch (e) {
      final parsed = _tryParseBody(e.body);
      _showError(_extractMessage(parsed) ?? e.message);
    } catch (e) {
      print('❌ VerifyPurchase error: $e');
      _showError('Purchase verification failed.');
    } finally {
      isPurchasing.value = false;
    }
  }

  // ─── Cancel subscription ─────────────────────────────────────
  // POST /api/v1/subscriptions/cancel/
  Future<void> cancelSubscription() async {
    isLoading.value = true;
    try {
      await _apiClient.post(
        ApiEndpoint.cancelSubscription,
        requiresAuth: true,
      );
      await fetchMySubscription();
      _showSuccess('Subscription cancelled.');
    } on HttpException catch (e) {
      _showError(e.message);
    } catch (e) {
      print('❌ CancelSubscription error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPlan(int index) => selectedPlanIdx.value = index;

  // ─── Helpers ─────────────────────────────────────────────────
  Map<String, dynamic>? _tryParseBody(String? body) {
    if (body == null || body.isEmpty) return null;
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
      if (val is List && val.isNotEmpty) return val.first.toString();
      if (val is String) return val;
    }
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    final context = Get.context;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
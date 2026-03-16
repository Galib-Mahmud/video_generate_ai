// lib/feature/home/controller/home_controller.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/endpoint/api_client.dart';
import '../../../core/endpoint/api_endpoint.dart';

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

  final RxBool isLoading        = false.obs;
  final RxInt selectedIndex     = (-1).obs;
  final RxList<IndustryModel> industries = <IndustryModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Wait for the current frame to finish so the token is guaranteed
    // to be in memory before the first API call fires.
    fetchIndustries();
  }

  // ─── Fetch Industries ─────────────────────────────────────────
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

  void selectIndustry(int index) => selectedIndex.value = index;

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
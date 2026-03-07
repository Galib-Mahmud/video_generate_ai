// app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color purple = Color(0xFFA691E6);
  static const Color cyan = Color(0xFF69E9E9);

  static const LinearGradient textGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [purple, cyan],
  );
}
import 'package:flutter/material.dart';

/// Centralized brand color palette for StudyFlow.
/// Keeping colors in one place means every screen stays visually consistent,
/// and changing the brand palette later only requires editing this file.
class AppColors {
  AppColors._(); // prevent instantiation

  // Brand
  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF7C3AED);

  // Light theme
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF111827);

  // Dark theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkText = Color(0xFFF8FAFC);

  // Status colors (same in both themes — status meaning shouldn't change)
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}
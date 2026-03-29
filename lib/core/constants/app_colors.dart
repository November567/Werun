import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Centralized color palette for the WeRun app.
/// Use these instead of hardcoding colors throughout the codebase.
class AppColors {
  AppColors._();

  // Brand — matches AppTheme.primary
  static const Color accent = AppTheme.primary;

  // Backgrounds
  static const Color scaffoldBg = Color(0xFF0E0E0E);
  static const Color surfaceBg = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF0E0E0E);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
  static const Color textMuted = Colors.white70;

  // Actions
  static const Color actionGreen = Colors.green;
  static const Color actionRed = Colors.redAccent;
}

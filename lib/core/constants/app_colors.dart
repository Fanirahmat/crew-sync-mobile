import 'package:flutter/material.dart';

/// Official High-Contrast Design System Color Tokens for CrewSync Mobile.
/// Optimized for dim ballroom / event venue visibility and battery efficiency.
class AppColors {
  AppColors._();

  // Core Brand Palette
  static const Color charcoalBlack = Color(0xFF121214);
  static const Color slateGray = Color(0xFF2B2D31);
  static const Color softGray = Color(0xFF6B7280);
  static const Color skyBlue = Color(0xFF54A3FF);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Status & Feedback Colors
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color emeraldGreenTint = Color(0x2610B981); // 15% opacity tint
  static const Color crimsonRed = Color(0xFFEF4444);
  static const Color crimsonRedTint = Color(0x26EF4444);
  static const Color amberOrange = Color(0xFFF59E0B);
  static const Color amberOrangeTint = Color(0x26F59E0B);

  // Semantic Design Tokens
  static const Color background = charcoalBlack;
  static const Color surface = slateGray;
  static const Color primary = skyBlue;
  static const Color textPrimary = pureWhite;
  static const Color textSecondary = softGray;
  static const Color border = softGray;
  static const Color borderSubtle = Color(0xFF3F4248);
  static const Color activeCue = skyBlue;
  static const Color geofenceValid = emeraldGreen;
  static const Color geofenceInvalid = crimsonRed;
}

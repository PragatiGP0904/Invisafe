import 'package:flutter/material.dart';

/// Centralized color palette for the unified Invisafe app.
///
/// The base dark glassmorphism palette is shared by every module so the six
/// integrated modules (originally three separate native apps) present one
/// consistent visual language.
class AppColors {
  AppColors._();

  // Base surfaces
  static const Color background = Color(0xFF0A0E17);
  static const Color surface = Color(0xFF131A26);
  static const Color surfaceAlt = Color(0xFF1B2435);
  static const Color glassWhite = Colors.white10;
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textTertiary = Colors.white38;

  // Per-module accent colors (used for cards, overlays and charts)
  static const Color structuralCyan = Color(0xFF00E5FF);
  static const Color bioSafetyGreen = Color(0xFF00E676);
  static const Color dermaTechPurple = Color(0xFFD500F9);
  static const Color roadVisionOrange = Color(0xFFFF9100);
  static const Color pipelineTeal = Color(0xFF1DE9B6);
  static const Color airSentinelBlue = Color(0xFF29B6F6);

  // Severity / status semantics (shared by all analyzers & reports)
  static const Color severityLow = Color(0xFF00E676);
  static const Color severityModerate = Color(0xFFFFC107);
  static const Color severityHigh = Color(0xFFFF7043);
  static const Color severityCritical = Color(0xFFFF1744);

  /// Maps a 0..1 severity score to a color on the low→critical gradient.
  static Color severityColor(double score) {
    if (score < 0.25) return severityLow;
    if (score < 0.5) return severityModerate;
    if (score < 0.75) return severityHigh;
    return severityCritical;
  }
}

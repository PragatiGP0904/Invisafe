import 'package:flutter/material.dart';

/// Descriptor for one of the six integrated modules. Drives the home grid and
/// the central navigation registry.
class ModuleInfo {
  final String id;
  final String title;
  final String subtitle;
  final Color accentColor;

  /// Fallback vector icon (always rendered if [iconAsset] is null/missing).
  final IconData icon;

  /// Optional rich icon image (e.g. assets/icons/structural.png). When present
  /// it is shown instead of [icon], with [icon] used as a graceful fallback.
  final String? iconAsset;

  final String routeName;

  const ModuleInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.routeName,
    this.iconAsset,
  });
}

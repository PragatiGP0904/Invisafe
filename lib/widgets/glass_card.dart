import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Reusable glassmorphism container matching the home-screen design language.
/// Used everywhere so the six modules share one card style.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            color: AppColors.surface.withOpacity(0.45),
            border: Border.all(
              color: (borderColor ?? AppColors.glassWhite).withOpacity(0.25),
              width: 1.2,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

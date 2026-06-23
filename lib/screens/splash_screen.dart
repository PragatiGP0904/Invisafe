import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/navigation/app_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// Branded splash, ported from InviSafeP's SplashActivity (logo fade/scale,
/// then route to home).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.of(context).pushReplacementNamed(AppRouter.home);
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _c,
          child: ScaleTransition(
            scale:
                Tween<double>(begin: 0.8, end: 1).animate(CurvedAnimation(
              parent: _c,
              curve: Curves.easeOutBack,
            )),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield_moon_outlined,
                    size: 88, color: AppColors.structuralCyan),
                const SizedBox(height: 16),
                Text(AppConstants.appName.toUpperCase(),
                    style: AppTheme.heading(32)),
                const SizedBox(height: 8),
                const Text(
                  AppConstants.tagline,
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      letterSpacing: 3,
                      fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

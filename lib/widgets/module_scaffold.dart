import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Standard scaffold for every module screen: consistent gradient background,
/// accent-tinted title and a back button. Centralizing this satisfies the
/// "standardize navigation/theme" requirement.
class ModuleScaffold extends StatelessWidget {
  final String title;
  final Color accent;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ModuleScaffold({
    super.key,
    required this.title,
    required this.accent,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: accent, letterSpacing: 1.4)),
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accent.withOpacity(0.08),
              AppColors.background,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(child: body),
      ),
    );
  }
}

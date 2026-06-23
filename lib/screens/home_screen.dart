import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/navigation/app_router.dart';
import '../core/theme/app_colors.dart';
import '../widgets/scenario_card.dart';

/// Unified home hub. All six modules are shown in a responsive glassmorphism
/// grid driven by [AppRouter.modules], each routing to its real module screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _navigateToModule(BuildContext context, String routeName) {
    Navigator.of(context).pushNamed(routeName);
  }

  /// Responsive column count: 2 on phones, 3 on tablets, 4 on wide screens.
  int _columnsFor(double width) {
    if (width >= 1100) return 4;
    if (width >= 720) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final columns = _columnsFor(width);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildTopSection(context)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              sliver: _buildModuleGrid(context, columns),
            ),
            SliverToBoxAdapter(child: _buildBottomSection(context)),
            const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 36, 24, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_moon_outlined,
                        color: AppColors.structuralCyan, size: 26),
                    const SizedBox(width: 10),
                    Text(
                      'INVISAFE',
                      style: GoogleFonts.syncopate(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.settings,
                      color: AppColors.textSecondary),
                  onPressed: () {},
                )
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              width: 80,
              decoration: BoxDecoration(
                color: AppColors.structuralCyan,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.structuralCyan.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // Welcome banner
            const Text(
              'Welcome back, Operator',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'MULTI-MODAL VISION INTELLIGENCE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.auto_awesome,
                    size: 14, color: AppColors.airSentinelBlue),
                const SizedBox(width: 6),
                const Text(
                  'AI + AR Safety Platform',
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  'MODULES',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '6 ACTIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.bioSafetyGreen,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleGrid(BuildContext context, int columns) {
    final modules = AppRouter.modules;
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final m = modules[index];
          return FadeInUp(
            duration: const Duration(milliseconds: 450),
            delay: Duration(milliseconds: 80 * index),
            from: 24,
            child: ScenarioCard(
              title: m.title,
              subtitle: m.subtitle,
              accentColor: m.accentColor,
              iconData: m.icon,
              iconAsset: m.iconAsset,
              onTap: () => _navigateToModule(context, m.routeName),
            ),
          );
        },
        childCount: modules.length,
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 520),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DASHBOARD',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDashboardMetric('Recent Reports', '12',
                      Icons.insert_chart, AppColors.structuralCyan),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDashboardMetric('Scan History', '1,403',
                      Icons.history, AppColors.bioSafetyGreen),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _navigateToModule(
                    context, AppRouter.modules.first.routeName),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner),
                    SizedBox(width: 12),
                    Text(
                      'QUICK SCAN',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardMetric(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassWhite.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

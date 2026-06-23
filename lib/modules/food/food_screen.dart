import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/detection_result.dart';
import '../../models/nutrition_info.dart';
import '../../models/scan_report.dart';
import '../../models/user_health_profile.dart';
import '../../services/camera_service.dart';
import '../../widgets/camera_preview_widget.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/module_scaffold.dart';
import '../../widgets/report_page.dart';
import '../../widgets/scan_overlay.dart';
import 'food_advisor.dart';
import 'food_classifier.dart';
import 'food_preferences_screen.dart';
import 'food_repository.dart';

/// Food & Nutrition Analysis module screen.
class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  final CameraService _camera = CameraService();
  final FoodClassifier _classifier = FoodClassifier();
  bool _ready = false;
  bool _scanning = false;
  NutritionInfo? _result;
  PersonalizedAdvice? _advice;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _camera.initialize();
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    if (_scanning) return;
    setState(() => _scanning = true);
    final path = await _camera.capture();
    await Future<void>.delayed(AppConstants.scanDuration);
    final label = _classifier.classify(imagePath: path);
    final info = FoodRepository.lookup(label);
    final advice =
        FoodAdvisor.advise(info, UserHealthProfileStore.instance.profile);
    if (!mounted) return;
    setState(() {
      _scanning = false;
      _result = info;
      _advice = advice;
    });
  }

  ScanReport _report(NutritionInfo info, PersonalizedAdvice advice) {
    return ScanReport(
      moduleId: 'food',
      moduleTitle: 'Food & Nutrition',
      title: '${info.name} Analysis',
      riskLevel: switch (info.status) {
        HealthStatus.healthy => RiskLevel.low,
        HealthStatus.moderate => RiskLevel.moderate,
        HealthStatus.unhealthy => RiskLevel.high,
      },
      summary:
          '${info.name} recognized. ${advice.message} ${info.tip}',
      metrics: {
        'Calories': '${info.calories} kcal',
        'Protein': '${info.protein} g',
        'Carbs': '${info.carbs} g',
        'Fat': '${info.fat} g',
        'Vitamin C': '${info.vitaminC} mg',
        'Health Rating': '${info.healthRating}/5',
      },
      detections: [
        DetectionResult(
          label: info.name,
          description: advice.message,
          confidence: 0.9,
          severity: switch (info.status) {
            HealthStatus.healthy => 0.1,
            HealthStatus.moderate => 0.45,
            HealthStatus.unhealthy => 0.75,
          },
        ),
      ],
      recommendations: [info.tip],
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.bioSafetyGreen;
    return ModuleScaffold(
      title: 'BIO-SAFETY',
      accent: accent,
      actions: [
        IconButton(
          icon: const Icon(Icons.tune),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const FoodPreferencesScreen())),
        ),
      ],
      body: !_ready
          ? const Center(child: CircularProgressIndicator(color: accent))
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CameraPreviewWidget(
                            service: _camera, accent: accent),
                      ),
                      ScanOverlay(
                          accent: accent,
                          active: _scanning,
                          label: 'IDENTIFYING FOOD'),
                    ],
                  ),
                ),
                if (_result != null && _advice != null)
                  _resultPanel(_result!, _advice!, accent),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: _scanning ? null : _scan,
                    icon: const Icon(Icons.restaurant),
                    label: Text(_scanning ? 'Scanning…' : 'Scan Food'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _resultPanel(
      NutritionInfo info, PersonalizedAdvice advice, Color accent) {
    final statusColor = switch (advice.status) {
      RecommendationStatus.recommended => AppColors.severityLow,
      RecommendationStatus.caution => AppColors.severityModerate,
      RecommendationStatus.avoid => AppColors.severityHigh,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassCard(
        borderColor: statusColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(info.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('${info.calories} kcal',
                    style: TextStyle(color: accent, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 6),
            Text(advice.message, style: TextStyle(color: statusColor)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ReportPage(
                      report: _report(info, advice), accent: accent),
                )),
                icon: const Icon(Icons.description),
                label: const Text('View Full Report'),
                style: TextButton.styleFrom(foregroundColor: accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

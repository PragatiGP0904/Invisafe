import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/detection_result.dart';
import '../../models/scan_report.dart';
import '../../widgets/scan_screen.dart';
import 'skin_analyzer.dart';

/// Skin Health Assessment module screen (front camera).
class SkinScreen extends StatelessWidget {
  const SkinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScanScreen(
      moduleId: 'skin',
      title: 'DERMA-TECH',
      accent: AppColors.dermaTechPurple,
      lens: CameraLensDirection.front,
      engine: SkinAnalyzer(),
      scanLabel: 'ANALYZING SKIN',
      buildReport: _buildReport,
    );
  }

  ScanReport _buildReport(List<DetectionResult> detections) {
    final avg = detections.isEmpty
        ? 0.0
        : detections.map((d) => d.severity).reduce((a, b) => a + b) /
            detections.length;
    final healthScore = ((1 - avg) * 100).round();
    return ScanReport(
      moduleId: 'skin',
      moduleTitle: 'Skin Health',
      title: 'Clinical Vitality Assessment',
      riskLevel: riskFromScore(avg),
      summary:
          'Facial region analysis complete. Overall skin health score: $healthScore/100 '
          'across ${detections.length} regions.',
      metrics: {
        'Health Score': '$healthScore/100',
        'Regions Analyzed': '${detections.length}',
        'Avg Concern': '${(avg * 100).round()}%',
      },
      detections: detections,
      recommendations: const [
        'Maintain hydration and a consistent cleansing routine.',
        'Use SPF daily to limit UV-related damage.',
        'Consult a dermatologist if high-severity concerns persist.',
      ],
    );
  }
}

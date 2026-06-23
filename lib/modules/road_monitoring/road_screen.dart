import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/detection_result.dart';
import '../../models/scan_report.dart';
import '../../widgets/demo_simulation_view.dart';
import '../../widgets/progression_chart.dart';
import '../../widgets/scan_screen.dart';
import 'road_analyzer.dart';

/// Road Crack / Pothole Detection module screen.
class RoadScreen extends StatelessWidget {
  const RoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScanScreen(
      moduleId: 'road',
      title: 'ROAD VISION',
      accent: AppColors.roadVisionOrange,
      engine: const RoadAnalyzer(),
      scanLabel: 'SCANNING ROAD SURFACE',
      actionLabel: 'Run Road AI',
      arView: const RoadSimulationView(),
      buildReport: _buildReport,
      reportChart: (_) => const ProgressionChart(
        stages: RoadAnalyzer.stages,
        values: RoadAnalyzer.stageValues,
        accent: AppColors.roadVisionOrange,
      ),
    );
  }

  ScanReport _buildReport(List<DetectionResult> detections) {
    final worst = detections.isEmpty
        ? 0.0
        : detections.map((d) => d.severity).reduce((a, b) => a > b ? a : b);
    return ScanReport(
      moduleId: 'road',
      moduleTitle: 'Road Surface',
      title: 'Road Surface Risk Report',
      riskLevel: riskFromScore(worst),
      summary:
          'AR-based visual & progression inference complete. Cracking and pothole '
          'formation detected; sub-base degradation risk is elevated.',
      metrics: {
        RoadAnalyzer.stages[1]: '${RoadAnalyzer.stageValues[1].round()}%',
        'Pothole Severity': '${RoadAnalyzer.stageValues[2].round()}%',
        'Sub-base Risk': '${RoadAnalyzer.stageValues[3].round()}%',
        'Detections': '${detections.length}',
      },
      detections: detections,
      recommendations: const [
        'Schedule crack sealing within 2 weeks to prevent water ingress.',
        'Patch active potholes; prioritize high-traffic lanes.',
        'Survey sub-base for moisture-driven deterioration.',
      ],
    );
  }
}

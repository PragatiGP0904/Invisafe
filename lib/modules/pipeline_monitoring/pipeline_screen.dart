import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/detection_result.dart';
import '../../models/scan_report.dart';
import '../../services/ar_service.dart';
import '../../widgets/demo_simulation_view.dart';
import '../../widgets/progression_chart.dart';
import '../../widgets/scan_screen.dart';
import 'pipeline_analyzer.dart';

/// Pipeline Leak / Damage Detection module screen (AR / 3D model view).
class PipelineScreen extends StatelessWidget {
  const PipelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScanScreen(
      moduleId: 'pipeline',
      title: 'PIPELINE GUARD',
      accent: AppColors.pipelineTeal,
      engine: const PipelineAnalyzer(),
      scanLabel: 'SCANNING PIPELINE',
      actionLabel: 'Run Pipeline AI',
      arView: PipelineSimulationView(
        modelView: ArService.instance.buildViewer(
          moduleId: 'pipeline',
          accent: AppColors.pipelineTeal,
          overlayLabel: 'UNDERGROUND PIPELINE',
        ),
      ),
      buildReport: _buildReport,
      reportChart: (_) => const ProgressionChart(
        stages: PipelineAnalyzer.stages,
        values: PipelineAnalyzer.stageValues,
        accent: AppColors.pipelineTeal,
      ),
    );
  }

  ScanReport _buildReport(List<DetectionResult> detections) {
    final worst = detections.isEmpty
        ? 0.0
        : detections.map((d) => d.severity).reduce((a, b) => a > b ? a : b);
    return ScanReport(
      moduleId: 'pipeline',
      moduleTitle: 'Underground Pipeline',
      title: 'Underground Pipeline Risk Report',
      riskLevel: riskFromScore(worst),
      summary:
          'Subsurface AR inspection complete. Corrosion and joint stress detected; '
          'monitor identified leak-risk points.',
      metrics: {
        for (var i = 0; i < PipelineAnalyzer.stages.length; i++)
          PipelineAnalyzer.stages[i]: '${PipelineAnalyzer.stageValues[i].round()}%',
      },
      detections: detections,
      recommendations: const [
        'Apply anti-corrosion coating to affected sections.',
        'Inspect high-stress joints; schedule preventive repair.',
        'Install leak sensors at identified risk points.',
      ],
    );
  }
}

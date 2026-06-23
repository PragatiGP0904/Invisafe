import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/detection_result.dart';
import '../../models/scan_report.dart';
import '../../widgets/scan_screen.dart';
import 'structural_analyzer.dart';

/// Entry screen for the Structural Safety module.
class StructuralScreen extends StatelessWidget {
  const StructuralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScanScreen(
      moduleId: 'structural',
      title: 'STRUCTURAL',
      accent: AppColors.structuralCyan,
      engine: StructuralAnalyzer(),
      scanLabel: 'SCANNING STRUCTURE',
      buildReport: _buildReport,
    );
  }

  ScanReport _buildReport(List<DetectionResult> detections) {
    final worst = detections.isEmpty
        ? 0.0
        : detections.map((d) => d.severity).reduce((a, b) => a > b ? a : b);
    return ScanReport(
      moduleId: 'structural',
      moduleTitle: 'Structural Safety',
      title: 'Wall Integrity Assessment',
      riskLevel: riskFromScore(worst),
      summary:
          'Surface analysis complete. ${detections.length} structural indicators evaluated for cracks, '
          'moisture ingress and coating degradation.',
      metrics: {
        'Indicators': '${detections.length}',
        'Peak Severity': '${(worst * 100).round()}%',
        'Scan Mode': 'Heuristic Edge/Texture',
      },
      detections: detections,
      recommendations: const [
        'Seal active cracks and monitor width over 30 days.',
        'Investigate moisture source; improve drainage / waterproofing.',
        'Re-coat peeling areas after surface preparation.',
      ],
    );
  }
}

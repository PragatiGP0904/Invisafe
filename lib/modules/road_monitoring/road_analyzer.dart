import 'dart:ui';

import '../../models/detection_result.dart';
import '../../services/inference_service.dart';

/// Road crack / pothole analyzer.
///
/// InvisafeU implemented "detection" as a demo video/image swap with hardcoded
/// report percentages (25 / 48 / 67 / 62). We reproduce equivalent findings.
class RoadAnalyzer extends SimulatedInferenceEngine {
  const RoadAnalyzer();

  @override
  String get moduleId => 'road';

  /// Hardcoded progression stages from the original Road Surface Risk Report.
  static const List<String> stages = [
    'Crack Init.',
    'Surface Wear',
    'Pothole',
    'Sub-base',
  ];
  static const List<double> stageValues = [25, 48, 67, 62];

  @override
  List<DetectionResult> produce(InferenceInput input) {
    return const [
      DetectionResult(
        label: 'Surface Crack',
        description: 'Longitudinal cracking detected on the carriageway.',
        confidence: 0.82,
        severity: 0.48,
        boundingBox: Rect.fromLTWH(0.15, 0.55, 0.55, 0.10),
      ),
      DetectionResult(
        label: 'Pothole',
        description: 'Depression / material loss indicating an active pothole.',
        confidence: 0.74,
        severity: 0.67,
        boundingBox: Rect.fromLTWH(0.45, 0.40, 0.25, 0.20),
      ),
    ];
  }
}

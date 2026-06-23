import 'dart:math';
import 'dart:ui';

import '../../models/detection_result.dart';
import '../../services/inference_service.dart';

/// Structural safety analyzer (wall crack & dampness detection).
///
/// Ported from InviSafeP's StructureAnalyzer, which used pixel luminance/edge
/// /texture heuristics (no neural model). Here we reproduce the same kind of
/// heuristic findings. When a real captured image is wired in, replace
/// [produce] with on-device edge analysis using the `image` package.
class StructuralAnalyzer extends SimulatedInferenceEngine {
  StructuralAnalyzer({Random? random}) : _rng = random ?? Random();

  final Random _rng;

  @override
  String get moduleId => 'structural';

  @override
  List<DetectionResult> produce(InferenceInput input) {
    final crackSeverity = 0.4 + _rng.nextDouble() * 0.5;
    final dampSeverity = _rng.nextDouble() * 0.6;
    final peelSeverity = _rng.nextDouble() * 0.4;

    return [
      DetectionResult(
        label: 'Surface Crack',
        description:
            'Linear fracture detected along the masonry surface. Monitor for propagation.',
        confidence: 0.7 + _rng.nextDouble() * 0.25,
        severity: crackSeverity,
        boundingBox: Rect.fromLTWH(0.18, 0.30, 0.42, 0.12),
      ),
      DetectionResult(
        label: 'Dampness / Moisture',
        description:
            'Elevated moisture signature consistent with water ingress or rising damp.',
        confidence: 0.55 + _rng.nextDouble() * 0.3,
        severity: dampSeverity,
        boundingBox: Rect.fromLTWH(0.55, 0.55, 0.30, 0.22),
      ),
      DetectionResult(
        label: 'Paint Peeling',
        description: 'Coating delamination / flaking detected on the surface.',
        confidence: 0.5 + _rng.nextDouble() * 0.3,
        severity: peelSeverity,
        boundingBox: Rect.fromLTWH(0.10, 0.66, 0.25, 0.18),
      ),
    ];
  }
}

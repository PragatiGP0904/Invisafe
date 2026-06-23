import 'dart:math';
import 'dart:ui';

import '../../models/detection_result.dart';
import '../../services/inference_service.dart';

/// Skin health analyzer.
///
/// Ported from InviSafeP's SkinAnalyzer, which ran color/texture heuristics on
/// facial regions detected via ML Kit. Here we reproduce per-region findings.
/// To restore real face detection, plug in `google_mlkit_face_detection` and
/// feed region crops into [produce].
class SkinAnalyzer extends SimulatedInferenceEngine {
  SkinAnalyzer({Random? random}) : _rng = random ?? Random();

  final Random _rng;

  @override
  String get moduleId => 'skin';

  @override
  List<DetectionResult> produce(InferenceInput input) {
    double sev() => _rng.nextDouble();
    return [
      DetectionResult(
        label: 'Forehead Oiliness',
        description: 'Sebum reflectance above baseline on the forehead region.',
        confidence: 0.6 + _rng.nextDouble() * 0.3,
        severity: sev() * 0.7,
        boundingBox: const Rect.fromLTWH(0.30, 0.15, 0.40, 0.12),
      ),
      DetectionResult(
        label: 'Cheek Redness',
        description: 'Elevated redness index on the cheeks (possible irritation).',
        confidence: 0.55 + _rng.nextDouble() * 0.3,
        severity: sev() * 0.8,
        boundingBox: const Rect.fromLTWH(0.18, 0.45, 0.22, 0.18),
      ),
      DetectionResult(
        label: 'Under-Eye Darkness',
        description: 'Darkness/contrast under the eyes (fatigue indicator).',
        confidence: 0.5 + _rng.nextDouble() * 0.3,
        severity: sev() * 0.6,
        boundingBox: const Rect.fromLTWH(0.33, 0.38, 0.34, 0.07),
      ),
      DetectionResult(
        label: 'Chin Texture',
        description: 'Texture variance suggesting blemishes around the chin.',
        confidence: 0.5 + _rng.nextDouble() * 0.3,
        severity: sev() * 0.65,
        boundingBox: const Rect.fromLTWH(0.40, 0.72, 0.20, 0.12),
      ),
    ];
  }
}

import 'dart:async';

import '../core/constants/app_constants.dart';
import '../models/detection_result.dart';

/// Input passed to an inference engine. [imagePath] is the captured still (may
/// be null when running on a device without a camera).
class InferenceInput {
  final String? imagePath;
  final Map<String, dynamic> context;
  const InferenceInput({this.imagePath, this.context = const {}});
}

/// Standardized AI inference pipeline contract.
///
/// Every module implements this so the UI layer is identical: show preview →
/// run [analyze] → render detections + report. Concrete engines may use real
/// heuristics, on-device ML (future), or scripted demo data — the UI does not
/// care.
abstract class InferenceEngine {
  String get moduleId;

  /// Runs analysis and returns findings. Implementations should be resilient
  /// (never throw) and may simulate latency to mirror the original demos.
  Future<List<DetectionResult>> analyze(InferenceInput input);
}

/// Base engine that simulates processing latency, matching the ~3s scan flows
/// used by the original native apps. Subclasses override [produce].
abstract class SimulatedInferenceEngine implements InferenceEngine {
  const SimulatedInferenceEngine();

  Duration get latency => AppConstants.scanDuration;

  /// Produce findings for the given input. Override per module.
  FutureOr<List<DetectionResult>> produce(InferenceInput input);

  @override
  Future<List<DetectionResult>> analyze(InferenceInput input) async {
    await Future<void>.delayed(latency);
    try {
      return await produce(input);
    } catch (_) {
      return const <DetectionResult>[];
    }
  }
}

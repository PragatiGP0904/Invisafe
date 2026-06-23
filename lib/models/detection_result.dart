import 'dart:ui';

/// A single finding produced by any module's inference pipeline.
///
/// This unifies the per-module result types from the three source apps
/// (StructureAnalyzer.AnalysisResult, SkinAnalyzer.AnalysisResult,
/// FoodResult, road/pipeline detections) behind one shape so the shared
/// overlay + report widgets can render them all.
class DetectionResult {
  final String label;
  final String description;

  /// 0..1 model/heuristic confidence.
  final double confidence;

  /// 0..1 severity score (drives severity color).
  final double severity;

  /// Optional normalized bounding box (0..1 in each axis) for AR overlays.
  final Rect? boundingBox;

  const DetectionResult({
    required this.label,
    this.description = '',
    this.confidence = 0,
    this.severity = 0,
    this.boundingBox,
  });

  String get severityLabel {
    if (severity < 0.25) return 'Low';
    if (severity < 0.5) return 'Moderate';
    if (severity < 0.75) return 'High';
    return 'Critical';
  }
}

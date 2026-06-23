import 'detection_result.dart';

enum RiskLevel { low, moderate, high, critical }

/// Maps a 0..1 severity score to a [RiskLevel]. Shared by all modules.
RiskLevel riskFromScore(double s) {
  if (s < 0.25) return RiskLevel.low;
  if (s < 0.5) return RiskLevel.moderate;
  if (s < 0.75) return RiskLevel.high;
  return RiskLevel.critical;
}

extension RiskLevelX on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.moderate:
        return 'Moderate';
      case RiskLevel.high:
        return 'High';
      case RiskLevel.critical:
        return 'Critical';
    }
  }

  double get score {
    switch (this) {
      case RiskLevel.low:
        return 0.15;
      case RiskLevel.moderate:
        return 0.45;
      case RiskLevel.high:
        return 0.7;
      case RiskLevel.critical:
        return 0.9;
    }
  }
}

/// Unified report model shared by every module.
///
/// The original apps each had a bespoke report (P generated a real PDF, K & U
/// only produced UI/Toast). This single model feeds the standardized
/// ReportService (PDF export + share) and the in-app report view.
class ScanReport {
  final String moduleId;
  final String moduleTitle;
  final String title;
  final DateTime timestamp;
  final RiskLevel riskLevel;
  final String summary;

  /// Ordered key/value metrics shown in the report header.
  final Map<String, String> metrics;

  /// Detailed findings.
  final List<DetectionResult> detections;

  /// Actionable recommendations / maintenance tips.
  final List<String> recommendations;

  ScanReport({
    required this.moduleId,
    required this.moduleTitle,
    required this.title,
    required this.riskLevel,
    required this.summary,
    DateTime? timestamp,
    this.metrics = const {},
    this.detections = const [],
    this.recommendations = const [],
  }) : timestamp = timestamp ?? DateTime.now();

  /// Plain-text rendering used for share/export fallbacks.
  String toFormattedString() {
    final buffer = StringBuffer()
      ..writeln('INVISAFE REPORT')
      ..writeln('Module: $moduleTitle')
      ..writeln('Title: $title')
      ..writeln('Generated: $timestamp')
      ..writeln('Overall Risk: ${riskLevel.label}')
      ..writeln('')
      ..writeln('Summary:')
      ..writeln(summary)
      ..writeln('');
    if (metrics.isNotEmpty) {
      buffer.writeln('Metrics:');
      metrics.forEach((k, v) => buffer.writeln('  - $k: $v'));
      buffer.writeln('');
    }
    if (detections.isNotEmpty) {
      buffer.writeln('Findings:');
      for (final d in detections) {
        buffer.writeln(
            '  - ${d.label} (${d.severityLabel}, ${(d.confidence * 100).round()}%)');
        if (d.description.isNotEmpty) buffer.writeln('      ${d.description}');
      }
      buffer.writeln('');
    }
    if (recommendations.isNotEmpty) {
      buffer.writeln('Recommendations:');
      for (final r in recommendations) {
        buffer.writeln('  - $r');
      }
    }
    return buffer.toString();
  }
}

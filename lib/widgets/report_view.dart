import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/detection_result.dart';
import '../models/scan_report.dart';
import '../services/report_service.dart';
import '../utils/format_utils.dart';
import 'glass_card.dart';

/// Standardized report renderer used by every module's report screen.
/// Renders the unified [ScanReport] and wires the shared PDF export / share
/// actions, so all six modules produce reports the same way.
class ReportView extends StatelessWidget {
  final ScanReport report;
  final Color accent;

  /// Optional chart (e.g. fl_chart) injected by the module.
  final Widget? chart;

  const ReportView({
    super.key,
    required this.report,
    required this.accent,
    this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _riskHeader(),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SUMMARY',
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 2)),
              const SizedBox(height: 8),
              Text(report.summary,
                  style: const TextStyle(
                      color: AppColors.textPrimary, height: 1.4)),
            ],
          ),
        ),
        if (report.metrics.isNotEmpty) ...[
          const SizedBox(height: 16),
          GlassCard(child: _metrics()),
        ],
        if (chart != null) ...[
          const SizedBox(height: 16),
          GlassCard(child: SizedBox(height: 220, child: chart!)),
        ],
        if (report.detections.isNotEmpty) ...[
          const SizedBox(height: 16),
          ...report.detections.map(_finding),
        ],
        if (report.recommendations.isNotEmpty) ...[
          const SizedBox(height: 16),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('RECOMMENDATIONS',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 2)),
                const SizedBox(height: 10),
                ...report.recommendations.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 18, color: accent),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(r,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary))),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        _actions(context),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _riskHeader() {
    final color = AppColors.severityColor(report.riskLevel.score);
    return GlassCard(
      borderColor: color,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(Icons.warning_amber_rounded, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('OVERALL RISK',
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 2)),
                const SizedBox(height: 4),
                Text(report.riskLevel.label,
                    style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('Generated ${FormatUtils.dateTime(report.timestamp)}',
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('METRICS',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                letterSpacing: 2)),
        const SizedBox(height: 10),
        ...report.metrics.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  Text(e.value,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            )),
      ],
    );
  }

  Widget _finding(DetectionResult d) {
    final color = AppColors.severityColor(d.severity);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        borderColor: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(d.label,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(d.severityLabel,
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (d.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(d.description,
                  style: const TextStyle(
                      color: AppColors.textSecondary, height: 1.3)),
            ],
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: d.confidence,
              backgroundColor: AppColors.glassWhite,
              color: color,
            ),
            const SizedBox(height: 4),
            Text('Confidence ${(d.confidence * 100).round()}%',
                style:
                    const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _actions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              try {
                await ReportService.instance.exportPdf(report);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('PDF export unavailable on this device')));
                }
              }
            },
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => ReportService.instance.shareText(report),
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              foregroundColor: accent,
              side: BorderSide(color: accent),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

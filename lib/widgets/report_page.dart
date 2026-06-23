import 'package:flutter/material.dart';
import '../models/scan_report.dart';
import 'module_scaffold.dart';
import 'report_view.dart';

/// A full report screen: module scaffold + standardized [ReportView].
class ReportPage extends StatelessWidget {
  final ScanReport report;
  final Color accent;
  final Widget? chart;

  const ReportPage({
    super.key,
    required this.report,
    required this.accent,
    this.chart,
  });

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      title: '${report.moduleTitle} Report',
      accent: accent,
      body: ReportView(report: report, accent: accent, chart: chart),
    );
  }
}

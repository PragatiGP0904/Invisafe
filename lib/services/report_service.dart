import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/scan_report.dart';

/// Standardized report generation + sharing pipeline.
///
/// Only InviSafeP generated a real PDF originally; K and U only showed a Toast.
/// This service gives every module a real, consistent PDF export plus a
/// plain-text share fallback, driven by the unified [ScanReport] model.
class ReportService {
  ReportService._();
  static final ReportService instance = ReportService._();

  /// Builds a PDF document from a [ScanReport].
  Future<pw.Document> buildPdf(ScanReport report) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('INVISAFE — ${report.moduleTitle}',
                style: pw.TextStyle(
                    fontSize: 20, fontWeight: pw.FontWeight.bold)),
          ),
          pw.Text(report.title,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Generated: ${report.timestamp}'),
          pw.Text('Overall Risk: ${report.riskLevel.label}'),
          pw.Divider(),
          pw.Text('Summary',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(report.summary),
          pw.SizedBox(height: 10),
          if (report.metrics.isNotEmpty) ...[
            pw.Text('Metrics',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              data: [
                ['Metric', 'Value'],
                ...report.metrics.entries.map((e) => [e.key, e.value]),
              ],
            ),
            pw.SizedBox(height: 10),
          ],
          if (report.detections.isNotEmpty) ...[
            pw.Text('Findings',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Table.fromTextArray(
              data: [
                ['Finding', 'Severity', 'Confidence'],
                ...report.detections.map((d) => [
                      d.label,
                      d.severityLabel,
                      '${(d.confidence * 100).round()}%',
                    ]),
              ],
            ),
            pw.SizedBox(height: 10),
          ],
          if (report.recommendations.isNotEmpty) ...[
            pw.Text('Recommendations',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Bullet(text: report.recommendations.join('\n')),
          ],
        ],
      ),
    );
    return doc;
  }

  /// Opens the system print/share-as-PDF dialog.
  Future<void> exportPdf(ScanReport report) async {
    final doc = await buildPdf(report);
    final bytes = await doc.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Invisafe_${report.moduleId}_${report.timestamp.millisecondsSinceEpoch}.pdf',
    );
  }

  /// Plain-text share fallback (works even where printing is unavailable).
  Future<void> shareText(ScanReport report) async {
    await Share.share(report.toFormattedString(),
        subject: 'Invisafe ${report.moduleTitle} Report');
  }
}

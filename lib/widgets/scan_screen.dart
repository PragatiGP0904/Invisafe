import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../models/detection_result.dart';
import '../models/scan_report.dart';
import '../services/camera_service.dart';
import '../services/inference_service.dart';
import 'camera_preview_widget.dart';
import 'detection_overlay.dart';
import 'module_scaffold.dart';
import 'report_page.dart';
import 'scan_overlay.dart';

/// Reusable camera-scan flow shared by the Structural, Skin, Road and Pipeline
/// modules. Standardizes camera + AI inference + AR overlay + navigation to the
/// unified report — exactly the cross-cutting concerns the integration asked to
/// standardize.
class ScanScreen extends StatefulWidget {
  final String moduleId;
  final String title;
  final Color accent;
  final CameraLensDirection lens;
  final InferenceEngine engine;
  final String scanLabel;
  final String actionLabel;

  /// Optional 3D/AR preview shown instead of the camera (pipeline module).
  final Widget? arView;

  /// Builds the unified report from the findings.
  final ScanReport Function(List<DetectionResult> detections) buildReport;

  /// Optional chart widget for the report screen.
  final Widget? Function(ScanReport report)? reportChart;

  const ScanScreen({
    super.key,
    required this.moduleId,
    required this.title,
    required this.accent,
    required this.engine,
    required this.buildReport,
    this.lens = CameraLensDirection.back,
    this.scanLabel = 'ANALYZING',
    this.actionLabel = 'Start Scan',
    this.arView,
    this.reportChart,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final CameraService _camera = CameraService();
  bool _ready = false;
  bool _scanning = false;
  List<DetectionResult> _detections = const [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (widget.arView == null) {
      await _camera.initialize(lens: widget.lens);
    }
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  Future<void> _runScan() async {
    if (_scanning) return;
    setState(() {
      _scanning = true;
      _detections = const [];
    });

    final imagePath = await _camera.capture();
    final detections =
        await widget.engine.analyze(InferenceInput(imagePath: imagePath));

    if (!mounted) return;
    setState(() {
      _scanning = false;
      _detections = detections;
    });

    final report = widget.buildReport(detections);
    if (!mounted) return;
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ReportPage(
        report: report,
        accent: widget.accent,
        chart: widget.reportChart?.call(report),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ModuleScaffold(
      title: widget.title,
      accent: widget.accent,
      body: !_ready
          ? Center(child: CircularProgressIndicator(color: widget.accent))
          : Stack(
              children: [
                Positioned.fill(
                  child: widget.arView ??
                      CameraPreviewWidget(
                          service: _camera, accent: widget.accent),
                ),
                if (_detections.isNotEmpty)
                  Positioned.fill(
                    child: DetectionOverlay(
                        detections: _detections, accent: widget.accent),
                  ),
                ScanOverlay(
                    accent: widget.accent,
                    active: _scanning,
                    label: widget.scanLabel),
                Align(
                  alignment: const Alignment(0, 0.95),
                  child: _scanButton(),
                ),
              ],
            ),
    );
  }

  Widget _scanButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: ElevatedButton.icon(
        onPressed: _scanning ? null : _runScan,
        icon: Icon(_scanning ? Icons.hourglass_top : Icons.radar),
        label: Text(_scanning ? 'Scanning…' : widget.actionLabel),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.accent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

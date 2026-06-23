import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/detection_result.dart';

/// Draws AR-style bounding boxes + callouts over a preview for detections that
/// carry a normalized [DetectionResult.boundingBox]. Ported conceptually from
/// InviSafeP's ArOverlayView / SkinArOverlayView (Canvas HUD).
class DetectionOverlay extends StatelessWidget {
  final List<DetectionResult> detections;
  final Color accent;

  const DetectionOverlay({
    super.key,
    required this.detections,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _OverlayPainter(detections, accent),
        size: Size.infinite,
      ),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  final List<DetectionResult> detections;
  final Color accent;
  _OverlayPainter(this.detections, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in detections) {
      final box = d.boundingBox;
      if (box == null) continue;
      final color = AppColors.severityColor(d.severity);
      final rect = Rect.fromLTWH(
        box.left * size.width,
        box.top * size.height,
        box.width * size.width,
        box.height * size.height,
      );

      final stroke = Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8)), stroke);

      // Label chip above the box.
      final tp = TextPainter(
        text: TextSpan(
          text: ' ${d.label} • ${d.severityLabel} ',
          style: TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              backgroundColor: color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(rect.left, (rect.top - 16).clamp(0, size.height)));
    }
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter old) =>
      old.detections != detections;
}

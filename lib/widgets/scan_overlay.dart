import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Animated scanning HUD drawn over the camera preview during inference.
/// Reproduces the "pulse scan" / sweep effect used by the original apps
/// (P's AR overlays, K's ScanningOverlay, U's eye-scan).
class ScanOverlay extends StatefulWidget {
  final Color accent;
  final bool active;
  final String label;

  const ScanOverlay({
    super.key,
    required this.accent,
    required this.active,
    this.label = 'ANALYZING',
  });

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return const SizedBox.shrink();
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return CustomPaint(
            painter: _ScanPainter(_c.value, widget.accent),
            child: Align(
              alignment: const Alignment(0, 0.85),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: widget.accent),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: widget.accent),
                    ),
                    const SizedBox(width: 10),
                    Text('${widget.label}…',
                        style: TextStyle(
                            color: widget.accent,
                            fontSize: 12,
                            letterSpacing: 2)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScanPainter extends CustomPainter {
  final double t;
  final Color accent;
  _ScanPainter(this.t, this.accent);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent.withOpacity(0.8)
      ..strokeWidth = 2;

    // Sweeping horizontal scan line.
    final y = size.height * t;
    final gradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [accent.withOpacity(0), accent.withOpacity(0.25)],
      ).createShader(Rect.fromLTWH(0, y - 40, size.width, 40));
    canvas.drawRect(Rect.fromLTWH(0, y - 40, size.width, 40), gradient);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    // Corner brackets.
    const len = 28.0;
    const margin = 24.0;
    final bracket = Paint()
      ..color = accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    void corner(Offset o, double dx, double dy) {
      canvas.drawLine(o, o.translate(dx, 0), bracket);
      canvas.drawLine(o, o.translate(0, dy), bracket);
    }

    corner(const Offset(margin, margin), len, len);
    corner(Offset(size.width - margin, margin), -len, len);
    corner(Offset(margin, size.height - margin), len, -len);
    corner(Offset(size.width - margin, size.height - margin), -len, -len);
  }

  @override
  bool shouldRepaint(covariant _ScanPainter old) => old.t != t;
}

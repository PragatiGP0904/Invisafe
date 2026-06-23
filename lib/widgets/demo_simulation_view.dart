import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Video-like simulation surfaces for modules whose original Android demos were
/// driven by bundled media instead of live camera frames.
class RoadSimulationView extends StatefulWidget {
  const RoadSimulationView({super.key});

  @override
  State<RoadSimulationView> createState() => _RoadSimulationViewState();
}

class _RoadSimulationViewState extends State<RoadSimulationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/road.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => CustomPaint(
                painter: _RoadFallbackPainter(_controller.value),
              ),
            ),
            CustomPaint(
              painter: _RoadDamagePainter(_controller.value),
            ),
            const _DemoBadge(
              label: 'ROAD CRACK SIMULATION',
              icon: Icons.add_road,
              alignment: Alignment.topLeft,
              color: AppColors.roadVisionOrange,
            ),
          ],
        );
      },
    );
  }
}

class PipelineSimulationView extends StatefulWidget {
  final Widget modelView;

  const PipelineSimulationView({
    super.key,
    required this.modelView,
  });

  @override
  State<PipelineSimulationView> createState() => _PipelineSimulationViewState();
}

class _PipelineSimulationViewState extends State<PipelineSimulationView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _PipelineBackgroundPainter(_controller.value),
            ),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.92,
                heightFactor: 0.62,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.pipelineTeal.withOpacity(0.55),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pipelineTeal.withOpacity(0.22),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: widget.modelView,
                  ),
                ),
              ),
            ),
            const _DemoBadge(
              label: 'PIPELINE AR SIMULATION',
              icon: Icons.plumbing,
              alignment: Alignment.topLeft,
              color: AppColors.pipelineTeal,
            ),
          ],
        );
      },
    );
  }
}

class _DemoBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Alignment alignment;
  final Color color;

  const _DemoBadge({
    required this.label,
    required this.icon,
    required this.alignment,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Container(
          margin: const EdgeInsets.all(18),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.72),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.75)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadDamagePainter extends CustomPainter {
  final double t;

  _RoadDamagePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final crackPaint = Paint()
      ..color = Colors.black.withOpacity(0.72)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final glowPaint = Paint()
      ..color = AppColors.roadVisionOrange.withOpacity(0.36)
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final crack = Path()
      ..moveTo(size.width * 0.18, size.height * 0.58)
      ..lineTo(size.width * 0.30, size.height * 0.54)
      ..lineTo(size.width * 0.42, size.height * 0.60)
      ..lineTo(size.width * 0.56, size.height * 0.56)
      ..lineTo(size.width * 0.72, size.height * 0.62);
    canvas.drawPath(crack, glowPaint);
    canvas.drawPath(crack, crackPaint);

    final potholeCenter = Offset(size.width * 0.58, size.height * 0.44);
    canvas.drawOval(
      Rect.fromCenter(
        center: potholeCenter,
        width: size.width * 0.24,
        height: size.height * 0.12,
      ),
      Paint()
        ..color = Colors.black.withOpacity(0.58)
        ..style = PaintingStyle.fill,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: potholeCenter,
        width: size.width * 0.28,
        height: size.height * 0.15,
      ),
      Paint()
        ..color = AppColors.roadVisionOrange.withOpacity(0.64)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    final scanX = size.width * ((t * 1.35) % 1);
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.roadVisionOrange.withOpacity(0.32),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(scanX - 70, 0, 140, size.height));
    canvas.drawRect(Rect.fromLTWH(scanX - 70, 0, 140, size.height), scanPaint);
  }

  @override
  bool shouldRepaint(covariant _RoadDamagePainter oldDelegate) =>
      oldDelegate.t != t;
}

class _RoadFallbackPainter extends CustomPainter {
  final double t;

  _RoadFallbackPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF24384D), Color(0xFF0B1018)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    final road = Path()
      ..moveTo(size.width * 0.28, size.height)
      ..lineTo(size.width * 0.44, size.height * 0.25)
      ..lineTo(size.width * 0.56, size.height * 0.25)
      ..lineTo(size.width * 0.76, size.height)
      ..close();
    canvas.drawPath(road, Paint()..color = const Color(0xFF242833));

    final lanePaint = Paint()
      ..color = Colors.white.withOpacity(0.58)
      ..strokeWidth = 3;
    for (var i = 0; i < 6; i++) {
      final y = size.height * (0.34 + i * 0.13 + (t * 0.08 % 0.08));
      canvas.drawLine(
        Offset(size.width * 0.50, y),
        Offset(size.width * 0.50, y + size.height * 0.06),
        lanePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoadFallbackPainter oldDelegate) =>
      oldDelegate.t != t;
}

class _PipelineBackgroundPainter extends CustomPainter {
  final double t;

  _PipelineBackgroundPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF061B1D), AppColors.background],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final gridPaint = Paint()
      ..color = AppColors.pipelineTeal.withOpacity(0.12)
      ..strokeWidth = 1;
    const spacing = 34.0;
    final shift = (t * spacing) % spacing;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      canvas.drawLine(Offset(x + shift, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y + shift), Offset(size.width, y), gridPaint);
    }

    final pulsePaint = Paint()
      ..color = AppColors.pipelineTeal.withOpacity(0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < 4; i++) {
      final radius = size.shortestSide * (0.12 + ((t + i * 0.2) % 1) * 0.55);
      canvas.drawCircle(size.center(Offset.zero), radius, pulsePaint);
    }

    final particlePaint = Paint()
      ..color = AppColors.pipelineTeal.withOpacity(0.42)
      ..style = PaintingStyle.fill;
    for (var i = 0; i < 28; i++) {
      final phase = (t + i * 0.037) % 1;
      final x = size.width * ((math.sin(i * 12.9898) * 43758.5453) % 1).abs();
      final y = size.height * phase;
      canvas.drawCircle(Offset(x, y), 1.5 + (i % 3), particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PipelineBackgroundPainter oldDelegate) =>
      oldDelegate.t != t;
}

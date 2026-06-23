import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/detection_result.dart';
import '../../models/scan_report.dart';
import '../../services/camera_service.dart';
import '../../widgets/camera_preview_widget.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/module_scaffold.dart';
import '../../widgets/report_page.dart';
import '../../widgets/scan_overlay.dart';
import 'air_quality_logic.dart';

/// Air Quality & Ventilation module screen.
class AirQualityScreen extends StatefulWidget {
  const AirQualityScreen({super.key});

  @override
  State<AirQualityScreen> createState() => _AirQualityScreenState();
}

class _AirQualityScreenState extends State<AirQualityScreen> {
  final CameraService _camera = CameraService();
  String _disease = AirQualityLogic.diseases.first;
  bool _ready = false;
  bool _analyzing = false;
  AirData? _data;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _camera.initialize();
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (_analyzing) return;
    setState(() => _analyzing = true);
    await Future<void>.delayed(AppConstants.scanDuration);
    if (!mounted) return;
    setState(() {
      _analyzing = false;
      _data = AirData.simulate();
    });
  }

  ScanReport _report(AirData data) {
    final suit = AirQualityLogic.calculateSuitability(_disease, data.aqi);
    final severity = (data.aqi / 200).clamp(0.0, 1.0);
    return ScanReport(
      moduleId: 'air_quality',
      moduleTitle: 'Air Quality',
      title: 'Air & Ventilation — $_disease',
      riskLevel: riskFromScore(severity),
      summary:
          'Air quality analysis for ${AirQualityLogic.location}. AQI ${data.aqi}. ${suit.message}',
      metrics: {
        'Location': AirQualityLogic.location,
        'AQI': '${data.aqi}',
        'Status': suit.label,
        'Temperature': '${data.temperature}°C',
        'Humidity': '${data.humidity}%',
        'PM2.5': data.pm25.toStringAsFixed(1),
        'PM10': data.pm10.toStringAsFixed(1),
        'NO₂': data.no2,
      },
      detections: [
        DetectionResult(
          label: 'AQI ${data.aqi} — ${suit.label}',
          description: suit.message,
          confidence: 0.85,
          severity: severity,
        ),
      ],
      recommendations: const [
        'Ventilate during lower-AQI hours (early morning).',
        'Use HEPA air purification indoors when AQI is elevated.',
        'Sensitive groups should limit outdoor exposure.',
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.airSentinelBlue;
    return ModuleScaffold(
      title: 'AIR SENTINEL',
      accent: accent,
      body: !_ready
          ? const Center(child: CircularProgressIndicator(color: accent))
          : Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CameraPreviewWidget(
                            service: _camera, accent: accent),
                      ),
                      if (_analyzing)
                        const Positioned.fill(child: _WindOverlay()),
                      ScanOverlay(
                          accent: accent,
                          active: _analyzing,
                          label: 'MEASURING AIR FLOW'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      GlassCard(
                        child: Row(
                          children: [
                            const Icon(Icons.coronavirus,
                                color: accent, size: 20),
                            const SizedBox(width: 12),
                            const Text('Condition:',
                                style:
                                    TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButton<String>(
                                value: _disease,
                                isExpanded: true,
                                dropdownColor: AppColors.surface,
                                underline: const SizedBox.shrink(),
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                                items: AirQualityLogic.diseases
                                    .map((d) => DropdownMenuItem(
                                        value: d, child: Text(d)))
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _disease = v ?? _disease),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_data != null) ...[
                        const SizedBox(height: 12),
                        _resultRow(_data!, accent),
                      ],
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _analyzing ? null : _analyze,
                        icon: const Icon(Icons.air),
                        label: Text(_analyzing ? 'Analyzing…' : 'Analyze Air'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _resultRow(AirData data, Color accent) {
    final suit = AirQualityLogic.calculateSuitability(_disease, data.aqi);
    return GlassCard(
      borderColor: suit.color,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('AQI ${data.aqi}',
                  style: TextStyle(
                      color: AirQualityLogic.aqiColor(data.aqi),
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Text(suit.label, style: TextStyle(color: suit.color)),
            ],
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ReportPage(
                report: _report(data),
                accent: accent,
                chart: _AqiChart(data: data),
              ),
            )),
            icon: const Icon(Icons.assessment),
            label: const Text('Report'),
            style: TextButton.styleFrom(foregroundColor: accent),
          ),
        ],
      ),
    );
  }
}

/// Animated wind/ventilation flow effect over the camera (visual only).
class _WindOverlay extends StatefulWidget {
  const _WindOverlay();

  @override
  State<_WindOverlay> createState() => _WindOverlayState();
}

class _WindOverlayState extends State<_WindOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) =>
          CustomPaint(painter: _WindPainter(_c.value), size: Size.infinite),
    );
  }
}

class _WindPainter extends CustomPainter {
  final double t;
  _WindPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.airSentinelBlue.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 6; i++) {
      final y = size.height * (i + 1) / 7;
      final path = Path();
      final offset = (t * size.width * 1.5 + i * 40) % (size.width + 100) - 50;
      path.moveTo(offset, y);
      path.relativeQuadraticBezierTo(40, -20, 80, 0);
      path.relativeQuadraticBezierTo(40, 20, 80, 0);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WindPainter old) => old.t != t;
}

/// Pollutant bar chart for the report.
class _AqiChart extends StatelessWidget {
  final AirData data;
  const _AqiChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final bars = [
      ('AQI', data.aqi.toDouble(), AirQualityLogic.aqiColor(data.aqi)),
      ('PM2.5', data.pm25, AppColors.severityModerate),
      ('PM10', data.pm10, AppColors.severityHigh),
      ('Humid', data.humidity.toDouble(), AppColors.airSentinelBlue),
    ];
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= bars.length) return const SizedBox.shrink();
                return Text(bars[i].$1,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 10));
              },
            ),
          ),
        ),
        barGroups: [
          for (int i = 0; i < bars.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                  toY: bars[i].$2,
                  color: bars[i].$3,
                  width: 18,
                  borderRadius: BorderRadius.circular(4)),
            ]),
        ],
      ),
    );
  }
}

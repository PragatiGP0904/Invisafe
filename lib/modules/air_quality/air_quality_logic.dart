import 'dart:math';

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Simulated air-quality data and suitability rules.
///
/// Ported from InvisafeK's VentilationScreen (random AQI 120–145, derived
/// pollutants, per-disease suitability thresholds). No real sensors/API — same
/// behavior as the original demo.
class AirData {
  final int aqi;
  final int temperature;
  final int humidity;
  final double pm25;
  final double pm10;
  final String no2;

  const AirData({
    required this.aqi,
    required this.temperature,
    required this.humidity,
    required this.pm25,
    required this.pm10,
    required this.no2,
  });

  factory AirData.simulate([Random? rng]) {
    final r = rng ?? Random();
    final aqi = 120 + r.nextInt(26); // 120..145
    return AirData(
      aqi: aqi,
      temperature: 28 + r.nextInt(8),
      humidity: 50 + r.nextInt(30),
      pm25: aqi * 0.45,
      pm10: aqi * 0.9,
      no2: '12 ppb',
    );
  }
}

class Suitability {
  final String label;
  final Color color;
  final String message;
  const Suitability(this.label, this.color, this.message);
}

class AirQualityLogic {
  static const String location = 'Ramapuram, Chennai';

  static const List<String> diseases = [
    'General',
    'Asthma',
    'Pneumonia',
    'COPD',
    'Allergies',
    'Heart Condition',
  ];

  static Color aqiColor(int aqi) {
    if (aqi <= 50) return AppColors.severityLow;
    if (aqi <= 100) return AppColors.severityModerate;
    if (aqi <= 150) return AppColors.severityHigh;
    return AppColors.severityCritical;
  }

  static Suitability calculateSuitability(String disease, int aqi) {
    // Sensitive groups have lower tolerance thresholds.
    final sensitive = disease != 'General';
    final threshold = sensitive ? 100 : 130;
    if (aqi <= threshold) {
      return Suitability('Suitable', AppColors.severityLow,
          'Conditions are acceptable for $disease. Normal ventilation recommended.');
    } else if (aqi <= threshold + 30) {
      return Suitability('Caution', AppColors.severityModerate,
          'Limit prolonged outdoor exposure for $disease. Keep windows partially closed.');
    } else {
      return Suitability('Unsuitable', AppColors.severityHigh,
          'Poor air for $disease. Use air purification and avoid outdoor activity.');
    }
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Risk-progression bar chart used by the Road and Pipeline report screens
/// (replaces InvisafeU's MPAndroidChart bar/line charts).
class ProgressionChart extends StatelessWidget {
  final List<String> stages;
  final List<double> values; // 0..100 percentages
  final Color accent;

  const ProgressionChart({
    super.key,
    required this.stages,
    required this.values,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        maxY: 100,
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true, drawVerticalLine: false),
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
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= stages.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(stages[i],
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 9)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          for (int i = 0; i < values.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(
                toY: values[i],
                color: AppColors.severityColor(values[i] / 100),
                width: 20,
                borderRadius: BorderRadius.circular(4),
              ),
            ]),
        ],
      ),
    );
  }
}

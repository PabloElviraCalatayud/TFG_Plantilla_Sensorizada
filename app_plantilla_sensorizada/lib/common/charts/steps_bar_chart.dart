import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/colors.dart';

class StepsBarChartWidget extends StatelessWidget {
  final List<int> data;

  const StepsBarChartWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Últimos 7 días',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.lightText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  final index = entry.key;
                  final value = entry.value;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: value.toDouble(),
                        color: AppColors.lightPrimary,
                        borderRadius: BorderRadius.circular(6),
                        width: 18,
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

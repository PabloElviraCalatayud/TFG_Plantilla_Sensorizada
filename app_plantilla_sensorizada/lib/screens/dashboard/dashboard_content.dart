import 'package:flutter/material.dart';
import '../../common/widgets/steps_summary_widget.dart';
import '../../common/charts/steps_bar_chart.dart';
import '../../common/widgets/pressure_map_widget.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {

    final weeklySteps = [4500, 6200, 7000, 5500, 8000, 10000, 9200];
    final todaySteps = 3560;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            StepsSummaryWidget(steps: todaySteps),
            const SizedBox(height: 24),

            StepsBarChartWidget(data: weeklySteps),
            const SizedBox(height: 24),

            const PressureMapWidget(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

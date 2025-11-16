import 'package:flutter/material.dart';
import '../core/colors.dart';

class StepsSummaryWidget extends StatelessWidget {
  final int steps;

  const StepsSummaryWidget({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Pasos de hoy',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.lightText,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$steps',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.lightPrimary,
            ),
          )
        ],
      ),
    );
  }
}

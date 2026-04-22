import 'package:flutter/material.dart';

class SetupStepIndicator extends StatelessWidget {
  final int currentStep; // 1-based
  final int totalSteps;

  const SetupStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Step $currentStep of $totalSteps',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
            const Spacer(),
            Text(
              '${((currentStep / totalSteps) * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E5187),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF2E5187)),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

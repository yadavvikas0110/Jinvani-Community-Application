import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Gradient header with back button, title, subtitle and 3-step progress.
class SignupHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int currentStep; // 1-based
  final VoidCallback? onBack;
  final List<String> steps;

  const SignupHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.currentStep,
    this.onBack,
    this.steps = _signupSteps,
  });

  static const _signupSteps = ['Enter Details', 'Enter OTP', 'Create Password'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: const BoxDecoration(gradient: AppColors.headerGradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 44,
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Color(0xFFC6C6C7), fontSize: 14)),
            const SizedBox(height: 16),
            Row(
              children: List.generate(steps.length, (i) {
                final step = i + 1;
                final done = step < currentStep;
                final active = step == currentStep;
                final label = steps[i];
                return Padding(
                  padding: EdgeInsets.only(right: i == steps.length - 1 ? 0 : 20),
                  child: Row(
                    children: [
                      _StepDot(step: step, done: done, active: active),
                      const SizedBox(width: 4),
                      Text(
                        label,
                        style: TextStyle(
                          color: active || done ? Colors.white : const Color(0xFFB8A6D3),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int step;
  final bool done;
  final bool active;
  const _StepDot({required this.step, required this.done, required this.active});

  @override
  Widget build(BuildContext context) {
    if (done) {
      return const Icon(Icons.check_circle, color: Colors.white, size: 14);
    }
    return Container(
      width: 14,
      height: 14,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? Colors.white : const Color(0xFFB8A6D3),
        shape: BoxShape.circle,
      ),
      child: Text(
        '$step',
        style: TextStyle(
          color: active ? const Color(0xFF49377E) : Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';

class ProfileStickyActions extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool loading;
  final VoidCallback? onSkip;

  const ProfileStickyActions({
    super.key,
    this.primaryLabel = 'Save & Continue',
    required this.onPrimary,
    this.loading = false,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GradientButton(
              label: primaryLabel,
              trailingIcon: Icons.arrow_forward,
              onPressed: onPrimary,
              loading: loading,
            ),
            if (onSkip != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFEEF0F4),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    foregroundColor: AppColors.textPrimary,
                  ),
                  onPressed: onSkip,
                  child: const Text('Skip for now',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

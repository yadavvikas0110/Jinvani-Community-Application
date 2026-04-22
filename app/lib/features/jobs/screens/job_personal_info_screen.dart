import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../state/seeker_setup_controller.dart';
import '../widgets/setup_step_indicator.dart';

class JobPersonalInfoScreen extends ConsumerStatefulWidget {
  const JobPersonalInfoScreen({super.key});
  @override
  ConsumerState<JobPersonalInfoScreen> createState() => _JobPersonalInfoScreenState();
}

class _JobPersonalInfoScreenState extends ConsumerState<JobPersonalInfoScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _location = TextEditingController();
  final _mobile = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _location.dispose();
    _mobile.dispose();
    super.dispose();
  }

  void _next() {
    if (!_form.currentState!.validate()) return;
    ref.read(seekerSetupProvider.notifier).setPersonalInfo(
          fullName: _name.text.trim(),
          email: _email.text.trim(),
          location: _location.text.trim(),
          mobile: _mobile.text.trim(),
        );
    context.push('/jobs/setup/professional');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            const SetupStepIndicator(currentStep: 1, totalSteps: 3),
            const SizedBox(height: 24),
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 24),
            _InputField(
              label: 'Full Name',
              controller: _name,
              hint: 'Your full name',
              prefixIcon: Icons.person_outline,
              validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your full name' : null,
            ),
            const SizedBox(height: 16),
            _InputField(
              label: 'Email',
              controller: _email,
              hint: 'priya@example.com',
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 16),
            _InputField(
              label: 'Location',
              controller: _location,
              hint: 'New Delhi',
              suffixIcon: Icons.keyboard_arrow_down,
            ),
            const SizedBox(height: 16),
            _InputField(
              label: 'Mobile Number',
              controller: _mobile,
              hint: '9873467265',
              keyboardType: TextInputType.phone,
              prefixWidget: Container(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🇮🇳', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    const Text('+91', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 20, color: AppColors.border),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: GradientButton(
            label: 'Next',
            trailingIcon: Icons.arrow_forward,
            onPressed: _next,
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixWidget;

  const _InputField({
    required this.label,
    required this.controller,
    required this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.prefixWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 16, color: AppColors.textMuted)
                : prefixWidget != null
                    ? prefixWidget
                    : null,
            prefixIconConstraints: prefixWidget != null
                ? const BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, size: 16, color: AppColors.textMuted)
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E5187)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

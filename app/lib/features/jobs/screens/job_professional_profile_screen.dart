import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../state/seeker_setup_controller.dart';
import '../widgets/setup_step_indicator.dart';

class JobProfessionalProfileScreen extends ConsumerStatefulWidget {
  const JobProfessionalProfileScreen({super.key});
  @override
  ConsumerState<JobProfessionalProfileScreen> createState() =>
      _JobProfessionalProfileScreenState();
}

class _JobProfessionalProfileScreenState
    extends ConsumerState<JobProfessionalProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _profile = TextEditingController();
  final _summary = TextEditingController();
  String _experience = 'Fresher';

  final _experienceOptions = ['Fresher', '0-1 Year', '1-2 Years', '2-4 Years', '4+ Years'];

  @override
  void dispose() {
    _profile.dispose();
    _summary.dispose();
    super.dispose();
  }

  void _next() {
    if (!_form.currentState!.validate()) return;
    ref.read(seekerSetupProvider.notifier).setProfessionalInfo(
          professionalProfile: _profile.text.trim(),
          professionalSummary: _summary.text.trim(),
          workExperience: _experience,
        );
    context.push('/jobs/setup/cv');
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
            const SetupStepIndicator(currentStep: 2, totalSteps: 3),
            const SizedBox(height: 24),
            const Text(
              'Professional profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 24),
            _label('Professional profile'),
            const SizedBox(height: 4),
            TextFormField(
              controller: _profile,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your professional profile' : null,
              decoration: _inputDecoration('e.g Backend developer, software developer'),
            ),
            const SizedBox(height: 16),
            _label('Professional summary'),
            const SizedBox(height: 4),
            TextFormField(
              controller: _summary,
              maxLines: 4,
              decoration: _inputDecoration("e.g I'm a backend developer..."),
            ),
            const SizedBox(height: 16),
            _label('Work experience'),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _experience,
              decoration: _inputDecoration('Select experience'),
              items: _experienceOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _experience = v ?? _experience),
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

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
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
      );
}

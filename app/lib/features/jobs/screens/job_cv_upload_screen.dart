import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../state/seeker_setup_controller.dart';
import '../widgets/setup_step_indicator.dart';

class JobCvUploadScreen extends ConsumerStatefulWidget {
  const JobCvUploadScreen({super.key});
  @override
  ConsumerState<JobCvUploadScreen> createState() => _JobCvUploadScreenState();
}

class _JobCvUploadScreenState extends ConsumerState<JobCvUploadScreen> {
  String? _cvFileName;
  final _portfolio = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _portfolio.dispose();
    super.dispose();
  }

  void _pickCv() {
    // Stub — wire up file_picker when backend is ready
    setState(() => _cvFileName = 'my_resume.pdf');
  }

  Future<void> _finish() async {
    setState(() => _loading = true);
    try {
      ref.read(seekerSetupProvider.notifier).setCv(
            cvUrl: _cvFileName,
            portfolio: _portfolio.text.trim().isEmpty ? null : _portfolio.text.trim(),
          );
      await ref.read(seekerSetupProvider.notifier).completeSetup();
      ref.invalidate(seekerSetupDoneProvider);
      if (mounted) context.go('/jobs');
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          const SetupStepIndicator(currentStep: 3, totalSteps: 3),
          const SizedBox(height: 24),
          const Text(
            'Upload your CV to get analyzed and receive job offers.',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 24),
          const Text('Upload CV', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickCv,
            child: Container(
              height: 75,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: _cvFileName != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.insert_drive_file_outlined,
                              size: 20, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Text(_cvFileName!,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.upload_outlined, size: 20, color: AppColors.textSecondary),
                          SizedBox(width: 8),
                          Text('Upload CV/Resume',
                              style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Portfolio (optional)',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          TextFormField(
            controller: _portfolio,
            decoration: InputDecoration(
              hintText: 'e.g https://myportfolio.com',
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: GradientButton(
            label: 'Next',
            trailingIcon: Icons.arrow_forward,
            loading: _loading,
            onPressed: _loading ? null : _finish,
          ),
        ),
      ),
    );
  }
}

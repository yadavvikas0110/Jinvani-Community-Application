import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../state/jobs_controller.dart';
import '../state/seeker_setup_controller.dart';

class JobApplyScreen extends ConsumerStatefulWidget {
  final String jobId;
  const JobApplyScreen({super.key, required this.jobId});

  @override
  ConsumerState<JobApplyScreen> createState() => _JobApplyScreenState();
}

class _JobApplyScreenState extends ConsumerState<JobApplyScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _email;
  late TextEditingController _location;
  late TextEditingController _mobile;
  String? _cvFileName;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(seekerSetupProvider);
    _name = TextEditingController(text: profile.fullName);
    _email = TextEditingController(text: profile.email);
    _location = TextEditingController(text: profile.location);
    _mobile = TextEditingController(text: profile.mobile);
    _cvFileName = profile.cvUrl;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _location.dispose();
    _mobile.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actionsPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
        content: const Text(
          'Are you sure you don\'t want to apply?',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm',
                style: TextStyle(
                    color: Color(0xFF2E5187), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  Future<void> _submit(String company) async {
    if (!_form.currentState!.validate()) return;
    setState(() => _submitting = true);
    final success =
        await ref.read(jobsControllerProvider.notifier).applyToJob(widget.jobId);
    setState(() => _submitting = false);
    if (!mounted) return;
    if (success) {
      context.pushReplacement('/jobs/${widget.jobId}/applied/success');
    } else {
      context.pushReplacement(
          '/jobs/${widget.jobId}/applied/failed?company=${Uri.encodeComponent(company)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobAsync = ref.watch(jobDetailProvider(widget.jobId));

    return jobAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (job) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final leave = await _onWillPop();
          if (leave && context.mounted) Navigator.of(context).pop();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.black12,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: AppColors.textPrimary, size: 22),
              onPressed: () async {
                final leave = await _onWillPop();
                if (leave && context.mounted) Navigator.of(context).pop();
              },
            ),
            title: Text(
              'Apply to ${job.company}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          body: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              children: [
                const Text(
                  'Contact details',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),
                _FieldLabel('Full Name'),
                const SizedBox(height: 4),
                _buildField(
                  controller: _name,
                  hint: 'Enter your full name',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                _FieldLabel('Email'),
                const SizedBox(height: 4),
                _buildField(
                  controller: _email,
                  hint: 'Enter your email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Enter valid email' : null,
                ),
                const SizedBox(height: 14),
                _FieldLabel('Location'),
                const SizedBox(height: 4),
                _buildField(
                  controller: _location,
                  hint: 'Enter your location',
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                _FieldLabel('Mobile Number'),
                const SizedBox(height: 4),
                TextFormField(
                  controller: _mobile,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                  decoration: InputDecoration(
                    hintText: 'Enter mobile number',
                    hintStyle: const TextStyle(
                        color: AppColors.textMuted, fontSize: 14),
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🇮🇳',
                              style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Container(
                              width: 1, height: 20, color: AppColors.border),
                          const SizedBox(width: 6),
                          const Text('+91',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    prefixIconConstraints:
                        const BoxConstraints(minWidth: 0, minHeight: 0),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF2E5187))),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                _FieldLabel('CV/Resume'),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () =>
                      setState(() => _cvFileName = 'my_resume.pdf'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _cvFileName != null
                        ? Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                    Icons.insert_drive_file_outlined,
                                    size: 20,
                                    color: Color(0xFFE53935)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _cvFileName!,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              const Icon(Icons.close,
                                  size: 18, color: AppColors.textMuted),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.upload_outlined,
                                  size: 20,
                                  color: AppColors.textSecondary),
                              SizedBox(width: 8),
                              Text('Upload CV/Resume',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary)),
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
                label: 'Submit & Apply',
                loading: _submitting,
                onPressed: _submitting ? null : () => _submit(job.company),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.textMuted, fontSize: 14),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E5187))),
          filled: true,
          fillColor: Colors.white,
        ),
      );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary),
      );
}

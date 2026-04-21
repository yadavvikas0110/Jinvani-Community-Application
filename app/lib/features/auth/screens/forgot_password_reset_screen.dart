import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/signup_header.dart';
import '../data/auth_repository.dart';
import '../state/forgot_password_controller.dart';

const _forgotSteps = ['Enter Details', 'Verify OTP', 'Reset Password'];

class ForgotPasswordResetScreen extends ConsumerStatefulWidget {
  const ForgotPasswordResetScreen({super.key});
  @override
  ConsumerState<ForgotPasswordResetScreen> createState() =>
      _ForgotPasswordResetScreenState();
}

class _ForgotPasswordResetScreenState extends ConsumerState<ForgotPasswordResetScreen> {
  final _form = GlobalKey<FormState>();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_pw.text != _pw2.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    final token = ref.read(forgotPasswordDraftProvider).resetToken;
    if (token == null) {
      setState(() => _error = 'Session expired. Please verify OTP again.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .resetPassword(resetToken: token, newPassword: _pw.text);
      ref.read(forgotPasswordDraftProvider.notifier).reset();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset. Please login.')),
      );
      context.go('/login');
    } on Exception {
      setState(() => _error = 'Could not reset password');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SignupHeader(
              title: 'Reset Password',
              subtitle: '',
              currentStep: 3,
              steps: _forgotSteps,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Form(
                key: _form,
                onChanged: () => setState(() {}),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Enter New Password',
                        style: TextStyle(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _pw,
                      obscureText: _obscure1,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline,
                            size: 18, color: AppColors.textMuted),
                        hintText: 'Min 6 character',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textMuted, size: 18),
                          onPressed: () => setState(() => _obscure1 = !_obscure1),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.length < 8) ? 'At least 8 characters' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Confirm New Password',
                        style: TextStyle(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _pw2,
                      obscureText: _obscure2,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline,
                            size: 18, color: AppColors.textMuted),
                        hintText: 'Re-enter password',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textMuted, size: 18),
                          onPressed: () => setState(() => _obscure2 = !_obscure2),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                      ),
                    const SizedBox(height: 28),
                    GradientButton(
                      label: 'Reset Password',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Remember your password? ',
                              style: TextStyle(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text('Login',
                                style: TextStyle(
                                    color: AppColors.accent, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/signup_header.dart';
import '../data/auth_repository.dart';
import '../state/forgot_password_controller.dart';

const _forgotSteps = ['Enter Details', 'Verify OTP', 'Reset Password'];

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _identifier.text = ref.read(forgotPasswordDraftProvider).identifier;
  }

  @override
  void dispose() {
    _identifier.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final raw = _identifier.text.trim();
    final phone = raw.contains('@')
        ? raw
        : raw.startsWith('+') ? raw : '+91$raw';
    try {
      await ref.read(authRepositoryProvider).forgotPassword(phone);
      ref.read(forgotPasswordDraftProvider.notifier).setIdentifier(
            identifier: raw,
            phone: phone,
          );
      if (mounted) context.push('/forgot-password/otp');
    } on Exception {
      setState(() => _error = 'No account found or could not send OTP');
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
            SignupHeader(
              title: 'Forgot Password',
              subtitle: 'Enter your registered mobile or email',
              currentStep: 1,
              steps: _forgotSteps,
              onBack: () => context.canPop() ? context.pop() : context.go('/login'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Mobile Number / Email',
                        style: TextStyle(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _identifier,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline, size: 18, color: AppColors.textMuted),
                        hintText: 'priya@example.com',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final s = v.trim();
                        if (s.contains('@')) {
                          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
                            return 'Invalid email';
                          }
                        } else {
                          final cleaned = s.replaceAll(RegExp(r'\D'), '');
                          if (cleaned.length < 10) return 'Invalid mobile';
                        }
                        return null;
                      },
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                      ),
                    const SizedBox(height: 28),
                    GradientButton(label: 'Send OTP', loading: _loading, onPressed: _submit),
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
                                style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
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

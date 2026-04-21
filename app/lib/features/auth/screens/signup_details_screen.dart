import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/signup_header.dart';
import '../data/auth_repository.dart';
import '../state/signup_controller.dart';

class SignupDetailsScreen extends ConsumerStatefulWidget {
  const SignupDetailsScreen({super.key});
  @override
  ConsumerState<SignupDetailsScreen> createState() => _SignupDetailsScreenState();
}

class _SignupDetailsScreenState extends ConsumerState<SignupDetailsScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(signupDraftProvider);
    _name.text = draft.name;
    _email.text = draft.email;
    _phone.text = draft.phone;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final phone = _phone.text.trim().startsWith('+')
          ? _phone.text.trim()
          : '+91${_phone.text.trim()}';
      await ref.read(authRepositoryProvider).signupStart(
            name: _name.text.trim(),
            phone: phone,
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
          );
      ref.read(signupDraftProvider.notifier).setDetails(
            name: _name.text.trim(),
            email: _email.text.trim(),
            phone: phone,
          );
      if (mounted) context.push('/signup/otp');
    } on Exception {
      setState(() => _error = 'Could not send OTP. Try again.');
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
              title: 'Enter Details',
              subtitle: 'Please fill in the details below',
              currentStep: 1,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Label('Full Name'),
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline, size: 18, color: AppColors.textMuted),
                        hintText: 'Your full name',
                      ),
                      validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    const _Label('Email'),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.mail_outline, size: 18, color: AppColors.textMuted),
                        hintText: 'priya@example.com',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const _Label('Mobile Number'),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.phone_outlined, size: 18, color: AppColors.textMuted),
                        hintText: '+91 9873467265',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final cleaned = v.replaceAll(RegExp(r'\D'), '');
                        if (cleaned.length < 10) return 'Invalid phone';
                        return null;
                      },
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                      ),
                    const SizedBox(height: 28),
                    GradientButton(
                      label: 'Continue',
                      trailingIcon: Icons.arrow_forward,
                      loading: _loading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already have an account? ',
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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(color: AppColors.textPrimary)),
      );
}

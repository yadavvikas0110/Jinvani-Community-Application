import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/signup_header.dart';
import '../data/auth_repository.dart';
import '../state/signup_controller.dart';

class SignupPasswordScreen extends ConsumerStatefulWidget {
  const SignupPasswordScreen({super.key});
  @override
  ConsumerState<SignupPasswordScreen> createState() => _SignupPasswordScreenState();
}

class _SignupPasswordScreenState extends ConsumerState<SignupPasswordScreen> {
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

  bool get _hasMin => _pw.text.length >= 8;
  bool get _hasNum => RegExp(r'\d').hasMatch(_pw.text);
  bool get _hasSym => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_pw.text);

  double get _strength {
    int v = 0;
    if (_hasMin) v++;
    if (_hasNum) v++;
    if (_hasSym) v++;
    return v / 3;
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_pw.text != _pw2.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final draft = ref.read(signupDraftProvider);
    if (draft.signupToken == null) {
      setState(() {
        _loading = false;
        _error = 'Session expired. Please verify OTP again.';
      });
      return;
    }
    try {
      await ref.read(authRepositoryProvider).signupComplete(
            signupToken: draft.signupToken!,
            password: _pw.text,
          );
      if (mounted) context.push('/signup/roles');
    } on Exception {
      setState(() => _error = 'Could not complete sign up');
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
              title: 'Create Password',
              subtitle: '',
              currentStep: 3,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Form(
                key: _form,
                onChanged: () => setState(() {}),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Set Password', style: TextStyle(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _pw,
                      obscureText: _obscure1,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
                        hintText: 'Min 8 character',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textMuted, size: 18),
                          onPressed: () => setState(() => _obscure1 = !_obscure1),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 8) ? 'At least 8 characters' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Confirm Password', style: TextStyle(color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _pw2,
                      obscureText: _obscure2,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
                        hintText: 'Min 8 character',
                        suffixIcon: IconButton(
                          icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textMuted, size: 18),
                          onPressed: () => setState(() => _obscure2 = !_obscure2),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    if (_pw.text.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: _strength,
                          backgroundColor: const Color(0xFFEDEDED),
                          valueColor: AlwaysStoppedAnimation(
                            _strength < 0.5
                                ? AppColors.warning
                                : _strength < 1
                                    ? AppColors.warning
                                    : AppColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Rule(label: '8 characters minimum', ok: _hasMin),
                      _Rule(label: 'a number', ok: _hasNum),
                      _Rule(label: 'a symbol', ok: _hasSym),
                    ],
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                      ),
                    const SizedBox(height: 24),
                    GradientButton(label: 'Continue', loading: _loading, onPressed: _submit),
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

class _Rule extends StatelessWidget {
  final String label;
  final bool ok;
  const _Rule({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16, color: ok ? AppColors.success : AppColors.textMuted),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: ok ? AppColors.textPrimary : AppColors.textSecondary)),
        ],
      ),
    );
  }
}

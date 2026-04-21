import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/signup_header.dart';
import '../data/auth_repository.dart';
import '../state/signup_controller.dart';

class SignupOtpScreen extends ConsumerStatefulWidget {
  const SignupOtpScreen({super.key});
  @override
  ConsumerState<SignupOtpScreen> createState() => _SignupOtpScreenState();
}

class _SignupOtpScreenState extends ConsumerState<SignupOtpScreen> {
  final List<TextEditingController> _cells = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;
  int _resendIn = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _resendIn = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_resendIn <= 0) {
        t.cancel();
      } else {
        setState(() => _resendIn -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _cells) {
      c.dispose();
    }
    for (final f in _nodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _cells.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length < 6) {
      setState(() => _error = 'Enter all 6 digits');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final draft = ref.read(signupDraftProvider);
      final token = await ref
          .read(authRepositoryProvider)
          .signupVerifyOtp(phone: draft.phone, code: _code);
      ref.read(signupDraftProvider.notifier).setSignupToken(token);
      if (mounted) context.push('/signup/password');
    } on Exception {
      setState(() => _error = 'Invalid or expired OTP');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    final draft = ref.read(signupDraftProvider);
    await ref.read(authRepositoryProvider).signupStart(
          name: draft.name,
          phone: draft.phone,
          email: draft.email.isEmpty ? null : draft.email,
        );
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(signupDraftProvider);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SignupHeader(
              title: 'Enter OTP',
              subtitle: 'We have sent an 6 digit OTP to your registered\nmobile number and email address.',
              currentStep: 2,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.phone.isEmpty ? 'Mobile Number / Email' : draft.phone,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) => _cell(i)),
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(_error!, style: const TextStyle(color: AppColors.danger)),
                    ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Verify OTP',
                    loading: _loading,
                    onPressed: _verify,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Didn't received the code  ",
                            style: TextStyle(color: AppColors.textSecondary)),
                        GestureDetector(
                          onTap: _resendIn > 0 ? null : _resend,
                          child: Text(
                            _resendIn > 0 ? 'Resend ($_resendIn)' : 'Resend',
                            style: TextStyle(
                              color: _resendIn > 0 ? AppColors.textMuted : AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(int i) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: _cells[i],
        focusNode: _nodes[i],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        decoration: const InputDecoration(counterText: ''),
        onChanged: (v) {
          if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
          if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
          setState(() {});
        },
      ),
    );
  }
}

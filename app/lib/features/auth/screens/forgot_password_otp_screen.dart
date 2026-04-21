import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/signup_header.dart';
import '../data/auth_repository.dart';
import '../state/forgot_password_controller.dart';

const _forgotSteps = ['Enter Details', 'Verify OTP', 'Reset Password'];

class ForgotPasswordOtpScreen extends ConsumerStatefulWidget {
  const ForgotPasswordOtpScreen({super.key});
  @override
  ConsumerState<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends ConsumerState<ForgotPasswordOtpScreen> {
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
      final draft = ref.read(forgotPasswordDraftProvider);
      final token = await ref
          .read(authRepositoryProvider)
          .forgotVerifyOtp(phone: draft.phone, code: _code);
      ref.read(forgotPasswordDraftProvider.notifier).setResetToken(token);
      if (mounted) context.push('/forgot-password/reset');
    } on Exception {
      setState(() => _error = 'Invalid or expired OTP');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    final draft = ref.read(forgotPasswordDraftProvider);
    await ref.read(authRepositoryProvider).forgotResendOtp(draft.phone);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(forgotPasswordDraftProvider);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SignupHeader(
              title: 'Enter OTP',
              subtitle:
                  'We sent a reset code to ${draft.identifier}\nenter the 6 digit code.',
              currentStep: 2,
              steps: _forgotSteps,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    draft.identifier.isEmpty ? 'Mobile Number / Email' : draft.identifier,
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

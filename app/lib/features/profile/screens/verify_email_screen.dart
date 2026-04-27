import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/state/auth_controller.dart';
import '../widgets/labeled_field.dart';
import '../widgets/profile_app_bar.dart';
import '../widgets/section_card.dart';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();
  bool _otpSent = false;
  bool _loading = false;
  int _timerSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final currentEmail = ref.read(authControllerProvider).user?.email;
    if (currentEmail != null) _email.text = currentEmail;
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  Future<void> _sendOtp() async {
    if (_email.text.trim().isEmpty || !_email.text.contains('@')) {
      _showError('Please enter a valid email address');
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).verifyEmailStart(_email.text.trim());
      setState(() {
        _otpSent = true;
        _loading = false;
      });
      _startTimer();
      _showSuccess('Verification code sent to your email');
    } catch (e) {
      setState(() => _loading = false);
      _showError('Failed to send code. Please try again.');
    }
  }

  Future<void> _verifyOtp() async {
    if (_code.text.length != 6) {
      _showError('Please enter the 6-digit code');
      return;
    }

    setState(() => _loading = true);
    try {
      final updatedUser = await ref.read(authRepositoryProvider).verifyEmailComplete(
        _email.text.trim(),
        _code.text.trim(),
      );
      ref.read(authControllerProvider.notifier).setUser(updatedUser);
      setState(() => _loading = false);
      _showSuccess('Email verified successfully!');
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _loading = false);
      _showError('Invalid or expired code. Please try again.');
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.danger),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: const ProfileAppBar(title: 'Email Verification'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: 'Secure Verification',
              subtitle: 'Verify your email to enhance account security.',
            ),
            const SizedBox(height: 16),
            SectionCard(
              child: Column(
                children: [
                  LabeledField(
                    label: 'Email Address',
                    child: TextFormField(
                      controller: _email,
                      enabled: !_otpSent,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'name@example.com',
                        prefixIcon: Icon(Icons.mail_outline, size: 20),
                      ),
                    ),
                  ),
                  if (_otpSent) ...[
                    const SizedBox(height: 20),
                    LabeledField(
                      label: 'Verification Code',
                      child: TextFormField(
                        controller: _code,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(
                          hintText: 'Enter 6-digit code',
                          prefixIcon: Icon(Icons.lock_outline, size: 20),
                          counterText: '',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: _otpSent ? 'Verify Code' : 'Send Verification Code',
              loading: _loading,
              onPressed: _otpSent ? _verifyOtp : _sendOtp,
            ),
            if (_otpSent) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _timerSeconds == 0 ? _sendOtp : null,
                  child: Text(
                    _timerSeconds > 0
                        ? 'Resend in ${_timerSeconds}s'
                        : 'Resend Verification Code',
                    style: TextStyle(
                      color: _timerSeconds > 0 ? AppColors.textMuted : AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _loading ? null : () => setState(() => _otpSent = false),
                  child: const Text('Change Email'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const SectionHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }
}

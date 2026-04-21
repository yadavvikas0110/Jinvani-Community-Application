import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../data/auth_repository.dart';
import '../state/auth_controller.dart';
import '../state/signup_controller.dart';

class SignupRolesScreen extends ConsumerStatefulWidget {
  const SignupRolesScreen({super.key});
  @override
  ConsumerState<SignupRolesScreen> createState() => _SignupRolesScreenState();
}

class _SignupRolesScreenState extends ConsumerState<SignupRolesScreen> {
  final _roles = const [
    'Jain Businessman',
    'Jain Professional',
    'Jain Social Workers',
    'Jain Youth Groups',
    "Jain Women's Organizations",
    'Jain Scholars & Speakers',
    'Jain Philanthropists',
  ];

  final _selected = <String>{};
  bool _loading = false;

  Future<void> _submit() async {
    if (_selected.isEmpty) return;
    setState(() => _loading = true);
    try {
      final user = await ref.read(authRepositoryProvider).updateRoles(_selected.toList());
      ref.read(authControllerProvider.notifier).setUser(user);
      ref.read(signupDraftProvider.notifier).reset();
      if (mounted) context.go('/home');
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              decoration: const BoxDecoration(gradient: AppColors.headerGradient),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 44,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                      ),
                    ),
                    const Text('Choose your roles',
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    const Text(
                      'Select one or more roles that describe you. This helps\nus personalize your experience.',
                      style: TextStyle(color: Color(0xFFC6C6C7), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                children: [
                  ..._roles.map(_roleTile),
                  const SizedBox(height: 20),
                  GradientButton(
                    label: 'Continue',
                    loading: _loading,
                    onPressed: _selected.isEmpty ? null : _submit,
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
          ],
        ),
      ),
    );
  }

  Widget _roleTile(String role) {
    final sel = _selected.contains(role);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() {
          if (sel) {
            _selected.remove(role);
          } else {
            _selected.add(role);
          }
        }),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: sel ? const Color(0xFFEDEAFB) : Colors.white,
            border: Border.all(color: sel ? AppColors.headerStart : AppColors.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: sel ? AppColors.headerStart : const Color(0xFFE9ECF1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 20, color: sel ? Colors.white : AppColors.textMuted),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const Text('Business owners and entrepreneurs',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(color: sel ? AppColors.headerStart : AppColors.border, width: 2),
                  shape: BoxShape.circle,
                  color: sel ? AppColors.headerStart : Colors.transparent,
                ),
                child: sel ? const Icon(Icons.circle, size: 8, color: Colors.white) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

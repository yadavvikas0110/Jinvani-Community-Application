import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../state/seeker_setup_controller.dart';

class JobRoleSelectionScreen extends ConsumerStatefulWidget {
  const JobRoleSelectionScreen({super.key});
  @override
  ConsumerState<JobRoleSelectionScreen> createState() => _JobRoleSelectionScreenState();
}

class _JobRoleSelectionScreenState extends ConsumerState<JobRoleSelectionScreen> {
  String? _selectedRole;

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
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Who are you?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 24),
            _RoleCard(
              icon: Icons.person_outline,
              label: "I'm a Recruiter",
              selected: _selectedRole == 'recruiter',
              onTap: () => setState(() => _selectedRole = 'recruiter'),
            ),
            const SizedBox(height: 16),
            _RoleCard(
              icon: Icons.search,
              label: "I'm a Job Seeker",
              selected: _selectedRole == 'seeker',
              onTap: () => setState(() => _selectedRole = 'seeker'),
            ),
            const Spacer(),
            GradientButton(
              label: 'Continue',
              onPressed: _selectedRole == null
                  ? null
                  : () {
                      ref.read(seekerSetupProvider.notifier).setRole(_selectedRole!);
                      context.push('/jobs/setup/personal');
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: selected ? const Color(0xFF2E5187) : const Color(0xFFAAB2BC),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(17),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFEAEFF7) : const Color(0xFFF0F1F3),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: selected ? const Color(0xFF2E5187) : AppColors.textMuted),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

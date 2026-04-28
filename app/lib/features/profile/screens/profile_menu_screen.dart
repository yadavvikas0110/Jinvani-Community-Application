import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/state/auth_controller.dart';
import '../state/profile_controller.dart';
import '../widgets/profile_app_bar.dart';

class ProfileMenuScreen extends ConsumerWidget {
  const ProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileControllerProvider);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: const ProfileAppBar(title: 'Profile'),
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileControllerProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _CompletionCard(completion: profile?.completion ?? 0),
            const SizedBox(height: 20),
            const Text('Complete Your Profile',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text(
              'Add details below to unlock community features.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _MenuItem(
              index: 1,
              icon: Icons.person_outline,
              title: 'Personal Details',
              required: true,
              filled: _hasPersonal(profile),
              onTap: () => context.push('/profile/personal'),
            ),
            _MenuItem(
              index: 2,
              icon: Icons.school_outlined,
              title: 'Educational Details',
              filled: (profile?.education ?? []).isNotEmpty,
              onTap: () => context.push('/profile/education'),
            ),
            _MenuItem(
              index: 3,
              icon: Icons.work_outline,
              title: 'Work Details',
              filled: _hasWork(profile),
              onTap: () => context.push('/profile/work'),
            ),
            _MenuItem(
              index: 4,
              icon: Icons.account_balance_wallet_outlined,
              title: 'Economic Data',
              filled: _hasEconomic(profile),
              onTap: () => context.push('/profile/economic'),
            ),
            _MenuItem(
              index: 5,
              icon: Icons.image_outlined,
              title: 'Picture & Bio',
              required: true,
              filled: _hasBio(profile),
              onTap: () => context.push('/profile/bio'),
            ),
            _MenuItem(
              index: 6,
              icon: Icons.flag_outlined,
              title: 'Goal Selection',
              filled: (profile?.goals ?? []).isNotEmpty,
              onTap: () => context.push('/profile/goals'),
            ),
            _MenuItem(
              index: 7,
              icon: Icons.account_tree_outlined,
              title: 'Family Tree',
              filled: false,
              onTap: () => context.push('/family'),
            ),
            _MenuItem(
              index: 8,
              icon: Icons.verified_user_outlined,
              title: 'Verify Email',
              filled: ref.watch(authControllerProvider).user?.isEmailVerified ?? false,
              onTap: () => context.push('/profile/verify-email'),
            ),
            _MenuItem(
              index: 9,
              icon: Icons.support_agent_outlined,
              title: 'Support & Feedback',
              filled: false,
              onTap: () => context.push('/support'),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Log Out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                        child: const Text('Log Out'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) context.go('/auth');
                }
              },
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text('Log Out', style: TextStyle(color: AppColors.danger, fontSize: 16)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasPersonal(dynamic p) {
    if (p == null) return false;
    final pd = p.personalDetails;
    return pd.fullName != null || pd.age != null || pd.gender != null;
  }

  bool _hasWork(dynamic p) {
    if (p == null) return false;
    final w = p.workDetails;
    return w.jobType != null || w.companyName != null || w.jobRole != null;
  }

  bool _hasEconomic(dynamic p) {
    if (p == null) return false;
    final e = p.economicData;
    return e.financialInfo.sourceOfIncome != null || e.futureGoals.goal != null ||
        e.investmentPortfolio.type != null;
  }

  bool _hasBio(dynamic p) {
    if (p == null) return false;
    return p.bio.avatarUrl != null || p.bio.briefIntroduction != null;
  }
}

class _CompletionCard extends StatelessWidget {
  final int completion;
  const _CompletionCard({required this.completion});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile Completion',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 6),
          Text('$completion%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completion / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String title;
  final bool required;
  final bool filled;
  final VoidCallback onTap;

  const _MenuItem({
    required this.index,
    required this.icon,
    required this.title,
    this.required = false,
    this.filled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAECF0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEFF4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$index',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                ),
                const SizedBox(width: 12),
                Icon(icon, size: 20, color: AppColors.textPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(
                        required ? 'Required' : (filled ? 'Completed' : 'Optional'),
                        style: TextStyle(
                          color: required
                              ? AppColors.danger
                              : filled
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

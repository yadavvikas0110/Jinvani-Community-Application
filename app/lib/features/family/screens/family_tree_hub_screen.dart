import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../auth/state/auth_controller.dart';
import '../../profile/widgets/profile_app_bar.dart';
import '../models/family.dart';
import '../state/family_controller.dart';
import '../widgets/family_tree_canvas.dart';

class FamilyTreeHubScreen extends ConsumerWidget {
  const FamilyTreeHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(familyControllerProvider);
    final user = ref.watch(authControllerProvider).user;
    final snap = state.data;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: const ProfileAppBar(title: 'Family Tree'),
      body: state.loading && snap == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(familyControllerProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (snap?.members ?? []).isEmpty
                              ? 'Add family members'
                              : 'Your family',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (snap?.members ?? []).isEmpty
                              ? 'Add family members to your family tree.'
                              : 'Tap a member to see details or remove them.',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  FamilyTreeCanvas(
                    selfName: user?.name ?? 'You',
                    members: snap?.members ?? const [],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: 180,
                      child: GradientButton(
                        label: 'Add Members',
                        trailingIcon: Icons.add,
                        onPressed: () => context.push('/family/add'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if ((snap?.pendingOutgoing ?? []).isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Pending Invitations',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 10),
                    ...(snap?.pendingOutgoing ?? []).map(
                      (inv) => _PendingInviteCard(inv: inv),
                    ),
                  ],
                  if ((snap?.pendingIncoming ?? []).isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Requests to you',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 10),
                    ...(snap?.pendingIncoming ?? []).map(
                      (inv) => _IncomingInviteTeaser(inv: inv),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _PendingInviteCard extends ConsumerWidget {
  final FamilyInvitation inv;
  const _PendingInviteCard({required this.inv});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEAECF0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    inv.proposedName
                        .trim()
                        .split(RegExp(r'\s+'))
                        .where((p) => p.isNotEmpty)
                        .take(2)
                        .map((p) => p[0].toUpperCase())
                        .join(),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inv.proposedName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(relationLabel(inv.relation),
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Pending',
                      style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 12)),
                ),
              ],
            ),
            if (inv.phone != null || inv.email != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFEAECF0)),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (inv.phone != null)
                    Expanded(
                      child: Text(inv.phone!,
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                    ),
                  if (inv.email != null)
                    Expanded(
                      child: Text(inv.email!,
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () async {
                  await ref.read(familyControllerProvider.notifier).cancel(inv.id);
                },
                child: const Text('Cancel', style: TextStyle(color: AppColors.danger)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomingInviteTeaser extends StatelessWidget {
  final FamilyInvitation inv;
  const _IncomingInviteTeaser({required this.inv});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/family/requests/${inv.id}'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAECF0)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: inv.sender?.avatarUrl != null
                      ? NetworkImage(inv.sender!.avatarUrl!)
                      : null,
                  backgroundColor: const Color(0xFFEEF0F4),
                  child: inv.sender?.avatarUrl == null
                      ? const Icon(Icons.person, color: AppColors.textMuted)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inv.sender?.name ?? 'A family member',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Wants to add you as ${relationLabel(inv.relation).toLowerCase()}',
                          style: const TextStyle(
                              color: AppColors.accent, fontSize: 12),
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

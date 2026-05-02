import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/widgets/profile_app_bar.dart';
import '../models/family.dart';
import '../state/family_controller.dart';

class FamilyRequestsScreen extends ConsumerWidget {
  const FamilyRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(familyControllerProvider);
    final incoming = state.data?.pendingIncoming ?? const [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: const ProfileAppBar(title: 'Family Requests'),
      body: state.loading && state.data == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(familyControllerProvider.notifier).refresh(),
              child: incoming.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: incoming.length,
                      itemBuilder: (_, i) => _RequestCard(inv: incoming[i]),
                    ),
            ),
      bottomNavigationBar: incoming.isEmpty
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEF0F4),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      foregroundColor: AppColors.textPrimary,
                    ),
                    onPressed: () => context.pop(),
                    child: const Text('Back',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  ),
                ),
              ),
            ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final FamilyInvitation inv;
  const _RequestCard({required this.inv});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFEEF0F4),
                      backgroundImage: inv.sender?.avatarUrl != null
                          ? NetworkImage(inv.sender!.avatarUrl!)
                          : null,
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
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary)),
                          if (inv.sender?.city != null)
                            Text(inv.sender!.city!,
                                style: const TextStyle(
                                    color: AppColors.textSecondary, fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link, size: 14, color: AppColors.accent),
                      const SizedBox(width: 6),
                        Text(
                          'Wants to add you as ${relationLabel(inv.relation).toLowerCase()}',
                          style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryButtonGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('View Request',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Icon(Icons.inbox_outlined, size: 72, color: AppColors.textMuted),
        SizedBox(height: 16),
        Center(
          child: Text('No pending requests',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    );
  }
}

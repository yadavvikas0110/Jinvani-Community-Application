import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../profile/widgets/profile_app_bar.dart';
import '../models/family.dart';
import '../state/family_controller.dart';

class FamilyRequestDetailScreen extends ConsumerStatefulWidget {
  final String invitationId;
  const FamilyRequestDetailScreen({super.key, required this.invitationId});

  @override
  ConsumerState<FamilyRequestDetailScreen> createState() =>
      _FamilyRequestDetailScreenState();
}

class _FamilyRequestDetailScreenState
    extends ConsumerState<FamilyRequestDetailScreen> {
  bool _busy = false;

  FamilyInvitation? _find() {
    final incoming = ref.read(familyControllerProvider).data?.pendingIncoming ?? const [];
    for (final i in incoming) {
      if (i.id == widget.invitationId) return i;
    }
    return null;
  }

  Future<void> _accept() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(familyControllerProvider.notifier)
          .accept(widget.invitationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Welcome to the family!')),
        );
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not accept request')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reject() async {
    setState(() => _busy = true);
    try {
      await ref
          .read(familyControllerProvider.notifier)
          .reject(widget.invitationId);
      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not reject request')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inv = _find();
    if (inv == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: const ProfileAppBar(title: 'Family Requests'),
        body: const Center(
          child: Text('Request not found',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }
    final sender = inv.sender;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: const ProfileAppBar(title: 'Family Requests'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryButtonGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  backgroundImage: sender?.avatarUrl != null
                      ? NetworkImage(sender!.avatarUrl!)
                      : null,
                  child: sender?.avatarUrl == null
                      ? const Icon(Icons.person,
                          size: 42, color: AppColors.textMuted)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(sender?.name ?? 'A family member',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18)),
                if (sender?.city != null) ...[
                  const SizedBox(height: 2),
                  Text(sender!.city!,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAECF0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_add_alt_1,
                      color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Family Request',
                          style: TextStyle(
                              color: AppColors.accent, fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        '${sender?.name ?? 'They'} want to add you as ${relationLabel(inv.relation)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.link, size: 14, color: AppColors.accent),
                  const SizedBox(width: 6),
                  Text('Relation: ${relationLabel(inv.relation)}',
                      style: const TextStyle(
                          color: AppColors.accent, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.verified_user_outlined,
                  size: 18, color: AppColors.success),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your documents are encrypted and stored securely. We never share your data.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Reject',
                  icon: Icons.cancel_outlined,
                  color: AppColors.danger,
                  onPressed: _busy ? null : _reject,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Accept',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                  onPressed: _busy ? null : _accept,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }
}

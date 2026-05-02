import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../state/directory_controller.dart';

class DirectoryMemberProfileScreen extends ConsumerWidget {
  final String memberId;
  const DirectoryMemberProfileScreen({super.key, required this.memberId});

  static const _gradStart = Color(0xFF1C427D);
  static const _gradMid   = Color(0xFF1B449C);
  static const _gradEnd   = AppColors.accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(directoryMemberProvider(memberId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F6),
      body: memberAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (member) {
          if (member == null) {
            return const Center(child: Text('Member not found'));
          }
          return CustomScrollView(
            slivers: [
              // ── Purple gradient header ───────────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: _gradStart,
                surfaceTintColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_gradStart, _gradMid, _gradEnd],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Avatar
                          _GradientAvatar(name: member.name, size: 80),
                          const SizedBox(height: 12),
                          // Name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                member.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (member.isVerified) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified,
                                          size: 11, color: Colors.white),
                                      SizedBox(width: 3),
                                      Text(
                                        'Verified',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.title,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          if (member.company != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              member.company!,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    // ── Call / Message buttons ─────────────────────────────
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.call_outlined,
                                  size: 16, color: AppColors.accent),
                              label: const Text('Call',
                                  style: TextStyle(
                                      color: AppColors.accent,
                                      fontWeight: FontWeight.w600)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: AppColors.accent),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.chat_bubble_outline,
                                  size: 16),
                              label: const Text('Message',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── About ──────────────────────────────────────────────
                    if (member.about != null)
                      _InfoSection(
                        title: 'About',
                        child: Text(
                          member.about!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4C4A53),
                            height: 1.6,
                          ),
                        ),
                      ),

                    // ── Work Details ───────────────────────────────────────
                    _InfoSection(
                      title: 'Work Details',
                      child: Column(
                        children: [
                          _DetailRow(
                            icon: Icons.work_outline,
                            label: 'Title',
                            value: member.title,
                          ),
                          if (member.company != null)
                            _DetailRow(
                              icon: Icons.business_outlined,
                              label: 'Company',
                              value: member.company!,
                            ),
                          _DetailRow(
                            icon: Icons.location_on_outlined,
                            label: 'Location',
                            value: member.city,
                          ),
                          if (member.tags.isNotEmpty)
                            _DetailRow(
                              icon: Icons.label_outline,
                              label: 'Finance & Options',
                              value: member.tags.join(', '),
                            ),
                        ],
                      ),
                    ),

                    // ── Contact Information ────────────────────────────────
                    _InfoSection(
                      title: 'Contact Information',
                      child: Column(
                        children: [
                          if (member.phone != null)
                            _DetailRow(
                              icon: Icons.phone_outlined,
                              label: 'Phone',
                              value: member.phone!,
                            ),
                          if (member.email != null)
                            _DetailRow(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: member.email!,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Info section card ─────────────────────────────────────────────────────────

class _InfoSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _InfoSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF121A2C),
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      );
}

// ── Detail row ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ── Gradient avatar ───────────────────────────────────────────────────────────

class _GradientAvatar extends StatelessWidget {
  final String name;
  final double size;
  const _GradientAvatar({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((s) => s[0]).join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.25),
        border: Border.all(color: Colors.white, width: 3),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.32,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

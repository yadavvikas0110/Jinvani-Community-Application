import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../models/directory_member.dart';
import '../state/directory_controller.dart';

class DirectoryScreen extends ConsumerWidget {
  const DirectoryScreen({super.key});

  static const _gradStart = Color(0xFF1C427D);
  static const _gradMid   = Color(0xFF1B449C);
  static const _gradEnd   = Color(0xFF6361E2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts   = ref.watch(directoryCategoryCountsProvider);
    final featured = ref.watch(directoryFeaturedProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        automaticallyImplyLeading: false,
        title: const Text(
          'Directory',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121A2C),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // ── Comprehensive Directory banner ──────────────────────────────
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [_gradStart, _gradMid, _gradEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comprehensive Directory',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_totalCount(counts)} community members',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.people_alt_outlined,
                      color: Colors.white, size: 30),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Categories ──────────────────────────────────────────────────
          const Text(
            'Browse by Category',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121A2C),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.4,
            children: directoryCategories.map((cat) {
              return _CategoryTile(
                category: cat,
                count: counts[cat.id] ?? 0,
                onTap: () => context.push('/directory/${cat.id}'),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // ── Featured Members ─────────────────────────────────────────────
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Featured Members',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121A2C),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/directory/professionals'),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF395A91),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...featured.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _FeaturedMemberCard(
                  member: m,
                  onTap: () => context.push('/directory/members/${m.id}'),
                ),
              )),
        ],
      ),
    );
  }

  int _totalCount(Map<String, int> counts) =>
      counts.values.fold(0, (a, b) => a + b);
}

// ── Category tile ─────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final DirectoryCategory category;
  final int count;
  final VoidCallback onTap;
  const _CategoryTile({required this.category, required this.count, required this.onTap});

  static const _iconMap = {
    'work':                Icons.work_outline,
    'store':               Icons.store_outlined,
    'account_balance':     Icons.account_balance_outlined,
    'volunteer_activism':  Icons.volunteer_activism_outlined,
  };

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE9E4FF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _iconMap[category.icon] ?? Icons.people_outline,
                  size: 18,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF121A2C),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '$count members',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
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

// ── Featured member card ──────────────────────────────────────────────────────

class _FeaturedMemberCard extends StatelessWidget {
  final DirectoryMember member;
  final VoidCallback onTap;
  const _FeaturedMemberCard({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEEEEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Avatar(name: member.name, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            member.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF121A2C),
                            ),
                          ),
                        ),
                        if (member.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF059669),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.title,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    if (member.company != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        member.company!,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 11, color: AppColors.textMuted),
                        const SizedBox(width: 2),
                        Text(
                          member.city,
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      );
}

// ── Avatar widget (shared) ────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final double size;
  const _Avatar({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().split(' ').take(2).map((s) => s[0]).join();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.33,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../models/directory_member.dart';
import '../state/directory_controller.dart';


class DirectoryListScreen extends ConsumerStatefulWidget {
  final String category;
  const DirectoryListScreen({super.key, required this.category});

  @override
  ConsumerState<DirectoryListScreen> createState() => _DirectoryListScreenState();
}

class _DirectoryListScreenState extends ConsumerState<DirectoryListScreen> {
  late final TextEditingController _searchCtrl;
  String _search = '';
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  DirectoryParams get _params => (
        category: widget.category,
        search: _search,
        tags: _tags,
      );

  String get _title {
    switch (widget.category) {
      case 'professionals':      return 'All Professionals';
      case 'business_owners':    return 'All Business Owners';
      case 'leaders_financiers': return 'All Leaders / Financiers';
      case 'community_services': return 'All Community Services';
      default: return 'Directory';
    }
  }

  List<String> get _filterTags {
    switch (widget.category) {
      case 'professionals':      return professionalFilterTags;
      case 'business_owners':    return businessFilterTags;
      case 'leaders_financiers': return leaderFilterTags;
      case 'community_services': return communityFilterTags;
      default: return [];
    }
  }

  void _setSearch(String q) => setState(() => _search = q);

  void _applyTags(List<String> tags) => setState(() => _tags = tags);

  void _resetFilters() {
    setState(() {
      _search = '';
      _tags = [];
      _searchCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync  = ref.watch(directoryMembersProvider(_params));
    final activeFilters = _tags;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF121A2C), size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          _title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121A2C),
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune_outlined,
                    color: Color(0xFF121A2C), size: 22),
                onPressed: () => _showFilterSheet(
                    context, activeFilters, _applyTags, _resetFilters),
              ),
              if (activeFilters.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _setSearch,
              decoration: InputDecoration(
                hintText: 'Search by name, job, profession...',
                hintStyle:
                    const TextStyle(fontSize: 13, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search,
                    size: 18, color: AppColors.textMuted),
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (members) {
          if (members.isEmpty) {
            return _EmptyState(onReset: _resetFilters);
          }
          return Column(
            children: [
              if (activeFilters.isNotEmpty)
                _ActiveFilterBar(tags: activeFilters, onClear: _resetFilters),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: members.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _MemberListCard(
                    member: members[i],
                    onTap: () =>
                        context.push('/directory/members/${members[i].id}'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFilterSheet(
    BuildContext context,
    List<String> currentTags,
    ValueChanged<List<String>> onApply,
    VoidCallback onReset,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _FilterSheet(
        allTags: _filterTags,
        selectedTags: currentTags,
        onApply: (tags) {
          onApply(tags);
          Navigator.pop(ctx);
        },
        onReset: () {
          onReset();
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

// ── Member list card ──────────────────────────────────────────────────────────

class _MemberListCard extends StatelessWidget {
  final DirectoryMember member;
  final VoidCallback onTap;
  const _MemberListCard({required this.member, required this.onTap});

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
              _MemberAvatar(name: member.name, size: 50),
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
                          const Icon(Icons.verified,
                              size: 16, color: AppColors.accent),
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
                        if (member.tags.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _TagPill(tag: member.tags.first),
                        ],
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

class _TagPill extends StatelessWidget {
  final String tag;
  const _TagPill({required this.tag});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          tag,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.accent,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
}

// ── Active filter bar ─────────────────────────────────────────────────────────

class _ActiveFilterBar extends StatelessWidget {
  final List<String> tags;
  final VoidCallback onClear;
  const _ActiveFilterBar({required this.tags, required this.onClear});

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.accent.withValues(alpha: 0.1),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.filter_list,
                size: 14, color: AppColors.accent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                tags.join(', '),
                style: const TextStyle(
                    fontSize: 12, color: AppColors.accent),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: onClear,
              child: const Text(
                'Clear',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onReset;
  const _EmptyState({required this.onReset});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline,
                  size: 32, color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            const Text('No members found',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121A2C))),
            const SizedBox(height: 6),
            const Text('Try a different search or clear filters',
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onReset,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.accent),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Clear Filters',
                  style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      );
}

// ── Filter bottom sheet ───────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final List<String> allTags;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onApply;
  final VoidCallback onReset;
  const _FilterSheet({
    required this.allTags,
    required this.selectedTags,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedTags);
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Filter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF121A2C),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Looking for',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF121A2C),
              ),
            ),
            const SizedBox(height: 12),
            ...widget.allTags.map((tag) {
              final selected = _selected.contains(tag);
              return GestureDetector(
                onTap: () => setState(() {
                  selected ? _selected.remove(tag) : _selected.add(tag);
                }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.accent.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.accent
                          : const Color(0xFFE5E7EB),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: selected
                                ? AppColors.accent
                                : const Color(0xFF374151),
                          ),
                        ),
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selected
                              ? AppColors.accent
                              : Colors.white,
                          border: Border.all(
                            color: selected
                                ? AppColors.accent
                                : const Color(0xFFD1D5DB),
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check,
                                size: 13, color: Colors.white)
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onReset,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Reset',
                        style: TextStyle(
                            color: Color(0xFF374151),
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onApply(_selected),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    child: const Text('Apply',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}

// ── Avatar (shared) ───────────────────────────────────────────────────────────

class _MemberAvatar extends StatelessWidget {
  final String name;
  final double size;
  const _MemberAvatar({required this.name, required this.size});

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

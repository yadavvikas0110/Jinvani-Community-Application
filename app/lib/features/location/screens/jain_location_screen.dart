import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../models/jain_location.dart';
import '../state/location_controller.dart';

class JainLocationScreen extends ConsumerStatefulWidget {
  const JainLocationScreen({super.key});

  @override
  ConsumerState<JainLocationScreen> createState() => _JainLocationScreenState();
}

class _JainLocationScreenState extends ConsumerState<JainLocationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late TextEditingController _searchCtrl;
  String _search = '';

  static const _categories = locationCategories;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _categories.length, vsync: this);
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF121A2C), size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Jain Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121A2C),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search,
                color: Color(0xFF121A2C), size: 22),
            onPressed: () => _showSearch(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF7C3AED),
          labelStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500),
          indicator: BoxDecoration(
            color: const Color(0xFF7C3AED),
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          tabs: _categories
              .map((c) => Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: Text(c.label),
                    ),
                  ))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: _categories.map((cat) {
          return _LocationTab(
            category: cat.id,
            search: _search,
            onTap: (id) => context.push('/location/$id'),
          );
        }).toList(),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Search Locations',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Temple, dharmshala, city...',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textMuted, size: 18),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Search',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab content ───────────────────────────────────────────────────────────────

class _LocationTab extends ConsumerWidget {
  final String category;
  final String search;
  final ValueChanged<String> onTap;

  const _LocationTab({
    required this.category,
    required this.search,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = (category: category, search: search);
    final locationsAsync = ref.watch(locationListProvider(params));

    return locationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (locations) {
        if (locations.isEmpty) {
          return _EmptyState(search: search);
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: locations.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _LocationCard(
            location: locations[i],
            onTap: () => onTap(locations[i].id),
          ),
        );
      },
    );
  }
}

// ── Location card ─────────────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  final JainLocation location;
  final VoidCallback onTap;
  const _LocationCard({required this.location, required this.onTap});

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
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  location.primaryImage,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: const Color(0xFFEDE9FF),
                    child: const Icon(Icons.place_outlined,
                        color: Color(0xFF7C3AED), size: 32),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              location.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF121A2C),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            location.isSaved
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 18,
                            color: location.isSaved
                                ? const Color(0xFF7C3AED)
                                : AppColors.textMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Star rating
                      Row(
                        children: [
                          ...List.generate(5, (i) {
                            final full = i < location.rating.floor();
                            final half = !full &&
                                i < location.rating &&
                                (location.rating - i) >= 0.5;
                            return Icon(
                              full
                                  ? Icons.star
                                  : half
                                      ? Icons.star_half
                                      : Icons.star_border,
                              size: 13,
                              color: const Color(0xFFFFC107),
                            );
                          }),
                          const SizedBox(width: 4),
                          Text(
                            '${location.rating} (${location.reviewCount})',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${location.city}, ${location.state}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      _CategoryPill(category: location.category),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _CategoryPill extends StatelessWidget {
  final String category;
  const _CategoryPill({required this.category});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (category) {
      case 'historical':
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFD97706);
        label = 'Historical';
        break;
      case 'devotional':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        label = 'Devotional';
        break;
      case 'dharmshala':
        bg = const Color(0xFFEFF6FF);
        fg = const Color(0xFF2563EB);
        label = 'Dharmshala';
        break;
      default:
        bg = const Color(0xFFF3F0FF);
        fg = const Color(0xFF7C3AED);
        label = category;
    }
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String search;
  const _EmptyState({required this.search});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F0FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.place_outlined,
                  size: 32, color: Color(0xFF7C3AED)),
            ),
            const SizedBox(height: 16),
            Text(
              search.isEmpty
                  ? 'No locations in this category'
                  : 'No results for "$search"',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121A2C)),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try a different category or search term',
              style: TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
}

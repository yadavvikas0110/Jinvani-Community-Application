import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../state/location_controller.dart';

class JainLocationDetailScreen extends ConsumerWidget {
  final String locationId;
  const JainLocationDetailScreen({super.key, required this.locationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(locationDetailProvider(locationId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F6),
      body: locationAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (location) {
          if (location == null) {
            return const Center(child: Text('Location not found'));
          }
          return CustomScrollView(
            slivers: [
              // ── Full-width image header ─────────────────────────────────
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: const Color(0xFF1C427D),
                surfaceTintColor: Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 20),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        location.isSaved
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    location.primaryImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFEDE9FF),
                      child: const Icon(Icons.place,
                          size: 80, color: Color(0xFF7C3AED)),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Name + tag + rating ───────────────────────────────
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  location.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF121A2C),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _OnVisitBadge(category: location.category),
                            ],
                          ),
                          const SizedBox(height: 8),
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
                                  size: 16,
                                  color: const Color(0xFFFFC107),
                                );
                              }),
                              const SizedBox(width: 6),
                              Text(
                                '${location.rating}  (${location.reviewCount} reviews)',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Address ───────────────────────────────────────────
                    _InfoCard(
                      title: 'Address',
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: Color(0xFF7C3AED)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${location.address}, ${location.city}, ${location.state}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ── About ─────────────────────────────────────────────
                    _InfoCard(
                      title: 'About',
                      child: Text(
                        location.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4C4A53),
                          height: 1.65,
                        ),
                      ),
                    ),

                    // ── Photos grid ───────────────────────────────────────
                    if (location.imageUrls.length > 1)
                      _InfoCard(
                        title: 'Photos',
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 6,
                            childAspectRatio: 1,
                          ),
                          itemCount: location.imageUrls.length,
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              location.imageUrls[i],
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                color: const Color(0xFFEDE9FF),
                                child: const Icon(Icons.image_outlined,
                                    color: Color(0xFF7C3AED), size: 24),
                              ),
                            ),
                          ),
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

// ── On Visit badge ────────────────────────────────────────────────────────────

class _OnVisitBadge extends StatelessWidget {
  final String category;
  const _OnVisitBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (category) {
      case 'historical':
        bg = const Color(0xFFFFF7ED); fg = const Color(0xFFD97706);
        label = 'Historical';
        break;
      case 'devotional':
        bg = const Color(0xFFECFDF5); fg = const Color(0xFF059669);
        label = 'Devotional';
        break;
      case 'dharmshala':
        bg = const Color(0xFFEFF6FF); fg = const Color(0xFF2563EB);
        label = 'Dharmshala';
        break;
      default:
        bg = const Color(0xFFF3F0FF); fg = const Color(0xFF7C3AED);
        label = 'On Visit';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

// ── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _InfoCard({required this.title, required this.child});

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
            const SizedBox(height: 10),
            child,
          ],
        ),
      );
}

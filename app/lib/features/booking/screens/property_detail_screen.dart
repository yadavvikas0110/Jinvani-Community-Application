import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/property.dart';
import '../state/booking_controller.dart';

class PropertyDetailScreen extends ConsumerWidget {
  final String propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyDetailProvider(propertyId));
    final checkout = ref.watch(checkoutControllerProvider);

    return propertyAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error: $e'))),
      data: (property) {
        if (property == null) {
          return const Scaffold(
              body: Center(child: Text('Property not found')));
        }
        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              // ── Hero image ────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back,
                          size: 20, color: Color(0xFF111827)),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: GestureDetector(
                      onTap: () => ref
                          .read(propertiesControllerProvider.notifier)
                          .toggleSave(property.id),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          property.isSaved
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: property.isSaved
                              ? Colors.red
                              : const Color(0xFF111827),
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Image.network(
                    property.primaryImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFFEDE9FF),
                      child: const Icon(Icons.apartment_outlined,
                          size: 60, color: Color(0xFF7C3AED)),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Category badge + rating ───────────────────────────
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF5FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              property.type == 'dharamshala'
                                  ? 'Dharamshala'
                                  : 'Hotel',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.star,
                              size: 14, color: Color(0xFFFFC107)),
                          const SizedBox(width: 3),
                          Text(
                            '${property.rating} (${property.reviewCount})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Property name ─────────────────────────────────────
                      Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(
                            property.location,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Booking info card ─────────────────────────────────
                      _BookingInfoCard(checkout: checkout),
                      const SizedBox(height: 20),

                      // ── About this property ───────────────────────────────
                      const Text(
                        'About this property',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Amenities ─────────────────────────────────────────
                      const Text(
                        'Amenities',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AmenitiesGrid(amenities: property.amenities),
                      const SizedBox(height: 24),

                      // ── Select a Room ─────────────────────────────────────
                      const Text(
                        'Select a Room',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...property.rooms.map((room) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _RoomCard(
                              room: room,
                              onSelect: () {
                                ref
                                    .read(checkoutControllerProvider.notifier)
                                    .selectRoom(room);
                                context.push(
                                    '/booking/properties/$propertyId/checkout');
                              },
                            ),
                          )),
                      const SizedBox(height: 8),

                      // ── Location map placeholder ──────────────────────────
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          height: 160,
                          width: double.infinity,
                          color: const Color(0xFFE5E7EB),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on,
                                    size: 32, color: Color(0xFF7C3AED)),
                                SizedBox(height: 6),
                                Text('Map View',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Booking info card ─────────────────────────────────────────────────────────

class _BookingInfoCard extends StatelessWidget {
  final CheckoutState checkout;
  const _BookingInfoCard({required this.checkout});

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd-${mm.padLeft(2, '0')}-${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final checkIn = checkout.checkIn;
    final checkOut = checkout.checkOut;
    final nights = checkout.nights;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _InfoCell(
              label: 'Check-in',
              value: checkIn != null ? _fmtDate(checkIn) : '--',
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: _InfoCell(
              label: 'Check-out',
              value: checkOut != null ? _fmtDate(checkOut) : '--',
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: _InfoCell(
              label: 'Guests',
              value: '${checkout.guests} Guests',
            ),
          ),
          Container(width: 1, height: 36, color: const Color(0xFFE5E7EB)),
          Expanded(
            child: _InfoCell(
              label: 'Duration',
              value: nights > 0 ? '$nights Night${nights > 1 ? 's' : ''}' : '--',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF9CA3AF))),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827))),
          ],
        ),
      );
}

// ── Amenities grid ────────────────────────────────────────────────────────────

class _AmenitiesGrid extends StatelessWidget {
  final List<String> amenities;
  const _AmenitiesGrid({required this.amenities});

  IconData _icon(String amenity) {
    switch (amenity) {
      case 'Mountain View': return Icons.landscape_outlined;
      case 'Prayer Room': return Icons.temple_hindu_outlined;
      case 'Library': return Icons.menu_book_outlined;
      case 'Herbal Garden': return Icons.eco_outlined;
      case 'Free WiFi': return Icons.wifi;
      case 'Parking': return Icons.local_parking;
      case 'Temple Nearby': return Icons.temple_hindu_outlined;
      default: return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 3.5,
      children: amenities.map((a) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(_icon(a),
                      size: 14, color: const Color(0xFF7C3AED)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(a,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          )).toList(),
    );
  }
}

// ── Room card ─────────────────────────────────────────────────────────────────

class _RoomCard extends StatelessWidget {
  final RoomType room;
  final VoidCallback onSelect;

  const _RoomCard({required this.room, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  room.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '₹${room.pricePerNight.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    const TextSpan(
                      text: '/night',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Up to ${room.maxGuests} guests',
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${room.availableRooms} rooms available',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF059669),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1B4B), Color(0xFF7C3AED)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: onSelect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Select Room',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

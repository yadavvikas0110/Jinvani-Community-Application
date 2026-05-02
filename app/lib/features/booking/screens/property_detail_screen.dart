import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../models/property.dart';
import '../state/booking_controller.dart';

class PropertyDetailScreen extends ConsumerWidget {
  final String propertyId;
  const PropertyDetailScreen({super.key, required this.propertyId});

  static const _purple = AppColors.accent;

  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/booking/properties');
    }
  }

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
          backgroundColor: const Color(0xFFF7F7F6),
          body: CustomScrollView(
            slivers: [
              // ── Hero image with floating back ────────────────────────────
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0,
                automaticallyImplyLeading: false,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () => _back(context),
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
                          size: 60, color: _purple),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Type pill + rating pill ───────────────────────────
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECF4FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              property.type == 'dharamshala'
                                  ? 'Dharamshala'
                                  : 'Hotel',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1B5BB3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9E3),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    size: 13, color: Color(0xFFFFB300)),
                                const SizedBox(width: 4),
                                Text(
                                  '${property.rating}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF101828),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${property.reviewCount})',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF757F8F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Property name + location ──────────────────────────
                      Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(
                            property.location,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A5565),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Booking dates card (2-col) ────────────────────────
                      _BookingDatesCard(checkout: checkout),
                      const SizedBox(height: 12),

                      // ── Guests & Rooms picker row ─────────────────────────
                      _GuestsRoomsRow(checkout: checkout),
                    ],
                  ),
                ),
              ),

              // ── About this property ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About this property',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF7E8288),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Amenities ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amenities',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _AmenitiesGrid(amenities: property.amenities),
                    ],
                  ),
                ),
              ),

              // ── Choose a Room ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choose a Room',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...property.rooms.map((room) {
                        final isSelected = checkout.selectedRoom?.id == room.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _RoomCard(
                            room: room,
                            propertyImage: property.primaryImage,
                            amenities: property.amenities,
                            isSelected: isSelected,
                            roomCount: checkout.roomCount,
                            onSelect: () {
                              ref
                                  .read(checkoutControllerProvider.notifier)
                                  .selectRoom(room);
                            },
                            onContinue: () {
                              ref
                                  .read(checkoutControllerProvider.notifier)
                                  .selectRoom(room);
                              context.push(
                                  '/booking/properties/$propertyId/checkout');
                            },
                            onIncRoom: () => ref
                                .read(checkoutControllerProvider.notifier)
                                .setRoomCount(checkout.roomCount + 1),
                            onDecRoom: checkout.roomCount > 1
                                ? () => ref
                                    .read(checkoutControllerProvider.notifier)
                                    .setRoomCount(checkout.roomCount - 1)
                                : null,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // ── Location ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          color: const Color(0xFFE5E7EB),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on,
                                    size: 32, color: _purple),
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
                      const SizedBox(height: 8),
                      Text(
                        property.location,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6A7282),
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

// ── Booking dates card (2-col with bottom duration strip) ───────────────────

class _BookingDatesCard extends StatelessWidget {
  final CheckoutState checkout;
  const _BookingDatesCard({required this.checkout});

  String _shortMonth(int m) {
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m];
  }

  String _weekdayName(int w) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[w];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E9FF)),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _DateCell(
                    label: 'CHECK-IN',
                    date: checkout.checkIn,
                    monthFn: _shortMonth,
                    weekdayFn: _weekdayName,
                  ),
                ),
                Container(width: 1, color: const Color(0xFFE2E9FF)),
                Expanded(
                  child: _DateCell(
                    label: 'CHECK-OUT',
                    date: checkout.checkOut,
                    monthFn: _shortMonth,
                    weekdayFn: _weekdayName,
                  ),
                ),
              ],
            ),
          ),
          // Duration strip
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEDF2FF), Color(0xFFF9F0FF)],
              ),
              border: Border(
                top: BorderSide(color: Color(0xFFE2E9FF)),
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 12, color: Color(0xFF0C3CBD)),
                const SizedBox(width: 6),
                Text(
                  checkout.nights > 0
                      ? '${checkout.nights} Night${checkout.nights > 1 ? 's' : ''}'
                      : 'Select dates',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0C3CBD),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateCell extends StatelessWidget {
  final String label;
  final DateTime? date;
  final String Function(int) monthFn;
  final String Function(int) weekdayFn;

  const _DateCell({
    required this.label,
    required this.date,
    required this.monthFn,
    required this.weekdayFn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF355BC2),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            date != null ? '${date!.day} ${monthFn(date!.month)}' : '--',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF33363B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            date != null
                ? '${weekdayFn(date!.weekday)},${date!.year}'
                : 'Not selected',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF848F9E),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Guests & Rooms row ───────────────────────────────────────────────────────

class _GuestsRoomsRow extends StatelessWidget {
  final CheckoutState checkout;
  const _GuestsRoomsRow({required this.checkout});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFECECF2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_outline,
              size: 20, color: Color(0xFF848F9E)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Guests & Rooms',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF848F9E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${checkout.guests} Guests, ${checkout.roomCount} Room${checkout.roomCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2939),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              size: 20, color: Color(0xFF848F9E)),
        ],
      ),
    );
  }
}

// ── Amenities grid (2x4) ─────────────────────────────────────────────────────

class _AmenitiesGrid extends StatelessWidget {
  final List<String> amenities;
  const _AmenitiesGrid({required this.amenities});

  IconData _icon(String amenity) {
    switch (amenity) {
      case 'Mountain View':
        return Icons.landscape_outlined;
      case 'Prayer Room':
      case 'Temple Nearby':
        return Icons.temple_hindu_outlined;
      case 'Library':
        return Icons.menu_book_outlined;
      case 'Herbal Garden':
        return Icons.eco_outlined;
      case 'Free WiFi':
        return Icons.wifi;
      case 'Parking':
      case 'Vehicle Parking':
        return Icons.local_parking;
      case 'Swimming Pool':
        return Icons.pool_outlined;
      case 'Dining Hall':
        return Icons.restaurant_outlined;
      case 'Medical Aid':
        return Icons.medical_services_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  Color _bgFor(int i) {
    const palette = [
      Color(0xFFF5F3FF),
      Color(0xFFFDF4FF),
      Color(0xFFFFFBEB),
      Color(0xFFFFF7ED),
      Color(0xFFEFF6FF),
      Color(0xFFFFF1F2),
      Color(0xFFECFCCB),
      Color(0xFFE0F2FE),
    ];
    return palette[i % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(amenities.length, (i) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 16 * 2 - 12 * 3) / 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: _bgFor(i),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(_icon(amenities[i]),
                    size: 18, color: const Color(0xFF374151)),
                const SizedBox(height: 6),
                Text(
                  amenities[i],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF364153),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Room card ────────────────────────────────────────────────────────────────

class _RoomCard extends StatelessWidget {
  final RoomType room;
  final String propertyImage;
  final List<String> amenities;
  final bool isSelected;
  final int roomCount;
  final VoidCallback onSelect;
  final VoidCallback onContinue;
  final VoidCallback onIncRoom;
  final VoidCallback? onDecRoom;

  const _RoomCard({
    required this.room,
    required this.propertyImage,
    required this.amenities,
    required this.isSelected,
    required this.roomCount,
    required this.onSelect,
    required this.onContinue,
    required this.onIncRoom,
    required this.onDecRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image header with price overlay ──────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Stack(
              children: [
                Image.network(
                  propertyImage,
                  height: 128,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 128,
                    color: const Color(0xFFEDE9FF),
                    child: const Icon(Icons.apartment_outlined,
                        size: 40, color: AppColors.accent),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10000),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                            text: '₹${room.pricePerNight.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(
                            text: ' /night',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row + availability pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            room.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101828),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Up to ${room.maxGuests} guests',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6A7282),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDAFDE7),
                        border:
                            Border.all(color: const Color(0xFF9DD3B2)),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF09AD48),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${room.availableRooms} Left',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF09AD48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Feature pills (uses property amenities, top 3)
                if (amenities.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: amenities
                        .take(3)
                        .map((a) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FBFF),
                                border: Border.all(
                                    color: const Color(0xFFDBE1F6)),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: Text(
                                a,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF364153),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 16),

                // Number-of-rooms stepper (selected only)
                if (isSelected) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Number of rooms',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF101828),
                            ),
                          ),
                        ),
                        _StepBtn(
                          icon: Icons.remove,
                          onTap: onDecRoom,
                          highlight: false,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$roomCount',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF101828),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _StepBtn(
                          icon: Icons.add,
                          onTap: roomCount < room.availableRooms
                              ? onIncRoom
                              : null,
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // CTA
                SizedBox(
                  width: double.infinity,
                  child: isSelected
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton.icon(
                            onPressed: onContinue,
                            icon: const Icon(Icons.check,
                                size: 18, color: Colors.white),
                            label: const Text(
                              'Room Selected',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: onSelect,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFEDEDF1),
                            foregroundColor: const Color(0xFF0C0C0C),
                            elevation: 0,
                            padding:
                                const EdgeInsets.symmetric(vertical: 11),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'Select Room',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool highlight;
  const _StepBtn({required this.icon, required this.onTap, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: highlight && enabled
              ? AppColors.accent
              : const Color(0xFFF9FAFB),
          shape: BoxShape.circle,
          border: Border.all(
            color: highlight && enabled
                ? AppColors.accent
                : const Color(0xFFBBBFE3),
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: highlight && enabled
              ? Colors.white
              : enabled
                  ? const Color(0xFF1E2939)
                  : const Color(0xFFD1D5DB),
        ),
      ),
    );
  }
}

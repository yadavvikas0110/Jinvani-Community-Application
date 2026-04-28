import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/property.dart';
import '../state/booking_controller.dart';

class MyBookingsScreen extends ConsumerStatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  ConsumerState<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends ConsumerState<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(myBookingsProvider);

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
          'My Bookings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121A2C),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF7C3AED),
          unselectedLabelColor: const Color(0xFF9CA3AF),
          indicatorColor: const Color(0xFF7C3AED),
          indicatorWeight: 2.5,
          labelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
        ),
      ),
      body: bookingsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (bookings) {
          final upcoming = bookings
              .where((b) => b.status == 'upcoming')
              .toList();
          final past = bookings
              .where((b) =>
                  b.status == 'completed' || b.status == 'cancelled')
              .toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _BookingList(
                bookings: upcoming,
                emptyMessage: 'No upcoming bookings',
                isUpcoming: true,
                onExplore: () => context.go('/booking'),
              ),
              _BookingList(
                bookings: past,
                emptyMessage: 'No past bookings yet',
                isUpcoming: false,
                onExplore: () => context.go('/booking'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Booking list ──────────────────────────────────────────────────────────────

class _BookingList extends StatelessWidget {
  final List<Booking> bookings;
  final String emptyMessage;
  final bool isUpcoming;
  final VoidCallback onExplore;

  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
    required this.isUpcoming,
    required this.onExplore,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F0FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today_outlined,
                  size: 36, color: Color(0xFF7C3AED)),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore properties and book your stay',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onExplore,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF7C3AED)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 12),
              ),
              child: const Text(
                'Explore Properties',
                style: TextStyle(
                    color: Color(0xFF7C3AED),
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, i) =>
          _BookingCard(booking: bookings[i], isUpcoming: isUpcoming),
    );
  }
}

// ── Booking card ──────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final bool isUpcoming;

  const _BookingCard({required this.booking, required this.isUpcoming});

  String _fmtDate(DateTime d) {
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month]}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/booking/bookings/${booking.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Gradient header band ─────────────────────────────────────
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUpcoming
                    ? const LinearGradient(
                        colors: [Color(0xFF1E1B4B), Color(0xFF7C3AED)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF374151), Color(0xFF6B7280)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Text(
                    booking.bookingRef,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _statusLabel(booking.status),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Property info ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: booking.propertyImageUrl != null
                            ? Image.network(
                                booking.propertyImageUrl!,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _imageFallback(),
                              )
                            : _imageFallback(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Type badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF5FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                booking.propertyType == 'dharamshala'
                                    ? 'Dharamshala'
                                    : 'Hotel',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              booking.propertyTitle,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 12,
                                    color: Color(0xFF9CA3AF)),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    booking.propertyLocation,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF6B7280)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── 2x2 info grid ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCell(
                          label: 'Check-in',
                          value: _fmtDate(booking.checkIn),
                          icon: Icons.login_outlined,
                        ),
                      ),
                      Expanded(
                        child: _InfoCell(
                          label: 'Check-out',
                          value: _fmtDate(booking.checkOut),
                          icon: Icons.logout_outlined,
                        ),
                      ),
                      Expanded(
                        child: _InfoCell(
                          label: 'Guests',
                          value: '${booking.guests}',
                          icon: Icons.person_outline,
                        ),
                      ),
                      Expanded(
                        child: _InfoCell(
                          label: 'Nights',
                          value: '${booking.nights}',
                          icon: Icons.nights_stay_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Total + View Details ──────────────────────────────
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Amount',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF))),
                          const SizedBox(height: 2),
                          Text(
                            '₹${booking.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () => context
                            .push('/booking/bookings/${booking.id}'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Color(0xFF7C3AED), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                        ),
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() => Container(
        width: 70,
        height: 70,
        decoration: const BoxDecoration(
          color: Color(0xFFEDE9FF),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: const Icon(Icons.apartment_outlined,
            color: Color(0xFF7C3AED), size: 28),
      );

  String _statusLabel(String status) {
    switch (status) {
      case 'upcoming':
        return 'Upcoming';
      case 'cancelled':
        return 'Cancelled';
      case 'completed':
        return 'Completed';
      default:
        return status[0].toUpperCase() + status.substring(1);
    }
  }
}

// ── Info cell ─────────────────────────────────────────────────────────────────

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoCell(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(icon, size: 12, color: const Color(0xFF7C3AED)),
              const SizedBox(width: 3),
              Text(value,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  )),
            ],
          ),
        ],
      );
}

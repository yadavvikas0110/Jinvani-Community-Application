import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/booking_controller.dart';

class BookingConfirmedScreen extends ConsumerWidget {
  final String bookingId;
  const BookingConfirmedScreen({super.key, required this.bookingId});

  static const _purple = Color(0xFF7C3AED);

  String _fmtDate(DateTime d) {
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F6),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (booking) {
          return CustomScrollView(
            slivers: [
              // ── Gradient header ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Your payment was successful!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your booking has been confirmed.\nGet ready for an amazing stay!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (booking != null) ...[
                        // ── Booking Summary card ─────────────────────────────
                        _SectionCard(
                          title: 'Booking Summary',
                          child: Column(
                            children: [
                              // Property row
                              Row(
                                children: [
                                  if (booking.propertyImageUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        booking.propertyImageUrl!,
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 64,
                                          height: 64,
                                          color: const Color(0xFFEDE9FF),
                                          child: const Icon(
                                              Icons.apartment_outlined,
                                              color: _purple,
                                              size: 28),
                                        ),
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEBF5FF),
                                            borderRadius:
                                                BorderRadius.circular(20),
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
                                            const Icon(
                                                Icons.location_on_outlined,
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
                              const Divider(height: 24, color: Color(0xFFEEEEEE)),

                              // Status
                              _InfoRow(
                                label: 'Status',
                                value: 'Confirmed',
                                valueColor: const Color(0xFF059669),
                                valueBold: true,
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: 'Booking Ref',
                                value: booking.bookingRef,
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: 'Room Type',
                                value: booking.roomType,
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: 'Check-in',
                                value: _fmtDate(booking.checkIn),
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: 'Check-out',
                                value: _fmtDate(booking.checkOut),
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: 'Guests',
                                value:
                                    '${booking.guests} Guest${booking.guests > 1 ? 's' : ''}',
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(
                                label: 'Duration',
                                value:
                                    '${booking.nights} Night${booking.nights > 1 ? 's' : ''}',
                              ),
                              const Divider(height: 24, color: Color(0xFFEEEEEE)),
                              _InfoRow(
                                label: 'Total Paid',
                                value:
                                    '₹${booking.totalPrice.toStringAsFixed(0)}',
                                valueColor: _purple,
                                valueBold: true,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Important information ────────────────────────────
                        _SectionCard(
                          title: 'Important Information',
                          child: Column(
                            children: const [
                              _InfoItem(
                                icon: Icons.access_time_outlined,
                                iconColor: Color(0xFF7C3AED),
                                text: 'Check-in time is 12:00 PM. Early check-in is subject to availability.',
                              ),
                              SizedBox(height: 12),
                              _InfoItem(
                                icon: Icons.cancel_outlined,
                                iconColor: Color(0xFFD97706),
                                text: 'Free cancellation up to 24 hours before check-in.',
                              ),
                              SizedBox(height: 12),
                              _InfoItem(
                                icon: Icons.phone_outlined,
                                iconColor: Color(0xFF059669),
                                text: 'A confirmation has been sent to your registered email and phone.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── View My Bookings button ──────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E1B4B), _purple],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(checkoutControllerProvider.notifier)
                                  .reset();
                              context.go('/booking/my-bookings');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text(
                              'View My Bookings',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Back to Home ──────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            ref
                                .read(checkoutControllerProvider.notifier)
                                .reset();
                            context.go('/booking');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFFE5E7EB), width: 1.5),
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            'Back to Home',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Need help ─────────────────────────────────────────
                      Center(
                        child: TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.headset_mic_outlined,
                              size: 16, color: _purple),
                          label: const Text(
                            'Need help? Contact Support',
                            style: TextStyle(
                              fontSize: 13,
                              color: _purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      );
}

// ── Info row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool valueBold;
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280))),
          Text(value,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    valueBold ? FontWeight.w700 : FontWeight.w600,
                color: valueColor ?? const Color(0xFF111827),
              )),
        ],
      );
}

// ── Info item ─────────────────────────────────────────────────────────────────

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  const _InfoItem(
      {required this.icon, required this.iconColor, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ),
        ],
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/booking_repository.dart';
import '../state/booking_controller.dart';

class BookingDetailScreen extends ConsumerWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  static const _purple = Color(0xFF7C3AED);

  String _fmtDate(DateTime d) {
    const months = [
      '',
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingAsync = ref.watch(bookingDetailProvider(bookingId));

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
          'Booking Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121A2C),
          ),
        ),
      ),
      body: bookingAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (booking) {
          if (booking == null) {
            return const Center(child: Text('Booking not found'));
          }

          final isUpcoming = booking.status == 'upcoming';
          final isCancelled = booking.status == 'cancelled';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            children: [
              // ── Header card ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: isUpcoming
                      ? const LinearGradient(
                          colors: [Color(0xFF1E1B4B), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFF374151), Color(0xFF6B7280)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Booking Reference',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.white60),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                booking.bookingRef,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isCancelled
                                ? 'Cancelled'
                                : isUpcoming
                                    ? 'Confirmed'
                                    : 'Completed',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _HeaderInfoCell(
                            label: 'Check-in',
                            value: '${booking.checkIn.day} ${_shortMonth(booking.checkIn.month)}'),
                        const _Divider(),
                        _HeaderInfoCell(
                            label: 'Check-out',
                            value: '${booking.checkOut.day} ${_shortMonth(booking.checkOut.month)}'),
                        const _Divider(),
                        _HeaderInfoCell(
                            label: 'Nights',
                            value: '${booking.nights}'),
                        const _Divider(),
                        _HeaderInfoCell(
                            label: 'Guests',
                            value: '${booking.guests}'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Property card ────────────────────────────────────────────
              _SectionCard(
                title: 'Property',
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: booking.propertyImageUrl != null
                          ? Image.network(
                              booking.propertyImageUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _imgFallback(),
                            )
                          : _imgFallback(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          const SizedBox(height: 6),
                          Text(
                            booking.propertyTitle,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 13,
                                  color: Color(0xFF9CA3AF)),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  booking.propertyLocation,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280)),
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
              const SizedBox(height: 14),

              // ── Stay details ─────────────────────────────────────────────
              _SectionCard(
                title: 'Stay Details',
                child: Column(
                  children: [
                    // Check-in / Check-out side by side
                    Row(
                      children: [
                        Expanded(
                          child: _StayDateBox(
                            label: 'Check-in',
                            date: _fmtDate(booking.checkIn),
                            icon: Icons.login_outlined,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StayDateBox(
                            label: 'Check-out',
                            date: _fmtDate(booking.checkOut),
                            icon: Icons.logout_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _DetailRow(
                      icon: Icons.hotel_outlined,
                      label: 'Room Type',
                      value: booking.roomType,
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.person_outline,
                      label: 'Guests',
                      value:
                          '${booking.guests} Guest${booking.guests > 1 ? 's' : ''}',
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.meeting_room_outlined,
                      label: 'Rooms',
                      value:
                          '${booking.roomCount} Room${booking.roomCount > 1 ? 's' : ''}',
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.nights_stay_outlined,
                      label: 'Duration',
                      value:
                          '${booking.nights} Night${booking.nights > 1 ? 's' : ''}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Price details ────────────────────────────────────────────
              _SectionCard(
                title: 'Price Details',
                child: Column(
                  children: [
                    _PriceRow(label: 'Room charges',
                        value: '₹${(booking.totalPrice / 1.12).toStringAsFixed(0)}'),
                    const SizedBox(height: 10),
                    _PriceRow(label: 'Taxes & Fees (12%)',
                        value: '₹${(booking.totalPrice - booking.totalPrice / 1.12).toStringAsFixed(0)}'),
                    const Divider(height: 20, color: Color(0xFFEEEEEE)),
                    _PriceRow(
                      label: 'Total Amount',
                      value: '₹${booking.totalPrice.toStringAsFixed(0)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Guest details ────────────────────────────────────────────
              if (booking.guestName.isNotEmpty) ...[
                _SectionCard(
                  title: 'Guest Details',
                  child: Column(
                    children: [
                      if (booking.guestName.isNotEmpty)
                        _DetailRow(
                          icon: Icons.person_outline,
                          label: 'Name',
                          value: booking.guestName,
                        ),
                      if (booking.guestEmail.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _DetailRow(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: booking.guestEmail,
                        ),
                      ],
                      if (booking.guestPhone.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _DetailRow(
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: booking.guestPhone,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // ── Payment details ──────────────────────────────────────────
              _SectionCard(
                title: 'Payment Details',
                child: Column(
                  children: [
                    _DetailRow(
                      icon: Icons.payment_outlined,
                      label: 'Method',
                      value: booking.paymentMethod,
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.receipt_outlined,
                      label: 'Transaction ID',
                      value: booking.transactionId,
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      icon: Icons.check_circle_outline,
                      label: 'Status',
                      value: booking.paymentStatus[0].toUpperCase() +
                          booking.paymentStatus.substring(1),
                      valueColor: booking.paymentStatus == 'paid'
                          ? const Color(0xFF059669)
                          : booking.paymentStatus == 'refunded'
                              ? const Color(0xFF2563EB)
                              : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Past booking actions ─────────────────────────────────────
              if (!isUpcoming && !isCancelled) ...[
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF193361),
                          Color(0xFF5970AF),
                          Color(0xFF985AC0),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0.0, 0.475, 1.0],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_outlined,
                          size: 18, color: Colors.white),
                      label: const Text('Download Invoice',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/booking'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE9E9E9)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Book Again',
                        style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF121A2C),
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Need Help (upcoming only) ────────────────────────────────
              if (isUpcoming) ...[
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF193361),
                          Color(0xFF5970AF),
                          Color(0xFF985AC0),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0.0, 0.475, 1.0],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/support'),
                      icon: const Icon(Icons.headset_mic_outlined,
                          size: 18, color: Colors.white),
                      label: const Text('Need Help',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Cancel upcoming booking ──────────────────────────────────
              if (isUpcoming) ...[
                OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        title: const Text('Cancel Booking?',
                            style:
                                TextStyle(fontWeight: FontWeight.w700)),
                        content: const Text(
                            'Are you sure you want to cancel this booking? A full refund will be processed.'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('No',
                                style: TextStyle(
                                    color: Color(0xFF6B7280))),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFDC2626),
                              elevation: 0,
                            ),
                            child: const Text('Cancel Booking',
                                style:
                                    TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await ref
                          .read(bookingRepositoryProvider)
                          .cancelBooking(booking.id);
                      ref.invalidate(myBookingsProvider);
                      ref.invalidate(
                          bookingDetailProvider(booking.id));
                      if (context.mounted) {
                        Navigator.of(context).maybePop();
                      }
                    }
                  },
                  icon: const Icon(Icons.cancel_outlined,
                      color: Color(0xFFDC2626), size: 18),
                  label: const Text('Cancel Booking',
                      style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFDC2626)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Need help ────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F0FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.headset_mic_outlined,
                          size: 20, color: _purple),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Need Help?',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827))),
                          SizedBox(height: 2),
                          Text('Contact our support team 24/7',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280))),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right,
                        color: Color(0xFF9CA3AF), size: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _imgFallback() => Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          color: Color(0xFFEDE9FF),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: const Icon(Icons.apartment_outlined,
            color: _purple, size: 32),
      );

  String _shortMonth(int m) {
    const months = [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[m];
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
          borderRadius: BorderRadius.circular(14),
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
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827))),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
}

// ── Header info cell (in gradient card) ──────────────────────────────────────

class _HeaderInfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _HeaderInfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Colors.white60)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
          ],
        ),
      );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 30,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: Colors.white.withValues(alpha: 0.25),
      );
}

// ── Stay date box ─────────────────────────────────────────────────────────────

class _StayDateBox extends StatelessWidget {
  final String label;
  final String date;
  final IconData icon;
  const _StayDateBox(
      {required this.label, required this.date, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F3FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 13, color: const Color(0xFF7C3AED)),
                const SizedBox(width: 4),
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF9CA3AF))),
              ],
            ),
            const SizedBox(height: 5),
            Text(date,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827))),
          ],
        ),
      );
}

// ── Detail row ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _DetailRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF6B7280))),
          const Spacer(),
          Text(value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF111827),
              )),
        ],
      );
}

// ── Price row ─────────────────────────────────────────────────────────────────

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _PriceRow(
      {required this.label, required this.value, this.isBold = false});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isBold ? 14 : 13,
                  fontWeight:
                      isBold ? FontWeight.w700 : FontWeight.w400,
                  color: isBold
                      ? const Color(0xFF111827)
                      : const Color(0xFF6B7280))),
          Text(value,
              style: TextStyle(
                  fontSize: isBold ? 16 : 13,
                  fontWeight:
                      isBold ? FontWeight.w800 : FontWeight.w500,
                  color: isBold
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFF374151))),
        ],
      );
}

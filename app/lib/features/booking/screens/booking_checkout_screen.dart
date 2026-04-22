import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/booking_controller.dart';

class BookingCheckoutScreen extends ConsumerStatefulWidget {
  final String propertyId;
  const BookingCheckoutScreen({super.key, required this.propertyId});

  @override
  ConsumerState<BookingCheckoutScreen> createState() =>
      _BookingCheckoutScreenState();
}

class _BookingCheckoutScreenState
    extends ConsumerState<BookingCheckoutScreen> {
  int _step = 0; // 0 = Room Details, 1 = Guest Details

  static const _purple = Color(0xFF7C3AED);

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _requestsFocus = FocusNode();

  @override
  void dispose() {
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _requestsFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync =
        ref.watch(propertyDetailProvider(widget.propertyId));
    final checkout = ref.watch(checkoutControllerProvider);
    final ctrl = ref.read(checkoutControllerProvider.notifier);

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

        final room = checkout.selectedRoom;
        if (room == null) {
          return const Scaffold(
              body: Center(child: Text('No room selected')));
        }

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
              onPressed: () {
                if (_step == 1) {
                  setState(() => _step = 0);
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            ),
            title: Text(
              _step == 0 ? 'Checkout' : 'Guest Details',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF121A2C),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              // ── Property card ─────────────────────────────────────────────
              _PropertyCard(property: property, roomName: room.name),
              const SizedBox(height: 16),

              if (_step == 0) ...[
                // ── Room Details ──────────────────────────────────────────
                _SectionCard(
                  title: 'Room Details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  room.name,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Up to ${room.maxGuests} guests',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '₹${room.pricePerNight.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: _purple,
                                  ),
                                ),
                                const TextSpan(
                                  text: '/night',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Available rooms: ${room.availableRooms}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Text(
                            'Number of rooms',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF374151)),
                          ),
                          const Spacer(),
                          _CounterBtn(
                            icon: Icons.remove,
                            onTap: checkout.roomCount > 1
                                ? () => ctrl.setRoomCount(
                                    checkout.roomCount - 1)
                                : null,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '${checkout.roomCount}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                          _CounterBtn(
                            icon: Icons.add,
                            onTap: checkout.roomCount < room.availableRooms
                                ? () => ctrl.setRoomCount(
                                    checkout.roomCount + 1)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Booking Summary ───────────────────────────────────────
                _SectionCard(
                  title: 'Booking Summary',
                  child: Column(
                    children: [
                      _SummaryRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Check-in',
                        value: checkout.checkIn != null
                            ? _fmtDate(checkout.checkIn!)
                            : 'Not selected',
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Check-out',
                        value: checkout.checkOut != null
                            ? _fmtDate(checkout.checkOut!)
                            : 'Not selected',
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        icon: Icons.access_time_outlined,
                        label: 'Duration',
                        value: checkout.nights > 0
                            ? '${checkout.nights} Night${checkout.nights > 1 ? 's' : ''}'
                            : '--',
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        icon: Icons.person_outline,
                        label: 'Guests',
                        value: '${checkout.guests} Guests',
                      ),
                      const SizedBox(height: 10),
                      _SummaryRow(
                        icon: Icons.bed_outlined,
                        label: 'Rooms',
                        value: '${checkout.roomCount} Room${checkout.roomCount > 1 ? 's' : ''}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Price Breakdown ───────────────────────────────────────
                _SectionCard(
                  title: 'Price Breakdown',
                  child: Column(
                    children: [
                      _PriceRow(
                        label:
                            '₹${room.pricePerNight.toStringAsFixed(0)} × ${checkout.roomCount} room${checkout.roomCount > 1 ? 's' : ''} × ${checkout.nights} night${checkout.nights > 1 ? 's' : ''}',
                        value: '₹${checkout.basePrice.toStringAsFixed(0)}',
                      ),
                      const SizedBox(height: 8),
                      _PriceRow(
                        label: 'Taxes & Fees (12%)',
                        value: '₹${checkout.taxes.toStringAsFixed(0)}',
                      ),
                      const Divider(height: 20, color: Color(0xFFEEEEEE)),
                      _PriceRow(
                        label: 'Total Amount',
                        value: '₹${checkout.total.toStringAsFixed(0)}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ],

              if (_step == 1) ...[
                // ── Booking Summary (compact) ─────────────────────────────
                _SectionCard(
                  title: 'Booking Summary',
                  child: Column(
                    children: [
                      _SummaryRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Check-in',
                          value: checkout.checkIn != null
                              ? _fmtDate(checkout.checkIn!)
                              : '--'),
                      const SizedBox(height: 10),
                      _SummaryRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Check-out',
                          value: checkout.checkOut != null
                              ? _fmtDate(checkout.checkOut!)
                              : '--'),
                      const SizedBox(height: 10),
                      _SummaryRow(
                          icon: Icons.access_time_outlined,
                          label: 'Duration',
                          value: '${checkout.nights} Night${checkout.nights > 1 ? 's' : ''}'),
                      const SizedBox(height: 10),
                      _SummaryRow(
                          icon: Icons.person_outline,
                          label: 'Guests',
                          value: '${checkout.guests} Guests'),
                      const SizedBox(height: 10),
                      _SummaryRow(
                          icon: Icons.bed_outlined,
                          label: 'Rooms',
                          value: '${checkout.roomCount} Room${checkout.roomCount > 1 ? 's' : ''}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Guest Details form ────────────────────────────────────
                _SectionCard(
                  title: 'Guest Details',
                  child: Column(
                    children: [
                      _FormField(
                        hint: 'Your full name',
                        icon: Icons.person_outline,
                        focusNode: _nameFocus,
                        onChanged: ctrl.setGuestName,
                        initialValue: checkout.guestName,
                      ),
                      const SizedBox(height: 12),
                      _FormField(
                        hint: 'Your email address',
                        icon: Icons.email_outlined,
                        focusNode: _emailFocus,
                        onChanged: ctrl.setGuestEmail,
                        initialValue: checkout.guestEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),
                      _FormField(
                        hint: 'Enter your phone number',
                        icon: Icons.phone_outlined,
                        focusNode: _phoneFocus,
                        onChanged: ctrl.setGuestPhone,
                        initialValue: checkout.guestPhone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      // Special Requests
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color(0xFFE5E7EB)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          focusNode: _requestsFocus,
                          onChanged: ctrl.setSpecialRequests,
                          controller: TextEditingController(
                              text: checkout.specialRequests),
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText:
                                'Any special requirements or preferences...',
                            hintStyle: TextStyle(
                                fontSize: 13, color: Color(0xFF9CA3AF)),
                            contentPadding: EdgeInsets.all(14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text('0/500',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Cancellation policy ───────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFFBBF24)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Color(0xFFD97706)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Free cancellation up to 24 hours before check-in. After that, 50% of the total amount will be charged.',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF92400E),
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Payment Summary ───────────────────────────────────────
                _SectionCard(
                  title: 'Payment Summary',
                  child: Column(
                    children: [
                      _PriceRow(
                          label: 'Room charges',
                          value:
                              '₹${checkout.basePrice.toStringAsFixed(0)}'),
                      const SizedBox(height: 8),
                      _PriceRow(
                          label: 'Taxes & Fees (12%)',
                          value:
                              '₹${checkout.taxes.toStringAsFixed(0)}'),
                      const Divider(height: 20, color: Color(0xFFEEEEEE)),
                      _PriceRow(
                        label: 'Total Amount',
                        value: '₹${checkout.total.toStringAsFixed(0)}',
                        isBold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          // ── Bottom bar ────────────────────────────────────────────────────
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Amount',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF9CA3AF))),
                      Text(
                        '₹${checkout.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E1B4B), Color(0xFF7C3AED)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (_step == 0) {
                            setState(() => _step = 1);
                          } else {
                            context.push(
                                '/booking/properties/${widget.propertyId}/payment');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Proceed to Checkout',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}

// ── Property card (compact, at top of checkout) ───────────────────────────────

class _PropertyCard extends StatelessWidget {
  final dynamic property;
  final String roomName;
  const _PropertyCard({required this.property, required this.roomName});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                property.primaryImage,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 70,
                  height: 70,
                  color: const Color(0xFFEDE9FF),
                  child: const Icon(Icons.apartment_outlined,
                      color: Color(0xFF7C3AED), size: 30),
                ),
              ),
            ),
            const SizedBox(width: 12),
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
                      property.type == 'dharamshala'
                          ? 'Dharamshala'
                          : 'Hotel',
                      style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1D4ED8)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 12, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 2),
                      Text(roomName,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
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

// ── Summary row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SummaryRow(
      {required this.icon, required this.label, required this.value});

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
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827))),
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
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: isBold ? 14 : 13,
                    fontWeight:
                        isBold ? FontWeight.w700 : FontWeight.w400,
                    color: isBold
                        ? const Color(0xFF111827)
                        : const Color(0xFF6B7280))),
          ),
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

// ── Counter button ────────────────────────────────────────────────────────────

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _CounterBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: onTap != null
                ? const Color(0xFFEDE9FF)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              size: 16,
              color: onTap != null
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFFD1D5DB)),
        ),
      );
}

// ── Form field ────────────────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final String initialValue;
  final TextInputType keyboardType;

  const _FormField({
    required this.hint,
    required this.icon,
    required this.focusNode,
    required this.onChanged,
    required this.initialValue,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          focusNode: focusNode,
          onChanged: onChanged,
          controller:
              TextEditingController(text: initialValue),
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                fontSize: 13, color: Color(0xFF9CA3AF)),
            prefixIcon:
                Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
}

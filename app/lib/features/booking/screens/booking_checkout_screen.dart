import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../models/property.dart';
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
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _requests;

  @override
  void initState() {
    super.initState();
    final c = ref.read(checkoutControllerProvider);
    _name = TextEditingController(text: c.guestName);
    _email = TextEditingController(text: c.guestEmail);
    _phone = TextEditingController(text: c.guestPhone);
    _requests = TextEditingController(text: c.specialRequests);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _requests.dispose();
    super.dispose();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/booking/properties/${widget.propertyId}');
    }
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
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
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
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Color(0xFF211E1E), size: 22),
              onPressed: _back,
            ),
            title: const Text(
              'Checkout',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF211E1E),
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // ── Booking Summary section ───────────────────────────
              const _SectionTitle('Booking Summary'),
              const SizedBox(height: 12),
              _BookingSummaryCard(
                property: property,
                room: room,
                checkout: checkout,
                roomCount: checkout.roomCount,
                onIncRoom: checkout.roomCount < room.availableRooms
                    ? () => ctrl.setRoomCount(checkout.roomCount + 1)
                    : null,
                onDecRoom: checkout.roomCount > 1
                    ? () => ctrl.setRoomCount(checkout.roomCount - 1)
                    : null,
              ),
              const SizedBox(height: 24),

              // ── Guest Details section ─────────────────────────────
              const _SectionTitle('Guest Details'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFE0E2E5)),
                ),
                child: Column(
                  children: [
                    _LabeledField(
                      label: 'Full Name',
                      child: TextField(
                        controller: _name,
                        onChanged: ctrl.setGuestName,
                        decoration: _decoration(
                          hint: 'Your full name',
                          icon: Icons.person_outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Email',
                      child: TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: ctrl.setGuestEmail,
                        decoration: _decoration(
                          hint: 'priya@example.com',
                          icon: Icons.mail_outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Mobile Number',
                      child: TextField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        onChanged: ctrl.setGuestPhone,
                        decoration: _decoration(
                          hint: 'Enter your phone number',
                          icon: Icons.phone_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LabeledField(
                      label: 'Special Requests (Optional)',
                      child: TextField(
                        controller: _requests,
                        onChanged: ctrl.setSpecialRequests,
                        maxLines: 4,
                        maxLength: 500,
                        buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            maxLength}) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '$currentLength/${maxLength ?? 500} characters',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF9EA1A8),
                              ),
                            ),
                          );
                        },
                        decoration: InputDecoration(
                          hintText:
                              'Any special requirements or preferences...',
                          hintStyle: const TextStyle(
                              fontSize: 12, color: Color(0xFF9EA1A8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: Color(0xFFAAB2BC)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                const BorderSide(color: AppColors.accent),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Cancellation policy notice ────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFEE685)),
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
                            color: Color(0xFF4A5565),
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Price Breakdown ───────────────────────────────────
              const _SectionTitle('Price Breakdown'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFE0E2E5)),
                ),
                child: Column(
                  children: [
                    _PriceRow(
                      label:
                          '₹${room.pricePerNight.toStringAsFixed(0)} × ${checkout.roomCount} room${checkout.roomCount > 1 ? 's' : ''} × ${checkout.nights} night${checkout.nights > 1 ? 's' : ''}',
                      value: '₹${checkout.basePrice.toStringAsFixed(0)}',
                    ),
                    const SizedBox(height: 16),
                    _PriceRow(
                      label: 'Taxes & Fees (12%)',
                      value: '₹${checkout.taxes.toStringAsFixed(0)}',
                    ),
                    const Divider(height: 28, color: Color(0xFFE6E9F0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF101828),
                          ),
                        ),
                        Text(
                          '₹${checkout.total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Sticky bottom ──────────────────────────────────────────
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
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6A7282),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '₹${checkout.total.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.accent, AppColors.accent.withValues(alpha: 0.8)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () => context.push(
                            '/booking/properties/${widget.propertyId}/payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
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

  static InputDecoration _decoration({required String hint, required IconData icon}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9EA1A8)),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9EA1A8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFAAB2BC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      );
}

// ── Section title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF101828),
        ),
      );
}

// ── Booking Summary card (property + dates + room counter) ──────────────────

class _BookingSummaryCard extends StatelessWidget {
  final dynamic property;
  final RoomType room;
  final CheckoutState checkout;
  final int roomCount;
  final VoidCallback? onIncRoom;
  final VoidCallback? onDecRoom;

  const _BookingSummaryCard({
    required this.property,
    required this.room,
    required this.checkout,
    required this.roomCount,
    required this.onIncRoom,
    required this.onDecRoom,
  });

  String _fmtDate(DateTime d) {
    const months = [
      '',
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF2FF), Color(0xFFF9F4FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFF0E5FF), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  property.primaryImage,
                  width: 95,
                  height: 92,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    width: 95,
                    height: 92,
                    color: const Color(0xFFEDE9FF),
                    child: const Icon(Icons.apartment_outlined,
                        size: 32, color: AppColors.accent),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6E5FB),
                        borderRadius: BorderRadius.circular(10000),
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
                    const SizedBox(height: 8),
                    Text(
                      property.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF101828),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4A5565),
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
          const SizedBox(height: 16),

          // Inner white card with date rows
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Check-in',
                  value: checkout.checkIn != null
                      ? _fmtDate(checkout.checkIn!)
                      : 'Not selected',
                ),
                const SizedBox(height: 16),
                _SummaryRow(
                  label: 'Check-out',
                  value: checkout.checkOut != null
                      ? _fmtDate(checkout.checkOut!)
                      : 'Not selected',
                ),
                const SizedBox(height: 16),
                _SummaryRow(
                  label: 'Duration',
                  value: checkout.nights > 0
                      ? '${checkout.nights} Night${checkout.nights > 1 ? 's' : ''}'
                      : '--',
                ),
                const SizedBox(height: 16),
                _SummaryRow(
                  label: 'Guests',
                  value:
                      '${checkout.guests} Guest${checkout.guests > 1 ? 's' : ''}',
                ),
                const SizedBox(height: 16),
                _SummaryRow(
                  label: 'Rooms',
                  value: '$roomCount ${room.name}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Room availability + counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available rooms: ${room.availableRooms}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5565),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Number of rooms',
                        style: TextStyle(
                          fontSize: 14,
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
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$roomCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF101828),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _StepBtn(
                      icon: Icons.add,
                      onTap: onIncRoom,
                      highlight: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF4A5565))),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101828))),
        ],
      );
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF4A5565),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828),
            ),
          ),
        ],
      );
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF121A2C),
              )),
          const SizedBox(height: 4),
          child,
        ],
      );
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
        width: 36,
        height: 36,
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
          size: 18,
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

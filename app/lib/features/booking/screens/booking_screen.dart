import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/booking_controller.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  static const _purple = Color(0xFF7C3AED);

  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 2;
  int _rooms = 1;

  String _fmtDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd-$mm-${d.year}';
  }

  Future<void> _pickDate(bool isCheckIn) async {
    final now = DateTime.now();
    final firstDate = isCheckIn ? now : (_checkIn ?? now).add(const Duration(days: 1));
    final initialDate = isCheckIn
        ? (_checkIn ?? now)
        : (_checkOut ?? firstDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: _purple),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckIn) {
        _checkIn = picked;
        if (_checkOut != null && !_checkOut!.isAfter(picked)) {
          _checkOut = picked.add(const Duration(days: 1));
        }
      } else {
        _checkOut = picked;
      }
    });
  }

  void _showGuestPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _GuestRoomPicker(
        guests: _guests,
        rooms: _rooms,
        onChanged: (g, r) => setState(() {
          _guests = g;
          _rooms = r;
        }),
      ),
    );
  }

  void _search() {
    // Store dates/guests in checkout state so they're available downstream
    if (_checkIn != null && _checkOut != null) {
      ref.read(checkoutControllerProvider.notifier).setDates(_checkIn!, _checkOut!);
      ref.read(checkoutControllerProvider.notifier).setGuests(_guests);
      ref.read(checkoutControllerProvider.notifier).setRoomCount(_rooms);
    }
    context.push('/booking/properties');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Book Accommodation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero image section ──────────────────────────────────────────
            Stack(
              children: [
                SizedBox(
                  height: 360,
                  width: double.infinity,
                  child: Image.network(
                    'https://images.unsplash.com/photo-1596178065887-1198b6148b2b?w=800',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: const Color(0xFF2D1B69),
                    ),
                  ),
                ),
                // Dark gradient overlay
                Container(
                  height: 360,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.black.withValues(alpha: 0.25),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ── Search card ─────────────────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -60),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search field
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'Search location, hotel, dharamshala...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF),
                            ),
                            prefixIcon: Icon(Icons.search,
                                size: 20, color: Color(0xFF9CA3AF)),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Check-in / Check-out
                      Row(
                        children: [
                          Expanded(
                            child: _DateField(
                              label: 'Check-in',
                              value: _checkIn != null
                                  ? _fmtDate(_checkIn!)
                                  : null,
                              onTap: () => _pickDate(true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DateField(
                              label: 'Check-out',
                              value: _checkOut != null
                                  ? _fmtDate(_checkOut!)
                                  : null,
                              onTap: () => _pickDate(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Guests & Rooms selector
                      GestureDetector(
                        onTap: _showGuestPicker,
                        child: Container(
                          height: 50,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.person_outline,
                                  size: 20, color: _purple),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '$_guests Guests, $_rooms Room${_rooms > 1 ? 's' : ''}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF374151),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const Icon(Icons.keyboard_arrow_down,
                                  size: 20, color: Color(0xFF9CA3AF)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search Properties button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
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
                            onPressed: _search,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text(
                              'Search Properties',
                              style: TextStyle(
                                fontSize: 15,
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
            ),

            // ── What are you looking for ────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -44),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What are you looking for?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF121A2C),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _CategoryTile(
                              icon: Icons.apartment_outlined,
                              title: 'Hotels',
                              subtitle: 'Premium stays with modern amenities',
                              onTap: () {
                                ref
                                    .read(propertiesControllerProvider.notifier)
                                    .selectType('Hotels');
                                context.push('/booking/properties');
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CategoryTile(
                              icon: Icons.temple_hindu_outlined,
                              title: 'Dharamshalas',
                              subtitle: 'Spiritual stays near temples',
                              onTap: () {
                                ref
                                    .read(propertiesControllerProvider.notifier)
                                    .selectType('Dharamshala');
                                context.push('/booking/properties');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Date field ────────────────────────────────────────────────────────────────

class _DateField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9CA3AF)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value ?? 'dd-mm-yyyy',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: value != null
                            ? const Color(0xFF111827)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.calendar_month_outlined,
                  size: 18, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      );
}

// ── Category tile ─────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F0FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28, color: const Color(0xFF7C3AED)),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121A2C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Guest & Room picker bottom sheet ─────────────────────────────────────────

class _GuestRoomPicker extends StatefulWidget {
  final int guests;
  final int rooms;
  final void Function(int guests, int rooms) onChanged;

  const _GuestRoomPicker({
    required this.guests,
    required this.rooms,
    required this.onChanged,
  });

  @override
  State<_GuestRoomPicker> createState() => _GuestRoomPickerState();
}

class _GuestRoomPickerState extends State<_GuestRoomPicker> {
  late int _guests;
  late int _rooms;

  @override
  void initState() {
    super.initState();
    _guests = widget.guests;
    _rooms = widget.rooms;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Select Guests & Rooms',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121A2C))),
          const SizedBox(height: 24),
          _CounterRow(
            label: 'Guests',
            value: _guests,
            onDecrease: _guests > 1 ? () => setState(() => _guests--) : null,
            onIncrease: _guests < 10 ? () => setState(() => _guests++) : null,
          ),
          const SizedBox(height: 16),
          _CounterRow(
            label: 'Rooms',
            value: _rooms,
            onDecrease: _rooms > 1 ? () => setState(() => _rooms--) : null,
            onIncrease: _rooms < 5 ? () => setState(() => _rooms++) : null,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onChanged(_guests, _rooms);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Done',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterRow extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  const _CounterRow({
    required this.label,
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151))),
          ),
          _Btn(icon: Icons.remove, onTap: onDecrease),
          SizedBox(
            width: 40,
            child: Text('$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827))),
          ),
          _Btn(icon: Icons.add, onTap: onIncrease),
        ],
      );
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _Btn({required this.icon, required this.onTap});

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

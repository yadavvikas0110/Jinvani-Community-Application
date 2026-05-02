import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../state/booking_controller.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

enum _Section { none, guests, propertyType }

enum _PropertyType { hotel, dharamshala, both }

class _BookingScreenState extends ConsumerState<BookingScreen> {
  static const _purple = AppColors.accent;

  final _locationCtrl = TextEditingController();
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _adults = 0;
  int _children = 0;
  _PropertyType? _propertyType;
  _Section _open = _Section.none;

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

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

  void _toggle(_Section s) {
    setState(() => _open = _open == s ? _Section.none : s);
  }

  void _search() {
    final guests = _adults + _children;
    if (_checkIn != null && _checkOut != null) {
      ref.read(checkoutControllerProvider.notifier).setDates(_checkIn!, _checkOut!);
      ref.read(checkoutControllerProvider.notifier).setGuests(guests > 0 ? guests : 1);
    }
    final typeFilter = switch (_propertyType) {
      _PropertyType.hotel => 'Hotels',
      _PropertyType.dharamshala => 'Dharamshala',
      _PropertyType.both => 'All',
      null => 'All',
    };
    ref.read(propertiesControllerProvider.notifier).selectType(typeFilter);
    context.push('/booking/properties');
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final guestsLabel = switch (_adults + _children) {
      0 => 'Choose guests',
      final n => '$n Guest${n > 1 ? 's' : ''}',
    };
    final typeLabel = switch (_propertyType) {
      _PropertyType.hotel => 'Hotel',
      _PropertyType.dharamshala => 'Dharamshala',
      _PropertyType.both => 'Both',
      null => 'Choose property type',
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
          onPressed: _back,
        ),
        title: const Text(
          'Book Accommodation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Hero image with overlay ───────────────────────────────
            SizedBox(
              height: 340,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://images.unsplash.com/photo-1596178065887-1198b6148b2b?w=800',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: const Color(0xFF2D1B69)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.black.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Foreground Content ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 240, left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location search
                        _BorderedField(
                          leading: const Icon(Icons.search, size: 20, color: Color(0xFF6B7280)),
                          child: TextField(
                            controller: _locationCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Search location, hotel, dharamshala...',
                              hintStyle: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Check-in / Check-out
                        Row(
                          children: [
                            Expanded(
                              child: _DateFieldLabeled(
                                label: 'Check-in',
                                value: _checkIn != null ? _fmtDate(_checkIn!) : null,
                                onTap: () => _pickDate(true),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _DateFieldLabeled(
                                label: 'Check-in', // Matches Figma explicitly
                                value: _checkOut != null ? _fmtDate(_checkOut!) : null,
                                onTap: () => _pickDate(false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Guests collapsible
                        _CollapsibleField(
                          leadingIcon: Icons.person_outline,
                          label: guestsLabel,
                          labelColor: (_adults + _children) > 0 ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                          expanded: _open == _Section.guests,
                          onTap: () => _toggle(_Section.guests),
                          body: Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Column(
                              children: [
                                _GuestRow(
                                  label: 'Adults',
                                  value: _adults,
                                  onDec: _adults > 0 ? () => setState(() => _adults--) : null,
                                  onInc: _adults < 10 ? () => setState(() => _adults++) : null,
                                ),
                                const SizedBox(height: 16),
                                _GuestRow(
                                  label: 'Children',
                                  value: _children,
                                  onDec: _children > 0 ? () => setState(() => _children--) : null,
                                  onInc: _children < 10 ? () => setState(() => _children++) : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Property type collapsible
                        _CollapsibleField(
                          leadingIcon: Icons.apartment_outlined,
                          label: typeLabel,
                          labelColor: _propertyType != null ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                          expanded: _open == _Section.propertyType,
                          onTap: () => _toggle(_Section.propertyType),
                          body: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              children: [
                                _RadioRow(
                                  label: 'Hotel',
                                  selected: _propertyType == _PropertyType.hotel,
                                  onTap: () => setState(() => _propertyType = _PropertyType.hotel),
                                ),
                                _RadioRow(
                                  label: 'Dharamshala',
                                  selected: _propertyType == _PropertyType.dharamshala,
                                  onTap: () => setState(() => _propertyType = _PropertyType.dharamshala),
                                ),
                                _RadioRow(
                                  label: 'Both',
                                  selected: _propertyType == _PropertyType.both,
                                  onTap: () => setState(() => _propertyType = _PropertyType.both),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Search Properties button
                        SizedBox(
                          width: double.infinity,
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
                              onPressed: _search,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text(
                                'Search Properties',
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
                  const SizedBox(height: 32),

                  // ── What are you looking for? ─────────────────────────────
                  const Text(
                    'What are you looking for?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _CategoryTile(
                          icon: Icons.apartment_outlined,
                          title: 'Hotels',
                          subtitle: 'Premium stays with\nmodern amenities',
                          onTap: () {
                            ref.read(propertiesControllerProvider.notifier).selectType('Hotels');
                            context.push('/booking/properties');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _CategoryTile(
                          icon: Icons.temple_hindu_outlined,
                          title: 'Dharamshalas',
                          subtitle: 'Spiritual stays near\ntemples',
                          onTap: () {
                            ref.read(propertiesControllerProvider.notifier).selectType('Dharamshala');
                            context.push('/booking/properties');
                          },
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
}

// ── Bordered field shell ─────────────────────────────────────────────────────

class _BorderedField extends StatelessWidget {
  final Widget? leading;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onTap;
  
  const _BorderedField({
    this.leading,
    required this.child,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 12),
          ],
          Expanded(child: child),
          ?trailing,
        ],
      ),
    );
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}

// ── Date field with floating label ───────────────────────────────────────────

class _DateFieldLabeled extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  
  const _DateFieldLabeled({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          _BorderedField(
            onTap: onTap,
            trailing: const Icon(Icons.calendar_month_outlined, size: 20, color: Color(0xFF9CA3AF)),
            child: Text(
              value ?? 'dd-mm-yyyy',
              style: TextStyle(
                fontSize: 13,
                color: value != null ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      );
}

// ── Collapsible field ────────────────────────────────────────────────────────

class _CollapsibleField extends StatelessWidget {
  final IconData leadingIcon;
  final String label;
  final Color labelColor;
  final bool expanded;
  final VoidCallback onTap;
  final Widget body;

  const _CollapsibleField({
    required this.leadingIcon,
    required this.label,
    required this.labelColor,
    required this.expanded,
    required this.onTap,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: Row(
                children: [
                  Icon(leadingIcon, size: 20, color: const Color(0xFF6B7280)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: labelColor,
                      ),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 20,
                    color: const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: body,
            ),
        ],
      ),
    );
  }
}

// ── Guest counter row ────────────────────────────────────────────────────────

class _GuestRow extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback? onDec;
  final VoidCallback? onInc;
  
  const _GuestRow({
    required this.label,
    required this.value,
    required this.onDec,
    required this.onInc,
  });

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
            ),
          ),
          _CounterBtn(icon: Icons.remove, onTap: onDec, highlight: false),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
          _CounterBtn(icon: Icons.add, onTap: onInc, highlight: true),
        ],
      );
}

class _CounterBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool highlight;
  
  const _CounterBtn({
    required this.icon,
    required this.onTap,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: highlight && enabled ? AppColors.accent : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: highlight && enabled ? AppColors.accent : const Color(0xFFE5E7EB),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: highlight && enabled 
              ? Colors.white 
              : (enabled ? const Color(0xFF6B7280) : const Color(0xFFD1D5DB)),
        ),
      ),
    );
  }
}

// ── Radio row (property type) ────────────────────────────────────────────────

class _RadioRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  
  const _RadioRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.accent : const Color(0xFFD1D5DB),
                    width: 1.5,
                  ),
                ),
                child: selected 
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
              ),
            ],
          ),
        ),
      );
}

// ── Category tile ────────────────────────────────────────────────────────────

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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.accent),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
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

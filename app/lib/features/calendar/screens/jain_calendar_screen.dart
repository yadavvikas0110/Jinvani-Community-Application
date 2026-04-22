import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/jain_festival.dart';
import '../state/calendar_controller.dart';

class JainCalendarScreen extends ConsumerWidget {
  const JainCalendarScreen({super.key});

  static const _purple = Color(0xFF7C3AED);

  static const _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state          = ref.watch(calendarControllerProvider);
    final ctrl           = ref.read(calendarControllerProvider.notifier);
    final festivalDays   = ref.watch(festivalDaysProvider);
    final selectedFests  = ref.watch(selectedDateFestivalsProvider);
    final upcoming       = ref.watch(upcomingFestivalsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Jain Calendar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121A2C),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Section header ─────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Calendar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121A2C),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Sacred festivals & dates',
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Calendar card ──────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Month header
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: ctrl.previousMonth,
                        icon: const Icon(Icons.chevron_left,
                            color: _purple, size: 24),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Expanded(
                        child: Text(
                          '${_monthNames[state.month]} ${state.year}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF121A2C),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: ctrl.nextMonth,
                        icon: const Icon(Icons.chevron_right,
                            color: _purple, size: 24),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Day labels
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .map((d) => Expanded(
                              child: Center(
                                child: Text(
                                  d,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 4),

                // Calendar grid
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                  child: _CalendarGrid(
                    year: state.year,
                    month: state.month,
                    selectedDate: state.selectedDate,
                    festivalDays: festivalDays,
                    today: DateTime.now(),
                    onDateTap: ctrl.selectDate,
                  ),
                ),
              ],
            ),
          ),

          // ── Selected festival card ─────────────────────────────────────
          if (selectedFests.isNotEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SelectedFestivalCard(festival: selectedFests.first),
            ),
          ],

          const SizedBox(height: 24),

          // ── Upcoming Jain Festivals ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Upcoming Jain Festivals',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF121A2C),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF395A91),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          ...upcoming.map((f) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _FestivalListItem(festival: f),
              )),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Calendar grid ─────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final int year;
  final int month;
  final DateTime? selectedDate;
  final Set<int> festivalDays;
  final DateTime today;
  final ValueChanged<DateTime> onDateTap;

  const _CalendarGrid({
    required this.year,
    required this.month,
    required this.selectedDate,
    required this.festivalDays,
    required this.today,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7; // 0 = Sunday

    final cells = <Widget>[];

    // Leading empty cells
    for (int i = 0; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final isToday = today.year == year &&
          today.month == month &&
          today.day == day;
      final isSelected = selectedDate?.year == year &&
          selectedDate?.month == month &&
          selectedDate?.day == day;
      final hasFestival = festivalDays.contains(day);

      cells.add(_DayCell(
        day: day,
        isToday: isToday,
        isSelected: isSelected,
        hasFestival: hasFestival,
        onTap: () => onDateTap(date),
      ));
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isSelected;
  final bool hasFestival;
  final VoidCallback onTap;

  static const _purple      = Color(0xFF7C3AED);
  static const _orange      = Color(0xFFFF8C00);

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.hasFestival,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final highlighted = isSelected || isToday;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? _purple
                    : isToday
                        ? _purple.withValues(alpha: 0.12)
                        : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: highlighted ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? _purple
                          : const Color(0xFF374151),
                ),
              ),
            ),
            if (hasFestival)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: _orange,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 7),
          ],
        ),
      ),
    );
  }
}

// ── Selected festival detail card ─────────────────────────────────────────────

class _SelectedFestivalCard extends StatelessWidget {
  final JainFestival festival;
  const _SelectedFestivalCard({required this.festival});

  static const _purple = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    final days = festival.daysLeft();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  festival.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _purple,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  days == 0
                      ? 'Today!'
                      : days > 0
                          ? '$days days left'
                          : '${-days} days ago',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            festival.description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF4C4A53),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Festival list item ────────────────────────────────────────────────────────

class _FestivalListItem extends StatelessWidget {
  final JainFestival festival;
  const _FestivalListItem({required this.festival});

  static const _orangeBg = Color(0xFFFFF3E0);

  @override
  Widget build(BuildContext context) {
    final days = festival.daysLeft();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Diya icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _orangeBg,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🪔', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  festival.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF121A2C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(festival.date),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: days == 0
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFF3F0FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              days == 0
                  ? 'Today!'
                  : days > 0
                      ? '$days days left'
                      : '${-days}d ago',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: days == 0
                    ? const Color(0xFF059669)
                    : const Color(0xFF7C3AED),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${d.day} ${months[d.month]} ${d.year}';
  }
}

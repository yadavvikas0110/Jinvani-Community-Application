import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/calendar_repository.dart';
import '../models/jain_festival.dart';

class CalendarState {
  final int year;
  final int month;
  final DateTime? selectedDate;

  const CalendarState({
    required this.year,
    required this.month,
    this.selectedDate,
  });

  CalendarState copyWith({int? year, int? month, DateTime? selectedDate, bool clearSelected = false}) =>
      CalendarState(
        year: year ?? this.year,
        month: month ?? this.month,
        selectedDate: clearSelected ? null : (selectedDate ?? this.selectedDate),
      );
}

class CalendarController extends Notifier<CalendarState> {
  @override
  CalendarState build() {
    final now = DateTime.now();
    return CalendarState(year: now.year, month: now.month);
  }

  void previousMonth() {
    int m = state.month - 1;
    int y = state.year;
    if (m < 1) { m = 12; y--; }
    state = state.copyWith(year: y, month: m, clearSelected: true);
  }

  void nextMonth() {
    int m = state.month + 1;
    int y = state.year;
    if (m > 12) { m = 1; y++; }
    state = state.copyWith(year: y, month: m, clearSelected: true);
  }

  void selectDate(DateTime date) {
    if (state.selectedDate?.year == date.year &&
        state.selectedDate?.month == date.month &&
        state.selectedDate?.day == date.day) {
      // Deselect on second tap
      state = state.copyWith(clearSelected: true);
    } else {
      state = state.copyWith(selectedDate: date);
    }
  }
}

final calendarControllerProvider =
    NotifierProvider<CalendarController, CalendarState>(CalendarController.new);

// Derived: festival dots for current month
final festivalDaysProvider = Provider<Set<int>>((ref) {
  final s = ref.watch(calendarControllerProvider);
  return ref
      .read(calendarRepositoryProvider)
      .getFestivalDaysInMonth(s.year, s.month);
});

// Derived: festivals on selected date
final selectedDateFestivalsProvider = Provider<List<JainFestival>>((ref) {
  final s = ref.watch(calendarControllerProvider);
  if (s.selectedDate == null) return [];
  return ref
      .read(calendarRepositoryProvider)
      .getFestivalsOnDate(s.selectedDate!);
});

// Upcoming festivals list
final upcomingFestivalsProvider = Provider<List<JainFestival>>((ref) {
  return ref.read(calendarRepositoryProvider).getUpcomingFestivalsList();
});

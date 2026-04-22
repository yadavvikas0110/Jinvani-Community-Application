import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/jain_festival.dart';

class CalendarRepository {
  /// All Jain festivals (2025 + 2026 dates)
  static final List<JainFestival> _festivals = [
    // ── 2025 ──────────────────────────────────────────────────────────────────
    JainFestival(
      id: 'mahavir_2025',
      name: 'Mahavir Jayanti',
      date: DateTime(2025, 4, 10),
      description:
          'Birth anniversary of Lord Mahavira, the 24th Tirthankara. Celebrated with processions, prayers, and charitable activities.',
      significance: 'Birthday of Lord Mahavira',
    ),
    JainFestival(
      id: 'akshaya_2025',
      name: 'Akshaya Tritiya',
      date: DateTime(2025, 4, 30),
      description:
          'An auspicious day marking the beginning of the Treta Yuga. Jains observe fasting and perform charitable deeds on this day.',
      significance: 'Auspicious day for charity & fasting',
    ),
    JainFestival(
      id: 'paryushana_2025',
      name: 'Paryushana Parv',
      date: DateTime(2025, 8, 20),
      description:
          'The most important festival for Jains, lasting 8 days (Shvetambara) or 10 days (Digambara). A period of intense fasting, prayer, and forgiveness.',
      significance: 'Festival of forgiveness & penance',
    ),
    JainFestival(
      id: 'samvatsari_2025',
      name: 'Samvatsari',
      date: DateTime(2025, 8, 27),
      description:
          'The last day of Paryushana. Jains ask forgiveness from all living beings by saying "Micchami Dukkadam".',
      significance: 'Day of seeking universal forgiveness',
    ),
    JainFestival(
      id: 'das_lakshana_2025',
      name: 'Das Lakshana',
      date: DateTime(2025, 8, 28),
      description:
          'A 10-day Digambara Jain festival celebrating the ten supreme virtues: forgiveness, humility, simplicity, contentment, truth, restraint, penance, renunciation, non-attachment, and celibacy.',
      significance: 'Ten-day celebration of supreme virtues',
    ),
    JainFestival(
      id: 'gyaan_panchami_2025',
      name: 'Gyaan Panchami',
      date: DateTime(2025, 10, 28),
      description:
          'A day devoted to knowledge and learning. Jains worship sacred scriptures and books, seeking blessings of wisdom.',
      significance: 'Day of worship of knowledge & scriptures',
    ),
    JainFestival(
      id: 'diwali_2025',
      name: 'Diwali (Deepawali)',
      date: DateTime(2025, 10, 20),
      description:
          'Marks the Nirvana (liberation) of Lord Mahavira. Jains celebrate by lighting lamps, offering prayers, and performing Lakshmi Puja.',
      significance: 'Nirvana of Lord Mahavira',
    ),
    JainFestival(
      id: 'kartiki_2025',
      name: 'Kartiki Poonam',
      date: DateTime(2025, 11, 5),
      description:
          'Full moon day in the month of Kartik. Pilgrims undertake holy yatras to Jain pilgrimage sites on this auspicious day.',
      significance: 'Auspicious full moon pilgrimage day',
    ),

    // ── 2026 ──────────────────────────────────────────────────────────────────
    JainFestival(
      id: 'mahavir_2026',
      name: 'Mahavir Jayanti',
      date: DateTime(2026, 4, 17),
      description:
          'Birth anniversary of Lord Mahavira, the 24th Tirthankara. Celebrated with processions, prayers, and charitable activities.',
      significance: 'Birthday of Lord Mahavira',
    ),
    JainFestival(
      id: 'akshaya_2026',
      name: 'Akshaya Tritiya',
      date: DateTime(2026, 5, 10),
      description:
          'An auspicious day marking the beginning of the Treta Yuga. Jains observe fasting and perform charitable deeds on this day.',
      significance: 'Auspicious day for charity & fasting',
    ),
    JainFestival(
      id: 'paryushana_2026',
      name: 'Paryushana Parv',
      date: DateTime(2026, 8, 29),
      description:
          'The most important festival for Jains, lasting 8 days (Shvetambara) or 10 days (Digambara). A period of intense fasting, prayer, and forgiveness.',
      significance: 'Festival of forgiveness & penance',
    ),
    JainFestival(
      id: 'samvatsari_2026',
      name: 'Samvatsari',
      date: DateTime(2026, 9, 5),
      description:
          'The last day of Paryushana. Jains ask forgiveness from all living beings by saying "Micchami Dukkadam".',
      significance: 'Day of seeking universal forgiveness',
    ),
    JainFestival(
      id: 'das_lakshana_2026',
      name: 'Das Lakshana',
      date: DateTime(2026, 9, 6),
      description:
          'A 10-day Digambara Jain festival celebrating the ten supreme virtues.',
      significance: 'Ten-day celebration of supreme virtues',
    ),
    JainFestival(
      id: 'diwali_2026',
      name: 'Diwali (Deepawali)',
      date: DateTime(2026, 10, 29),
      description:
          'Marks the Nirvana (liberation) of Lord Mahavira. Jains celebrate by lighting lamps, offering prayers, and performing Lakshmi Puja.',
      significance: 'Nirvana of Lord Mahavira',
    ),
    JainFestival(
      id: 'gyaan_panchami_2026',
      name: 'Gyaan Panchami',
      date: DateTime(2026, 11, 15),
      description:
          'A day devoted to knowledge and learning. Jains worship sacred scriptures and books, seeking blessings of wisdom.',
      significance: 'Day of worship of knowledge & scriptures',
    ),
    JainFestival(
      id: 'kartiki_2026',
      name: 'Kartiki Poonam',
      date: DateTime(2026, 11, 5),
      description:
          'Full moon day in the month of Kartik. Pilgrims undertake holy yatras to Jain pilgrimage sites on this auspicious day.',
      significance: 'Auspicious full moon pilgrimage day',
    ),
  ];

  /// All festivals sorted by date
  List<JainFestival> getAllFestivals() {
    final list = List<JainFestival>.from(_festivals);
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<JainFestival> getUpcomingFestivalsList({int limit = 20}) {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final result = _festivals
        .where((f) =>
            f.date.isAfter(todayOnly) ||
            f.date.isAtSameMomentAs(todayOnly))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return result.take(limit).toList();
  }

  /// Festivals for a given month
  List<JainFestival> getFestivalsForMonth(int year, int month) {
    return _festivals
        .where((f) => f.date.year == year && f.date.month == month)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Festivals on a specific date
  List<JainFestival> getFestivalsOnDate(DateTime date) {
    return _festivals
        .where((f) =>
            f.date.year == date.year &&
            f.date.month == date.month &&
            f.date.day == date.day)
        .toList();
  }

  /// Set of festival days for a month (for dot markers)
  Set<int> getFestivalDaysInMonth(int year, int month) {
    return _festivals
        .where((f) => f.date.year == year && f.date.month == month)
        .map((f) => f.date.day)
        .toSet();
  }
}

final calendarRepositoryProvider =
    Provider<CalendarRepository>((_) => CalendarRepository());

class JainFestival {
  final String id;
  final String name;
  final DateTime date;
  final String description;
  final String? significance; // short one-liner

  const JainFestival({
    required this.id,
    required this.name,
    required this.date,
    required this.description,
    this.significance,
  });

  /// Days remaining from today (negative = past)
  int daysLeft() => date.difference(_today()).inDays;

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }
}

extension DateTimeExtensions on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  DateTime get startOfWeek {
    final daysSinceMonday = weekday - 1;
    return DateTime(year, month, day - daysSinceMonday);
  }

  DateTime get endOfWeek => startOfWeek
      .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

  DateTime get startOfMonth => DateTime(year, month, 1);

  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);

  DateTime get startOfYear => DateTime(year, 1, 1);

  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59);

  bool isBetween(DateTime start, DateTime end) =>
      isAfter(start) && isBefore(end) ||
      isAtSameMomentAs(start) ||
      isAtSameMomentAs(end);

  List<DateTime> getNextOccurrences({
    required int interval,
    required String frequency,
    DateTime? endDate,
    int maxOccurrences = 100,
  }) {
    final occurrences = <DateTime>[];
    DateTime current = this;
    var count = 0;

    while (count < maxOccurrences) {
      switch (frequency) {
        case 'daily':
          current = current.add(Duration(days: interval));
          break;
        case 'weekly':
          current = current.add(Duration(days: 7 * interval));
          break;
        case 'monthly':
          current =
              DateTime(current.year, current.month + interval, current.day);
          break;
        case 'yearly':
          current =
              DateTime(current.year + interval, current.month, current.day);
          break;
        default:
          current = current.add(Duration(days: interval));
      }

      if (endDate != null && current.isAfter(endDate)) break;
      occurrences.add(current);
      count++;
    }
    return occurrences;
  }
}

import 'package:intl/intl.dart';

class DateTimeFormatter {
  DateTimeFormatter._();

  static String friendly(DateTime dateTime) {
    final now = DateTime.now();
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final today = DateTime(now.year, now.month, now.day);
    final time = DateFormat('h:mm a').format(dateTime);

    final dayDiff = date.difference(today).inDays;
    if (dayDiff == 0) return 'Today, $time';
    if (dayDiff == 1) return 'Tomorrow, $time';
    if (dayDiff == -1) return 'Yesterday, $time';

    return '${DateFormat('MMM d, y').format(dateTime)}, $time';
  }

  /// Calendar-day key (`yyyy-MM-dd`) used to bucket per-day data —
  /// e.g. schedule-item completions — independent of time-of-day.
  static String dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

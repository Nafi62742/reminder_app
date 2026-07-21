import 'package:flutter/material.dart';

/// Converts between [TimeOfDay] and the minutes-since-midnight ints that
/// [ScheduleItemModel] persists, and formats either for display.
class ScheduleTimeFormatter {
  ScheduleTimeFormatter._();

  static int toMinutes(TimeOfDay time) => time.hour * 60 + time.minute;

  static TimeOfDay fromMinutes(int minutes) {
    return TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
  }

  static String format(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
  }

  static String formatMinutes(int minutes) => format(fromMinutes(minutes));
}

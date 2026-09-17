import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

import '../../data/models/reminder_model.dart';

/// Helper service to add reminders to the device's native calendar
/// (Google Calendar on Android, Apple Calendar on iOS) completely offline.
class CalendarService {
  CalendarService._();

  /// Opens the native calendar app pre-populated with reminder details.
  /// Returns true if the native calendar intent was successfully launched.
  static Future<bool> addReminderToCalendar(ReminderModel reminder) async {
    if (reminder.dateTime == null) return false;

    try {
      final startDate = reminder.dateTime!;
      final endDate = startDate.add(const Duration(minutes: 30));

      final event = Event(
        title: reminder.title,
        description: reminder.description ?? '',
        startDate: startDate,
        endDate: endDate,
        iosParams: const IOSParams(
          reminder: Duration(minutes: 0),
        ),
        androidParams: const AndroidParams(
          emailInvites: [],
        ),
      );

      return await Add2Calendar.addEvent2Cal(event);
    } catch (e) {
      debugPrint('Error adding event to calendar: $e');
      return false;
    }
  }
}

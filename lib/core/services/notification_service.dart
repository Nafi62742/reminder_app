import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../data/models/reminder_model.dart';

/// Schedules and cancels local notifications for reminders. All scheduling
/// is on-device — nothing here talks to a network or backend.
class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'reminders_channel',
    'Reminders',
    channelDescription: 'Notifications for scheduled reminders',
    importance: Importance.max,
    priority: Priority.high,
  );

  Future<NotificationService> init() async {
    tz_data.initializeTimeZones();
    _setLocalTimeZone();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    try {
      // Notification setup is best-effort: on a platform where the plugin
      // or a permission channel isn't available (e.g. desktop targets used
      // for local UI testing), this must not stop the app from launching —
      // it would otherwise escape main() before runApp() ever runs.
      await _plugin.initialize(
        const InitializationSettings(
          android: androidInit,
          iOS: darwinInit,
          macOS: darwinInit,
        ),
      );
      await requestPermissions();
    } catch (_) {
      // Reminders just won't produce local notifications on this platform.
    }
    return this;
  }

  // The `timezone` package defaults tz.local to UTC unless told otherwise.
  // Without a native timezone-lookup plugin, approximate the device's zone
  // from its current UTC offset (whole-hour offsets only).
  void _setLocalTimeZone() {
    final offset = DateTime.now().timeZoneOffset;
    final sign = offset.isNegative ? '+' : '-';
    final hours = offset.abs().inHours;
    final name = hours == 0 ? 'UTC' : 'Etc/GMT$sign$hours';
    try {
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> requestPermissions() async {
    // Each request is independently best-effort — one platform channel
    // being unavailable shouldn't skip the others.
    await _tryRequest(() => Permission.notification.request());
    await _tryRequest(() => Permission.scheduleExactAlarm.request());
    await _tryRequest(
      () => _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true),
    );
    await _tryRequest(
      () => _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true),
    );
  }

  Future<void> _tryRequest(Future<dynamic>? Function() request) async {
    try {
      await request();
    } catch (_) {
      // See init() — best-effort, must never block startup.
    }
  }

  Future<void> scheduleReminder(ReminderModel reminder) async {
    await cancelReminder(reminder.id);
    if (reminder.dateTime == null ||
        reminder.isCompleted ||
        reminder.dateTime!.isBefore(DateTime.now())) {
      return;
    }
    await _plugin.zonedSchedule(
      reminder.id,
      reminder.title,
      reminder.description,
      tz.TZDateTime.from(reminder.dateTime!, tz.local),
      const NotificationDetails(
        android: _androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int id) => _plugin.cancel(id);
}

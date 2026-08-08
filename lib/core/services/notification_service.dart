import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../app/routes/app_routes.dart';
import '../../data/models/reminder_model.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../modules/reminders/controllers/reminders_controller.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Action buttons have showsUserInterface: true, so they will launch the app
  // and trigger onDidReceiveNotificationResponse in the main isolate instead.
}

/// Schedules and cancels local notifications for reminders. All scheduling
/// is on-device — nothing here talks to a network or backend.
class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static final AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'reminders_alarm_channel_v2', // New channel ID to register the alarm properties
    'Reminders Alarms',
    channelDescription: 'Alarms for scheduled reminders',
    importance: Importance.max,
    priority: Priority.high,
    largeIcon: const DrawableResourceAndroidBitmap('ic_launcher_foreground'),
    playSound: true,
    sound: const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
    audioAttributesUsage: AudioAttributesUsage.alarm,
    category: AndroidNotificationCategory.alarm,
    fullScreenIntent: true,
    additionalFlags: Int32List.fromList(<int>[4]), // insistent (loop sound until interacted)
    actions: const <AndroidNotificationAction>[
      AndroidNotificationAction(
        'dismiss_action',
        'Dismiss',
        showsUserInterface: true,
      ),
      AndroidNotificationAction(
        'snooze_action',
        'Snooze',
        showsUserInterface: true,
      ),
    ],
  );

  Future<NotificationService> init() async {
    tz_data.initializeTimeZones();
    _setLocalTimeZone();

    const androidInit = AndroidInitializationSettings('ic_launcher_foreground');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    // Notification setup is best-effort
    await _plugin.initialize(
      const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    await requestPermissions();

    // Check if a notification launched the app
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      final payload = launchDetails.notificationResponse?.payload;
      final reminderId = int.tryParse(payload ?? '');
      if (reminderId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.toNamed(AppRoutes.alarmRinging, arguments: reminderId);
        });
      }
    }
    return this;
  }

  void _onNotificationResponse(NotificationResponse details) {
    final payload = details.payload;
    final actionId = details.actionId;
    final reminderId = int.tryParse(payload ?? '');

    if (reminderId == null) return;

    if (actionId == 'dismiss_action') {
      cancelReminder(reminderId);
      final repo = Get.find<ReminderRepository>();
      final all = repo.getAll();
      final reminder = all.firstWhereOrNull((r) => r.id == reminderId);
      if (reminder != null) {
        repo.update(reminder.copyWith(isCompleted: true));
        // Force refresh active controller state if present
        if (Get.isRegistered<RemindersController>()) {
          Get.find<RemindersController>().onInit();
        }
      }
    } else if (actionId == 'snooze_action') {
      cancelReminder(reminderId);
      final repo = Get.find<ReminderRepository>();
      final all = repo.getAll();
      final reminder = all.firstWhereOrNull((r) => r.id == reminderId);
      if (reminder != null) {
        snoozeReminder(reminder);
      }
    } else {
      // Notification body tap or full-screen intent trigger
      Get.toNamed(AppRoutes.alarmRinging, arguments: reminderId);
    }
  }

  // The `timezone` package defaults tz.local to UTC unless told otherwise.
  // Without a native timezone-lookup plugin, approximate the device's zone
  // from its current UTC offset (whole-hour offsets only).
  void _setLocalTimeZone() {
    final offset = DateTime.now().timeZoneOffset;
    final sign = offset.isNegative ? '+' : '-';
    final hours = offset.abs().inHours;
    final name = hours == 0 ? 'UTC' : 'Etc/GMT$sign$hours';
    if (tz.timeZoneDatabase.locations.containsKey(name)) {
      tz.setLocalLocation(tz.getLocation(name));
    } else {
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> requestPermissions() async {
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleReminder(ReminderModel reminder) async {
    await cancelReminder(reminder.id);
    if (reminder.dateTime == null ||
        reminder.isCompleted ||
        reminder.dateTime!.isBefore(DateTime.now())) {
      return;
    }

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final canScheduleExact = androidPlugin == null ||
        (await androidPlugin.canScheduleExactNotifications() ?? true);

    await _plugin.zonedSchedule(
      reminder.id,
      reminder.title,
      reminder.description,
      tz.TZDateTime.from(reminder.dateTime!, tz.local),
      NotificationDetails(
        android: _androidDetails,
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: canScheduleExact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: reminder.id.toString(),
    );
  }

  Future<void> snoozeReminder(ReminderModel reminder) async {
    final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
    final snoozedReminder = reminder.copyWith(dateTime: snoozeTime);
    
    // 1. Persist the snoozed time
    final repo = Get.find<ReminderRepository>();
    await repo.update(snoozedReminder);
    
    // 2. Schedule the alarm for new time
    await scheduleReminder(snoozedReminder);

    // 3. Refresh controller to update UI
    if (Get.isRegistered<RemindersController>()) {
      Get.find<RemindersController>().onInit();
    }
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }
}

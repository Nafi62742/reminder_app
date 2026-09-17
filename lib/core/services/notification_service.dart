import 'package:flutter/foundation.dart';
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
  // Action buttons have showsUserInterface: true, so they launch the app
  // and trigger onDidReceiveNotificationResponse in the main isolate.
}

/// Schedules and cancels local notifications for reminders. All scheduling
/// is strictly on-device using Android's AlarmManager (alarmClock mode)
/// and iOS's UserNotifications framework — zero network or cloud dependency.
class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'reminders_alarm_channel_v3';
  static const String channelName = 'Reminders Alarms';
  static const String channelDescription = 'Alarms and alerts for scheduled reminders';

  /// Stores reminderId if the app cold-started from an alarm notification tap or full-screen intent.
  int? launchedReminderId;

  static final AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.max,
    priority: Priority.max,
    largeIcon: const DrawableResourceAndroidBitmap('ic_launcher_foreground'),
    playSound: true,
    sound: const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
    audioAttributesUsage: AudioAttributesUsage.alarm,
    category: AndroidNotificationCategory.alarm,
    fullScreenIntent: true,
    additionalFlags: Int32List.fromList(<int>[4]), // insistent (loop sound until interacted)
    enableVibration: true,
    vibrationPattern: Int64List.fromList(<int>[0, 1000, 500, 1000]),
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

  static const DarwinNotificationDetails _darwinDetails =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: 'default',
    interruptionLevel: InterruptionLevel.timeSensitive,
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

    await _plugin.initialize(
      const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // Explicitly configure and create the Android channel
    await _configureAndroidChannels();

    await requestPermissions();

    // Check if cold start was triggered by notification
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      final payload = launchDetails.notificationResponse?.payload;
      final reminderId = int.tryParse(payload ?? '');
      if (reminderId != null) {
        launchedReminderId = reminderId;
      }
    }

    return this;
  }

  /// Explicitly creates the high-importance alarm channel and removes older channels
  /// so that Android (especially Samsung / Xiaomi) doesn't reuse lower-importance cached channels.
  Future<void> _configureAndroidChannels() async {
    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return;

      // Delete deprecated channel IDs if they exist
      await androidPlugin.deleteNotificationChannel('reminders_alarm_channel');
      await androidPlugin.deleteNotificationChannel('reminders_alarm_channel_v2');

      // Create new max-importance channel
      final alarmChannel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
        playSound: true,
        sound: const UriAndroidNotificationSound('content://settings/system/alarm_alert'),
        audioAttributesUsage: AudioAttributesUsage.alarm,
        enableVibration: true,
        vibrationPattern: Int64List.fromList(<int>[0, 1000, 500, 1000]),
      );
      await androidPlugin.createNotificationChannel(alarmChannel);
    } catch (e) {
      debugPrint('Error configuring notification channels: $e');
    }
  }

  void _onNotificationResponse(NotificationResponse details) {
    final payload = details.payload;
    final actionId = details.actionId;
    final reminderId = int.tryParse(payload ?? '');

    if (reminderId == null) return;

    if (actionId == 'dismiss_action') {
      cancelReminder(reminderId);
      if (Get.isRegistered<ReminderRepository>()) {
        final repo = Get.find<ReminderRepository>();
        final all = repo.getAll();
        final reminder = all.firstWhereOrNull((r) => r.id == reminderId);
        if (reminder != null) {
          repo.update(reminder.copyWith(isCompleted: true));
          if (Get.isRegistered<RemindersController>()) {
            Get.find<RemindersController>().onInit();
          }
        }
      }
    } else if (actionId == 'snooze_action') {
      cancelReminder(reminderId);
      if (Get.isRegistered<ReminderRepository>()) {
        final repo = Get.find<ReminderRepository>();
        final all = repo.getAll();
        final reminder = all.firstWhereOrNull((r) => r.id == reminderId);
        if (reminder != null) {
          snoozeReminder(reminder);
        }
      }
    } else {
      // Notification tapped or full-screen intent triggered -> show alarm ringing screen
      Get.toNamed(AppRoutes.alarmRinging, arguments: reminderId);
    }
  }

  // The `timezone` package defaults tz.local to UTC unless told otherwise.
  // Without a native timezone-lookup plugin, approximate the device's zone
  // from its current UTC offset.
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
    try {
      await Permission.notification.request();
    } catch (_) {}

    try {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
    } catch (_) {}

    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}

    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (_) {}
  }

  /// Schedules a reminder offline backed by Android's AlarmManager (alarmClock mode)
  /// or iOS's local notification engine.
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

    // AndroidScheduleMode.alarmClock uses AlarmManager.setAlarmClock() —
    // the highest priority Android wake-up mechanism that ignores Doze mode.
    final primaryMode = canScheduleExact
        ? AndroidScheduleMode.alarmClock
        : AndroidScheduleMode.inexactAllowWhileIdle;

    final targetDateTime = tz.TZDateTime.from(reminder.dateTime!, tz.local);

    try {
      await _plugin.zonedSchedule(
        reminder.id,
        reminder.title,
        reminder.description,
        targetDateTime,
        NotificationDetails(
          android: _androidDetails,
          iOS: _darwinDetails,
        ),
        androidScheduleMode: primaryMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.id.toString(),
      );
    } catch (e) {
      debugPrint('Primary alarmClock schedule failed ($e), falling back to exactAllowWhileIdle');
      try {
        await _plugin.zonedSchedule(
          reminder.id,
          reminder.title,
          reminder.description,
          targetDateTime,
          NotificationDetails(
            android: _androidDetails,
            iOS: _darwinDetails,
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: reminder.id.toString(),
        );
      } catch (fallbackError) {
        debugPrint('Fallback exact schedule also failed ($fallbackError), scheduling inexact');
        await _plugin.zonedSchedule(
          reminder.id,
          reminder.title,
          reminder.description,
          targetDateTime,
          NotificationDetails(
            android: _androidDetails,
            iOS: _darwinDetails,
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: reminder.id.toString(),
        );
      }
    }
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

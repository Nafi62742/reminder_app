import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/repositories/reminder_repository.dart';

class RemindersController extends GetxController {
  RemindersController(this._repository, this._notifications, this._storage);

  final ReminderRepository _repository;
  final NotificationService _notifications;
  final StorageService _storage;

  // Only today-and-future reminders — past ones live in the history screen.
  final reminders = <ReminderModel>[].obs;

  String get userName => _storage.userName ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadReminders();
  }

  void _loadReminders() {
    final all = _repository.getAll()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Re-sync notifications for any pending reminders — covers cases like a
    // device reboot or the app being reinstalled with restored preferences.
    for (final reminder in all) {
      if (!reminder.isCompleted && reminder.dateTime.isAfter(DateTime.now())) {
        _notifications.scheduleReminder(reminder);
      }
    }

    final today = DateTimeFormatter.startOfDay(DateTime.now());
    reminders.assignAll(
      all.where(
        (r) => !DateTimeFormatter.startOfDay(r.dateTime).isBefore(today),
      ),
    );
  }

  Future<void> toggleComplete(ReminderModel reminder) async {
    final updated = reminder.copyWith(isCompleted: !reminder.isCompleted);
    await _repository.update(updated);
    if (updated.isCompleted) {
      await _notifications.cancelReminder(updated.id);
    } else {
      await _notifications.scheduleReminder(updated);
    }
    _loadReminders();
  }

  Future<void> deleteReminder(ReminderModel reminder) async {
    await _repository.delete(reminder.id);
    await _notifications.cancelReminder(reminder.id);
    _loadReminders();
  }

  void goToAdd() => Get.toNamed(AppRoutes.addReminder)?.then((_) => _loadReminders());

  void goToEdit(ReminderModel reminder) {
    Get.toNamed(AppRoutes.editReminder, arguments: reminder)
        ?.then((_) => _loadReminders());
  }

  void goToHistory() => Get.toNamed(AppRoutes.reminderHistory);
}

import 'package:get/get.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/repositories/reminder_repository.dart';

/// Every reminder whose date has already passed — completed or not — so
/// the user can see what they finished and what they missed.
class ReminderHistoryController extends GetxController {
  ReminderHistoryController(this._repository, this._notifications);

  final ReminderRepository _repository;
  final NotificationService _notifications;

  final reminders = <ReminderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    final today = DateTimeFormatter.startOfDay(DateTime.now());
    final past = _repository
        .getAll()
        .where((r) =>
            r.dateTime != null &&
            DateTimeFormatter.startOfDay(r.dateTime!).isBefore(today))
        .toList()
      ..sort((a, b) => b.dateTime!.compareTo(a.dateTime!));
    reminders.assignAll(past);
  }

  Future<void> toggleComplete(ReminderModel reminder) async {
    final updated = reminder.copyWith(isCompleted: !reminder.isCompleted);
    await _repository.update(updated);
    if (updated.isCompleted) {
      await _notifications.cancelReminder(updated.id);
    }
    _load();
  }

  Future<void> deleteReminder(ReminderModel reminder) async {
    await _repository.delete(reminder.id);
    await _notifications.cancelReminder(reminder.id);
    _load();
  }
}

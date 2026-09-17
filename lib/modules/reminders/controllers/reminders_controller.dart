import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/date_time_formatter.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../../data/repositories/schedule_repository.dart';

class MonthlyScheduleStat {
  final String label;
  final int completedCount;

  MonthlyScheduleStat(this.label, this.completedCount);
}

class RemindersController extends GetxController {
  RemindersController(this._repository, this._notifications, this._storage, this._scheduleRepository);

  final ReminderRepository _repository;
  final NotificationService _notifications;
  final StorageService _storage;
  final ScheduleRepository _scheduleRepository;

  // Only today-and-future reminders — past ones live in the history screen.
  final reminders = <ReminderModel>[].obs;
  final monthlyStats = <MonthlyScheduleStat>[].obs;

  String get userName => _storage.userName ?? '';

  @override
  void onInit() {
    super.onInit();
    _loadReminders();
  }

  void _loadReminders() {
    final all = _repository.getAll()
      ..sort((a, b) {
        // Undated reminders sort to the bottom.
        if (a.dateTime == null && b.dateTime == null) return 0;
        if (a.dateTime == null) return 1;
        if (b.dateTime == null) return -1;
        return a.dateTime!.compareTo(b.dateTime!);
      });

    // Re-sync notifications for any pending reminders — covers cases like a
    // device reboot or the app being reinstalled with restored preferences.
    for (final reminder in all) {
      if (!reminder.isCompleted &&
          reminder.dateTime != null &&
          reminder.dateTime!.isAfter(DateTime.now())) {
        _notifications.scheduleReminder(reminder);
      }
    }

    final today = DateTimeFormatter.startOfDay(DateTime.now());
    reminders.assignAll(
      all.where((r) {
        // Completed reminders are archived in History, not shown in active list.
        if (r.isCompleted) return false;
        // Undated reminders always appear in the main list.
        if (r.dateTime == null) return true;
        return !DateTimeFormatter.startOfDay(r.dateTime!).isBefore(today);
      }),
    );
    loadMonthlyStats();
  }

  void loadMonthlyStats() {
    final stats = <MonthlyScheduleStat>[];
    final now = DateTime.now();
    // Fetch last 5 months statistics
    for (int i = 4; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final monthStart = targetDate;
      final monthEnd = DateTime(targetDate.year, targetDate.month + 1, 1).subtract(const Duration(days: 1));
      
      final label = DateFormat('MMM').format(monthStart);
      final count = _scheduleRepository.completedCountBetween(monthStart, monthEnd);
      stats.add(MonthlyScheduleStat(label, count));
    }
    monthlyStats.assignAll(stats);
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

  void goToHistory() => Get.toNamed(AppRoutes.reminderHistory)?.then((_) => _loadReminders());
}

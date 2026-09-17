import 'dart:async';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/notification_service.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../reminders/controllers/reminders_controller.dart';

class AlarmRingingController extends GetxController {
  AlarmRingingController(this._repository, this._notifications);

  final ReminderRepository _repository;
  final NotificationService _notifications;

  final reminder = Rxn<ReminderModel>();
  final currentTimeString = ''.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _loadReminder();
    _startClock();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void _loadReminder() {
    final args = Get.arguments;
    int? reminderId;

    if (args is int) {
      reminderId = args;
    } else if (args is String) {
      reminderId = int.tryParse(args);
    } else if (args is ReminderModel) {
      reminder.value = args;
      return;
    }

    if (reminderId != null) {
      final all = _repository.getAll();
      reminder.value = all.firstWhereOrNull((r) => r.id == reminderId);
    }
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    final hour = now.hour == 0 ? 12 : (now.hour > 12 ? now.hour - 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    currentTimeString.value = '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> dismissAlarm() async {
    final current = reminder.value;
    if (current != null) {
      // 1. Cancel the local notification to stop sound
      await _notifications.cancelReminder(current.id);
      // 2. Mark reminder as completed in local storage
      final updated = current.copyWith(isCompleted: true);
      await _repository.update(updated);
      // 3. Refresh controller to update UI
      if (Get.isRegistered<RemindersController>()) {
        Get.find<RemindersController>().onInit();
      }
    }
    // Return to the reminders screen
    if (Get.key.currentState?.canPop() == true) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.main);
    }
  }

  Future<void> snoozeAlarm() async {
    final current = reminder.value;
    if (current != null) {
      // 1. Cancel the local notification to stop sound
      await _notifications.cancelReminder(current.id);
      // 2. Schedule snooze reminder (5 minutes from now)
      await _notifications.snoozeReminder(current);
    }
    // Return to the reminders screen
    if (Get.key.currentState?.canPop() == true) {
      Get.back();
    } else {
      Get.offAllNamed(AppRoutes.main);
    }
  }
}

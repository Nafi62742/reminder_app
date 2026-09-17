import 'package:get/get.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../reminders/controllers/reminders_controller.dart';
import '../../schedule/controllers/customize_schedule_controller.dart';
import '../../schedule/controllers/schedule_controller.dart';
import '../controllers/main_shell_controller.dart';

/// All four tabs stay mounted simultaneously (IndexedStack), so every
/// controller they need must be registered up front with `Get.put` rather
/// than the lazy, per-route `Get.lazyPut` used elsewhere.
class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    final storage = Get.find<StorageService>();
    final notifications = Get.find<NotificationService>();

    final scheduleRepository = Get.find<ScheduleRepository>();
    final reminderRepository = Get.find<ReminderRepository>();
    
    if (!Get.isRegistered<RemindersController>()) {
      Get.put(
        RemindersController(reminderRepository, notifications, storage, scheduleRepository),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ScheduleController>()) {
      Get.put(
        ScheduleController(scheduleRepository),
        permanent: true,
      );
    }
    if (!Get.isRegistered<CustomizeScheduleController>()) {
      Get.put(
        CustomizeScheduleController(scheduleRepository),
        permanent: true,
      );
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(
        ProfileController(storage, scheduleRepository),
        permanent: true,
      );
    }
    if (!Get.isRegistered<MainShellController>()) {
      Get.put(
        MainShellController(),
        permanent: true,
      );
    }
  }
}

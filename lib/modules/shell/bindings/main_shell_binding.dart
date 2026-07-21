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

    final reminderRepository = Get.put(ReminderRepository(storage));
    Get.put(RemindersController(reminderRepository, notifications, storage));

    final scheduleRepository = Get.put(ScheduleRepository(storage));
    Get.put(ScheduleController(scheduleRepository));
    Get.put(CustomizeScheduleController(scheduleRepository));

    Get.put(ProfileController(storage, scheduleRepository));

    Get.put(MainShellController());
  }
}

import 'package:get/get.dart';

import '../../../core/services/notification_service.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../controllers/alarm_ringing_controller.dart';

class AlarmRingingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AlarmRingingController>(
      () => AlarmRingingController(
        Get.find<ReminderRepository>(),
        Get.find<NotificationService>(),
      ),
    );
  }
}

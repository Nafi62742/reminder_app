import 'package:get/get.dart';

import '../../../core/services/notification_service.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../controllers/reminder_history_controller.dart';

class ReminderHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ReminderHistoryController(
        Get.find<ReminderRepository>(),
        Get.find<NotificationService>(),
      ),
    );
  }
}

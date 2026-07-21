import 'package:get/get.dart';

import '../../../core/services/notification_service.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../controllers/reminder_form_controller.dart';

class ReminderFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => ReminderFormController(
        Get.find<ReminderRepository>(),
        Get.find<NotificationService>(),
      ),
    );
  }
}

import 'package:get/get.dart';

import '../../profile/controllers/profile_controller.dart';
import '../../schedule/controllers/schedule_controller.dart';

/// Owns the bottom-nav tab index. All four tabs stay mounted at once
/// (via IndexedStack) so switching tabs doesn't re-run onInit — this
/// reloads the tabs whose data another tab could have just changed.
class MainShellController extends GetxController {
  final currentIndex = 0.obs;

  static const int remindersTab = 0;
  static const int scheduleTab = 1;
  static const int customizeTab = 2;
  static const int profileTab = 3;

  void changeTab(int index) {
    currentIndex.value = index;
    switch (index) {
      case scheduleTab:
        Get.find<ScheduleController>().reload();
      case profileTab:
        Get.find<ProfileController>().refreshStats();
    }
  }
}

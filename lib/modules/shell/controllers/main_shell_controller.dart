import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../profile/controllers/profile_controller.dart';
import '../../reminders/controllers/reminders_controller.dart';
import '../../schedule/controllers/schedule_controller.dart';
import '../../workout/controllers/workout_controller.dart';

/// Owns the bottom-nav tab index and the [PageView] that makes the tabs
/// swipeable. All four tabs stay mounted at once (the PageView is built
/// with an explicit children list, not `.builder`) so switching tabs never
/// re-runs onInit — [onPageChanged] instead reloads whichever tab's data
/// another tab could have just changed, whether the page changed by a tap
/// on the nav bar or a swipe.
class MainShellController extends GetxController {
  final currentIndex = 0.obs;
  final pageController = PageController();

  static const int remindersTab = 0;
  static const int scheduleTab = 1;
  static const int workoutTab = 2;
  static const int profileTab = 3;

  void changeTab(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
    switch (index) {
      case remindersTab:
        Get.find<RemindersController>().loadMonthlyStats();
      case scheduleTab:
        Get.find<ScheduleController>().reload();
      case workoutTab:
        Get.find<WorkoutController>().reload();
      case profileTab:
        Get.find<ProfileController>().refreshStats();
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

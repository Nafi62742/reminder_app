import 'package:get/get.dart';

import '../../modules/onboarding/bindings/onboarding_binding.dart';
import '../../modules/onboarding/views/onboarding_view.dart';
import '../../modules/profile/views/profile_settings_view.dart';
import '../../modules/reminders/bindings/reminder_form_binding.dart';
import '../../modules/reminders/bindings/reminder_history_binding.dart';
import '../../modules/reminders/views/reminder_form_view.dart';
import '../../modules/reminders/views/reminder_history_view.dart';
import '../../modules/shell/bindings/main_shell_binding.dart';
import '../../modules/shell/views/main_shell_view.dart';
import '../../modules/alarm/bindings/alarm_ringing_binding.dart';
import '../../modules/alarm/views/alarm_ringing_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainShellView(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: AppRoutes.addReminder,
      page: () => const ReminderFormView(),
      binding: ReminderFormBinding(),
    ),
    GetPage(
      name: AppRoutes.editReminder,
      page: () => const ReminderFormView(),
      binding: ReminderFormBinding(),
    ),
    GetPage(
      name: AppRoutes.reminderHistory,
      page: () => const ReminderHistoryView(),
      binding: ReminderHistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.profileSettings,
      page: () => const ProfileSettingsView(),
    ),
    GetPage(
      name: AppRoutes.alarmRinging,
      page: () => const AlarmRingingView(),
      binding: AlarmRingingBinding(),
    ),
  ];
}

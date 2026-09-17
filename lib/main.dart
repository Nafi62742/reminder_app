import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/app_theme_controller.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'data/repositories/reminder_repository.dart';
import 'data/repositories/schedule_repository.dart';
import 'modules/shell/bindings/main_shell_binding.dart';
import 'modules/splash/views/splash_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await Get.putAsync(() => StorageService().init());
  Get.put(ReminderRepository(storageService));
  Get.put(ScheduleRepository(storageService));

  await Get.putAsync(() => NotificationService().init());
  Get.put(AppThemeController(storageService));

  final nextRoute = storageService.userName == null
      ? AppRoutes.onboarding
      : AppRoutes.main;

  final initialTheme = AppTheme.dataFor(
    storageService.selectedThemeId ?? AppTheme.defaultThemeId,
  );

  runApp(ReminderApp(nextRoute: nextRoute, initialTheme: initialTheme));
}

class ReminderApp extends StatelessWidget {
  const ReminderApp({
    super.key,
    required this.nextRoute,
    required this.initialTheme,
  });

  final String nextRoute;
  final ThemeData initialTheme;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: initialTheme,
      themeMode: ThemeMode.light,
      initialBinding: MainShellBinding(),
      home: SplashView(nextRoute: nextRoute),
      getPages: AppPages.pages,
    );
  }
}

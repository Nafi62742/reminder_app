import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await Get.putAsync(() => StorageService().init());
  await Get.putAsync(() => NotificationService().init());

  final initialRoute = storageService.userName == null
      ? AppRoutes.onboarding
      : AppRoutes.main;

  runApp(ReminderApp(initialRoute: initialRoute));
}

class ReminderApp extends StatelessWidget {
  const ReminderApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}

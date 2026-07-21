import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reminder_app/app/routes/app_routes.dart';
import 'package:reminder_app/core/services/storage_service.dart';
import 'package:reminder_app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:reminder_app/modules/onboarding/views/onboarding_view.dart';

void main() {
  late StorageService storageService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService().init();
    Get.testMode = true;
    Get.put<StorageService>(storageService);
    Get.put(OnboardingController(storageService));
  });

  tearDown(Get.reset);

  Widget buildTestApp() {
    return GetMaterialApp(
      home: const OnboardingView(),
      getPages: [
        GetPage(name: AppRoutes.main, page: () => const SizedBox()),
      ],
    );
  }

  testWidgets('shows a validation error when submitting an empty name',
      (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Please enter your name'), findsOneWidget);
  });

  testWidgets('saves the entered name locally', (tester) async {
    await tester.pumpWidget(buildTestApp());

    await tester.enterText(find.byType(TextField), 'Alex');
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(storageService.userName, 'Alex');
  });
}

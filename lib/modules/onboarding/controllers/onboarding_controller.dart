import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/storage_service.dart';

class OnboardingController extends GetxController {
  OnboardingController(this._storage);

  final StorageService _storage;

  final nameController = TextEditingController();
  final errorText = RxnString();

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      errorText.value = 'Please enter your name';
      return;
    }
    errorText.value = null;
    await _storage.setUserName(name);
    Get.offAllNamed(AppRoutes.main);
  }
}

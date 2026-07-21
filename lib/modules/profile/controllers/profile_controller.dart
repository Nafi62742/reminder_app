import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/services/storage_service.dart';
import '../../../data/repositories/schedule_repository.dart';

class ProfileController extends GetxController {
  ProfileController(this._storage, this._scheduleRepository);

  final StorageService _storage;
  final ScheduleRepository _scheduleRepository;

  late final nameController = TextEditingController(text: _storage.userName ?? '');
  late final emailController = TextEditingController(text: _storage.userEmail ?? '');
  late final weightController =
      TextEditingController(text: _storage.userWeightKg?.toString() ?? '');
  late final heightController =
      TextEditingController(text: _storage.userHeightCm?.toString() ?? '');

  final appVersion = ''.obs;
  final totalItems = 0.obs;
  final todayCount = 0.obs;
  final weekCount = 0.obs;
  final monthCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    refreshStats();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    appVersion.value = '${info.version} (${info.buildNumber})';
  }

  void refreshStats() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(today.year, today.month, 1);

    totalItems.value = _scheduleRepository.getItems().length;
    todayCount.value = _scheduleRepository.completedCountFor(today);
    weekCount.value = _scheduleRepository.completedCountBetween(weekStart, today);
    monthCount.value = _scheduleRepository.completedCountBetween(monthStart, today);
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.onClose();
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;
    await _storage.setUserName(name);
    await _storage.setUserEmail(emailController.text.trim());
    await _storage.setUserWeightKg(double.tryParse(weightController.text.trim()));
    await _storage.setUserHeightCm(double.tryParse(heightController.text.trim()));
    Get.snackbar(
      'Saved',
      'Your profile has been updated',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

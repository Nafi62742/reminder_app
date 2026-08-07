import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

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

  Future<void> copyBackupToClipboard() async {
    final Map<String, dynamic> backup = _storage.exportBackup();
    final jsonStr = jsonEncode(backup);
    await Clipboard.setData(ClipboardData(text: jsonStr));
    Get.snackbar(
      'Backup Copied',
      'The backup data has been copied to your clipboard. Save it in a note or send it to yourself!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
    );
  }

  Future<void> restoreBackupFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      if (clipboardData == null || clipboardData.text == null || clipboardData.text!.isEmpty) {
        Get.snackbar(
          'Clipboard Empty',
          'Could not find any text in clipboard to restore.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
        );
        return;
      }
      final parsed = jsonDecode(clipboardData.text!) as Map<String, dynamic>;
      final success = await _storage.importBackup(parsed);
      if (success) {
        nameController.text = _storage.userName ?? '';
        emailController.text = _storage.userEmail ?? '';
        weightController.text = _storage.userWeightKg?.toString() ?? '';
        heightController.text = _storage.userHeightCm?.toString() ?? '';
        refreshStats();
        Get.snackbar(
          'Restore Successful',
          'Your offline backup data has been successfully restored!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
        );
      } else {
        Get.snackbar(
          'Restore Failed',
          'The clipboard text does not contain a valid backup.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Restore Error',
        'Failed to parse clipboard data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      );
    }
  }

  Future<void> exportBackupToFile() async {
    try {
      final Map<String, dynamic> backup = _storage.exportBackup();
      final jsonStr = jsonEncode(backup);

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/remindly_backup.json');
      await file.writeAsString(jsonStr);

      final xFile = XFile(file.path, mimeType: 'application/json');
      await Share.shareXFiles(
        [xFile],
        text: 'RemindLy Offline Backup Data',
      );
      
      Get.snackbar(
        'Backup Exported',
        'Your backup file is ready to share/download.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.withValues(alpha: 0.1),
      );
    } catch (e) {
      Get.snackbar(
        'Export Failed',
        'Failed to export backup to file: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      );
    }
  }

  Future<void> importBackupFromFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return;
      }

      final path = result.files.single.path!;
      final file = File(path);
      final content = await file.readAsString();

      final parsed = jsonDecode(content) as Map<String, dynamic>;
      final success = await _storage.importBackup(parsed);

      if (success) {
        nameController.text = _storage.userName ?? '';
        emailController.text = _storage.userEmail ?? '';
        weightController.text = _storage.userWeightKg?.toString() ?? '';
        heightController.text = _storage.userHeightCm?.toString() ?? '';
        refreshStats();
        Get.snackbar(
          'Restore Successful',
          'Your offline backup data has been successfully restored from the file!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withValues(alpha: 0.1),
        );
      } else {
        Get.snackbar(
          'Restore Failed',
          'The file content does not contain a valid backup format.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Restore Error',
        'Failed to import backup from file: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
      );
    }
  }
}

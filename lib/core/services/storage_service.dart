import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Thin wrapper around [SharedPreferences] — the single source of local
/// persistence for this offline-only app.
class StorageService extends GetxService {
  late final SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  String? get userName => _prefs.getString(StorageKeys.userName);

  Future<void> setUserName(String name) {
    return _prefs.setString(StorageKeys.userName, name);
  }

  String? get userEmail => _prefs.getString(StorageKeys.userEmail);

  Future<void> setUserEmail(String email) {
    return _prefs.setString(StorageKeys.userEmail, email);
  }

  double? get userWeightKg => _prefs.getDouble(StorageKeys.userWeightKg);

  Future<void> setUserWeightKg(double? weightKg) {
    if (weightKg == null) return _prefs.remove(StorageKeys.userWeightKg);
    return _prefs.setDouble(StorageKeys.userWeightKg, weightKg);
  }

  double? get userHeightCm => _prefs.getDouble(StorageKeys.userHeightCm);

  Future<void> setUserHeightCm(double? heightCm) {
    if (heightCm == null) return _prefs.remove(StorageKeys.userHeightCm);
    return _prefs.setDouble(StorageKeys.userHeightCm, heightCm);
  }

  List<Map<String, dynamic>> getReminders() {
    final raw = _prefs.getString(StorageKeys.reminders);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> saveReminders(List<Map<String, dynamic>> reminders) {
    return _prefs.setString(StorageKeys.reminders, jsonEncode(reminders));
  }

  int nextReminderId() {
    final next = (_prefs.getInt(StorageKeys.nextReminderId) ?? 0) + 1;
    _prefs.setInt(StorageKeys.nextReminderId, next);
    return next;
  }

  List<Map<String, dynamic>> getScheduleItems() {
    final raw = _prefs.getString(StorageKeys.scheduleItems);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> saveScheduleItems(List<Map<String, dynamic>> items) {
    return _prefs.setString(StorageKeys.scheduleItems, jsonEncode(items));
  }

  int nextScheduleItemId() {
    final next = (_prefs.getInt(StorageKeys.nextScheduleItemId) ?? 0) + 1;
    _prefs.setInt(StorageKeys.nextScheduleItemId, next);
    return next;
  }

  Map<String, List<int>> _allCompletions() {
    final raw = _prefs.getString(StorageKeys.scheduleCompletions);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, (value as List<dynamic>).cast<int>()),
    );
  }

  Set<int> getCompletions(String dateKey) {
    return (_allCompletions()[dateKey] ?? const <int>[]).toSet();
  }

  Future<void> saveCompletions(String dateKey, Set<int> itemIds) {
    final all = _allCompletions();
    all[dateKey] = itemIds.toList();
    return _prefs.setString(StorageKeys.scheduleCompletions, jsonEncode(all));
  }

  String? get selectedThemeId => _prefs.getString(StorageKeys.selectedThemeId);

  Future<void> setSelectedThemeId(String id) {
    return _prefs.setString(StorageKeys.selectedThemeId, id);
  }
}

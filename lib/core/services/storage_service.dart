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

  Map<String, dynamic> exportBackup() {
    return {
      StorageKeys.userName: _prefs.getString(StorageKeys.userName),
      StorageKeys.userEmail: _prefs.getString(StorageKeys.userEmail),
      StorageKeys.userWeightKg: _prefs.getDouble(StorageKeys.userWeightKg),
      StorageKeys.userHeightCm: _prefs.getDouble(StorageKeys.userHeightCm),
      StorageKeys.reminders: _prefs.getString(StorageKeys.reminders),
      StorageKeys.nextReminderId: _prefs.getInt(StorageKeys.nextReminderId),
      StorageKeys.scheduleItems: _prefs.getString(StorageKeys.scheduleItems),
      StorageKeys.nextScheduleItemId: _prefs.getInt(StorageKeys.nextScheduleItemId),
      StorageKeys.scheduleCompletions: _prefs.getString(StorageKeys.scheduleCompletions),
      StorageKeys.selectedThemeId: _prefs.getString(StorageKeys.selectedThemeId),
    };
  }

  Future<bool> importBackup(Map<String, dynamic> data) async {
    try {
      if (data.containsKey(StorageKeys.userName) && data[StorageKeys.userName] != null) {
        await _prefs.setString(StorageKeys.userName, data[StorageKeys.userName] as String);
      }
      if (data.containsKey(StorageKeys.userEmail) && data[StorageKeys.userEmail] != null) {
        await _prefs.setString(StorageKeys.userEmail, data[StorageKeys.userEmail] as String);
      }
      if (data.containsKey(StorageKeys.userWeightKg) && data[StorageKeys.userWeightKg] != null) {
        await _prefs.setDouble(StorageKeys.userWeightKg, (data[StorageKeys.userWeightKg] as num).toDouble());
      }
      if (data.containsKey(StorageKeys.userHeightCm) && data[StorageKeys.userHeightCm] != null) {
        await _prefs.setDouble(StorageKeys.userHeightCm, (data[StorageKeys.userHeightCm] as num).toDouble());
      }
      if (data.containsKey(StorageKeys.reminders) && data[StorageKeys.reminders] != null) {
        await _prefs.setString(StorageKeys.reminders, data[StorageKeys.reminders] as String);
      }
      if (data.containsKey(StorageKeys.nextReminderId) && data[StorageKeys.nextReminderId] != null) {
        await _prefs.setInt(StorageKeys.nextReminderId, data[StorageKeys.nextReminderId] as int);
      }
      if (data.containsKey(StorageKeys.scheduleItems) && data[StorageKeys.scheduleItems] != null) {
        await _prefs.setString(StorageKeys.scheduleItems, data[StorageKeys.scheduleItems] as String);
      }
      if (data.containsKey(StorageKeys.nextScheduleItemId) && data[StorageKeys.nextScheduleItemId] != null) {
        await _prefs.setInt(StorageKeys.nextScheduleItemId, data[StorageKeys.nextScheduleItemId] as int);
      }
      if (data.containsKey(StorageKeys.scheduleCompletions) && data[StorageKeys.scheduleCompletions] != null) {
        await _prefs.setString(StorageKeys.scheduleCompletions, data[StorageKeys.scheduleCompletions] as String);
      }
      if (data.containsKey(StorageKeys.selectedThemeId) && data[StorageKeys.selectedThemeId] != null) {
        await _prefs.setString(StorageKeys.selectedThemeId, data[StorageKeys.selectedThemeId] as String);
      }
      return true;
    } catch (e) {
      return false;
    }
  }
}

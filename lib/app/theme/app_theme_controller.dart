import 'package:get/get.dart';

import '../../core/services/storage_service.dart';
import 'app_theme.dart';

/// Tracks which of the four themes is active and persists the choice.
/// Registered as a permanent singleton in main() — the initial [ThemeData]
/// passed to GetMaterialApp is read directly from storage before this
/// controller even exists, so the app never flashes the wrong theme.
class AppThemeController extends GetxController {
  AppThemeController(this._storage);

  final StorageService _storage;

  late final selectedThemeId = (_storage.selectedThemeId ?? AppTheme.defaultThemeId).obs;

  ThemeOption get currentOption => AppTheme.optionFor(selectedThemeId.value);

  Future<void> selectTheme(String id) async {
    if (id == selectedThemeId.value) return;
    selectedThemeId.value = id;
    await _storage.setSelectedThemeId(id);
    Get.changeTheme(AppTheme.dataFor(id));
  }
}

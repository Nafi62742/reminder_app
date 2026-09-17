import 'package:get/get.dart';

import '../../../data/models/workout_item_model.dart';
import '../../../data/repositories/workout_repository.dart';
import 'workout_controller.dart';

/// Manages workout routine definitions: add, edit, delete, reorder, and reset to presets.
class CustomizeWorkoutController extends GetxController {
  CustomizeWorkoutController(this._repository);

  final WorkoutRepository _repository;

  final items = <WorkoutItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  void reload() {
    items.assignAll(_repository.getItems());
  }

  Future<void> addItem({
    required String title,
    required String instructions,
    required int durationMinutes,
    required int targetReps,
    int sets = 3,
    String category = 'General',
  }) async {
    await _repository.addItem(
      title: title,
      instructions: instructions,
      durationMinutes: durationMinutes,
      targetReps: targetReps,
      sets: sets,
      category: category,
    );
    reload();
    _syncWorkoutTab();
  }

  Future<void> updateItem(WorkoutItemModel item) async {
    await _repository.updateItem(item);
    reload();
    _syncWorkoutTab();
  }

  Future<void> deleteItem(WorkoutItemModel item) async {
    await _repository.deleteItem(item.id);
    reload();
    _syncWorkoutTab();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    await _repository.reorder(oldIndex, newIndex);
    _syncWorkoutTab();
  }

  Future<void> resetToPresets() async {
    await _repository.resetToPresets();
    reload();
    _syncWorkoutTab();
  }

  void _syncWorkoutTab() {
    if (Get.isRegistered<WorkoutController>()) {
      Get.find<WorkoutController>().reload();
    }
  }
}

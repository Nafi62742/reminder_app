import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:reminder_app/core/services/storage_service.dart';
import 'package:reminder_app/data/repositories/workout_repository.dart';
import 'package:reminder_app/modules/workout/controllers/customize_workout_controller.dart';
import 'package:reminder_app/modules/workout/controllers/workout_controller.dart';

void main() {
  late StorageService storageService;
  late WorkoutRepository workoutRepository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService().init();
    workoutRepository = WorkoutRepository(storageService);
    Get.testMode = true;
    Get.put<StorageService>(storageService);
    Get.put<WorkoutRepository>(workoutRepository);
  });

  tearDown(Get.reset);

  test('initializes default presets when storage is empty', () {
    final items = workoutRepository.getItems();
    expect(items.length, 6);
    expect(items.first.title, 'Push-ups');
    expect(items.first.targetReps, 15);
    expect(items.first.instructions, contains('chest'));
  });

  test('customizing reps updates the routine', () async {
    final items = workoutRepository.getItems();
    final first = items.first;

    await workoutRepository.updateReps(first.id, 25, newSets: 4);

    final updatedItems = workoutRepository.getItems();
    final updatedFirst = updatedItems.firstWhere((i) => i.id == first.id);
    expect(updatedFirst.targetReps, 25);
    expect(updatedFirst.sets, 4);
  });

  test('toggling completion persists per-day completion state', () async {
    final items = workoutRepository.getItems();
    final today = DateTime.now();

    expect(workoutRepository.completedCountFor(today), 0);

    await workoutRepository.toggleCompletion(items[0].id, today);
    expect(workoutRepository.completedCountFor(today), 1);
    expect(workoutRepository.completionsFor(today).contains(items[0].id), isTrue);

    // Toggle off
    await workoutRepository.toggleCompletion(items[0].id, today);
    expect(workoutRepository.completedCountFor(today), 0);
  });

  test('CustomizeWorkoutController supports add, edit, delete, reorder, reset', () async {
    final workoutController = WorkoutController(workoutRepository);
    Get.put(workoutController);
    final customizeController = CustomizeWorkoutController(workoutRepository);

    // Add item
    await customizeController.addItem(
      title: 'Diamond Push-ups',
      instructions: 'Keep thumbs and index fingers touching.',
      durationMinutes: 8,
      targetReps: 12,
      sets: 3,
      category: 'Upper Body',
    );

    expect(customizeController.items.length, 7);
    expect(workoutController.items.length, 7);

    // Edit item
    final added = customizeController.items.last;
    await customizeController.updateItem(added.copyWith(title: 'Diamond Push-ups (Advanced)'));
    expect(customizeController.items.last.title, 'Diamond Push-ups (Advanced)');

    // Reorder
    await customizeController.reorder(0, 1);
    expect(customizeController.items[1].title, 'Push-ups');

    // Delete
    await customizeController.deleteItem(added);
    expect(customizeController.items.length, 6);

    // Reset to presets
    await customizeController.resetToPresets();
    expect(customizeController.items.length, 6);
    expect(customizeController.items.first.title, 'Push-ups');
  });
}

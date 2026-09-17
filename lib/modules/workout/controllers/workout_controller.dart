import 'package:get/get.dart';

import '../../../data/models/workout_item_model.dart';
import '../../../data/repositories/workout_repository.dart';

class WorkoutController extends GetxController {
  WorkoutController(this._repository);

  final WorkoutRepository _repository;

  final items = <WorkoutItemModel>[].obs;
  final completedIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  void reload() {
    items.assignAll(_repository.getItems());
    completedIds.assignAll(_repository.completionsFor(DateTime.now()));
  }

  bool isCompleted(int id) => completedIds.contains(id);

  Future<void> toggleCompletion(WorkoutItemModel item) async {
    await _repository.toggleCompletion(item.id, DateTime.now());
    completedIds.assignAll(_repository.completionsFor(DateTime.now()));
  }

  Future<void> updateReps(int itemId, int reps, {int? sets}) async {
    await _repository.updateReps(itemId, reps, newSets: sets);
    reload();
  }
}

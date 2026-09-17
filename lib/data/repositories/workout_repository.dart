import '../../core/services/storage_service.dart';
import '../../core/utils/date_time_formatter.dart';
import '../models/workout_item_model.dart';

class WorkoutRepository {
  WorkoutRepository(this._storage);

  final StorageService _storage;

  /// Returns persisted workout items. If empty on first run, initializes with default presets.
  List<WorkoutItemModel> getItems() {
    final raw = _storage.getWorkoutItems();
    if (raw.isEmpty) {
      final presets = WorkoutItemModel.defaultPresets;
      _persistItems(presets);
      return presets;
    }
    final items = raw.map(WorkoutItemModel.fromJson).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  Future<void> _persistItems(List<WorkoutItemModel> items) {
    return _storage.saveWorkoutItems(items.map((i) => i.toJson()).toList());
  }

  List<WorkoutItemModel> _reindexed(List<WorkoutItemModel> items) {
    return [
      for (var i = 0; i < items.length; i++) items[i].copyWith(order: i),
    ];
  }

  Future<WorkoutItemModel> addItem({
    required String title,
    required String instructions,
    required int durationMinutes,
    required int targetReps,
    int sets = 3,
    String category = 'General',
  }) async {
    final items = getItems();
    final item = WorkoutItemModel(
      id: _storage.nextWorkoutItemId(),
      title: title,
      instructions: instructions,
      durationMinutes: durationMinutes,
      targetReps: targetReps,
      sets: sets,
      category: category,
      order: items.length,
    );
    items.add(item);
    await _persistItems(_reindexed(items));
    return item;
  }

  Future<void> updateItem(WorkoutItemModel item) async {
    final items = getItems();
    final index = items.indexWhere((i) => i.id == item.id);
    if (index == -1) return;
    items[index] = item;
    await _persistItems(items);
  }

  Future<void> updateReps(int itemId, int newReps, {int? newSets}) async {
    final items = getItems();
    final index = items.indexWhere((i) => i.id == itemId);
    if (index == -1) return;
    items[index] = items[index].copyWith(
      targetReps: newReps,
      sets: newSets,
    );
    await _persistItems(items);
  }

  Future<void> deleteItem(int id) async {
    final items = getItems()..removeWhere((i) => i.id == id);
    await _persistItems(_reindexed(items));
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final items = getItems();
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    await _persistItems(_reindexed(items));
  }

  Future<void> resetToPresets() async {
    final presets = WorkoutItemModel.defaultPresets;
    await _persistItems(presets);
  }

  Set<int> completionsFor(DateTime date) {
    return _storage.getWorkoutCompletions(DateTimeFormatter.dateKey(date));
  }

  Future<void> toggleCompletion(int itemId, DateTime date) async {
    final key = DateTimeFormatter.dateKey(date);
    final current = _storage.getWorkoutCompletions(key);
    if (!current.remove(itemId)) current.add(itemId);
    await _storage.saveWorkoutCompletions(key, current);
  }

  int completedCountFor(DateTime date) => completionsFor(date).length;

  int completedCountBetween(DateTime start, DateTime end) {
    var count = 0;
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      count += completedCountFor(d);
    }
    return count;
  }
}

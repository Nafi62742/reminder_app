import '../../core/services/storage_service.dart';
import '../../core/utils/date_time_formatter.dart';
import '../models/schedule_item_model.dart';

class ScheduleRepository {
  ScheduleRepository(this._storage);

  final StorageService _storage;

  List<ScheduleItemModel> getItems() {
    final items = _storage.getScheduleItems().map(ScheduleItemModel.fromJson).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  Future<void> _persistItems(List<ScheduleItemModel> items) {
    return _storage.saveScheduleItems(items.map((i) => i.toJson()).toList());
  }

  // Reassigns `order` to match each item's current position in the list.
  List<ScheduleItemModel> _reindexed(List<ScheduleItemModel> items) {
    return [
      for (var i = 0; i < items.length; i++) items[i].copyWith(order: i),
    ];
  }

  Future<ScheduleItemModel> addItem({
    required String title,
    int? timeMinutes,
  }) async {
    final items = getItems();
    // New items land next to others with a similar time; untimed items go
    // to the end. Once persisted, order is manual (see reorder) — time is
    // only used to pick this initial position.
    var insertAt = items.length;
    if (timeMinutes != null) {
      final index = items.indexWhere(
        (i) => i.timeMinutes == null || i.timeMinutes! > timeMinutes,
      );
      insertAt = index == -1 ? items.length : index;
    }
    final item = ScheduleItemModel(
      id: _storage.nextScheduleItemId(),
      title: title,
      timeMinutes: timeMinutes,
      order: insertAt,
    );
    items.insert(insertAt, item);
    final reindexed = _reindexed(items);
    await _persistItems(reindexed);
    return item;
  }

  Future<void> updateItem(ScheduleItemModel item) async {
    final items = getItems();
    final index = items.indexWhere((i) => i.id == item.id);
    if (index == -1) return;
    items[index] = item;
    await _persistItems(items);
  }

  Future<void> deleteItem(int id) async {
    final items = getItems()..removeWhere((i) => i.id == id);
    await _persistItems(_reindexed(items));
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final items = getItems();
    if (newIndex > oldIndex) newIndex -= 1;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    await _persistItems(_reindexed(items));
  }

  Set<int> completionsFor(DateTime date) {
    return _storage.getCompletions(DateTimeFormatter.dateKey(date));
  }

  Future<void> toggleCompletion(int itemId, DateTime date) async {
    final key = DateTimeFormatter.dateKey(date);
    final current = _storage.getCompletions(key);
    if (!current.remove(itemId)) current.add(itemId);
    await _storage.saveCompletions(key, current);
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

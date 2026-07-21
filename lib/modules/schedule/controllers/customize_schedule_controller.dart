import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/schedule_time_formatter.dart';
import '../../../data/models/schedule_item_model.dart';
import '../../../data/repositories/schedule_repository.dart';

/// Manages the daily-routine item definitions shown (and checked off) in
/// the Schedule tab: add/edit/delete plus drag-to-reorder.
class CustomizeScheduleController extends GetxController {
  CustomizeScheduleController(this._repository);

  final ScheduleRepository _repository;

  final items = <ScheduleItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    reload();
  }

  void reload() => items.assignAll(_repository.getItems());

  Future<void> addItem(String title, TimeOfDay? time) async {
    await _repository.addItem(
      title: title,
      timeMinutes: time == null ? null : ScheduleTimeFormatter.toMinutes(time),
    );
    reload();
  }

  Future<void> updateItem(
    ScheduleItemModel item,
    String title,
    TimeOfDay? time,
  ) async {
    await _repository.updateItem(
      item.copyWith(
        title: title,
        timeMinutes:
            time == null ? null : ScheduleTimeFormatter.toMinutes(time),
        clearTime: time == null,
      ),
    );
    reload();
  }

  Future<void> deleteItem(ScheduleItemModel item) async {
    await _repository.deleteItem(item.id);
    reload();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    // Optimistic local reorder for a smooth drag animation; persisted below.
    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final item = items.removeAt(oldIndex);
    items.insert(adjustedNewIndex, item);
    await _repository.reorder(oldIndex, newIndex);
  }
}

import 'package:get/get.dart';

import '../../../data/models/schedule_item_model.dart';
import '../../../data/repositories/schedule_repository.dart';

/// Today's daily-routine checklist. The item definitions themselves are
/// managed from the Customize tab; this controller only tracks today's
/// completion state for them.
class ScheduleController extends GetxController {
  ScheduleController(this._repository);

  final ScheduleRepository _repository;

  final items = <ScheduleItemModel>[].obs;
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

  Future<void> toggle(ScheduleItemModel item) async {
    await _repository.toggleCompletion(item.id, DateTime.now());
    reload();
  }
}

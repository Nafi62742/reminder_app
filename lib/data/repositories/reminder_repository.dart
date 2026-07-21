import '../../core/services/storage_service.dart';
import '../models/reminder_model.dart';

class ReminderRepository {
  ReminderRepository(this._storage);

  final StorageService _storage;

  List<ReminderModel> getAll() {
    return _storage.getReminders().map(ReminderModel.fromJson).toList();
  }

  Future<void> _persist(List<ReminderModel> reminders) {
    return _storage.saveReminders(reminders.map((r) => r.toJson()).toList());
  }

  Future<ReminderModel> create({
    required String title,
    String? description,
    required DateTime dateTime,
  }) async {
    final reminders = getAll();
    final reminder = ReminderModel(
      id: _storage.nextReminderId(),
      title: title,
      description: description,
      dateTime: dateTime,
    );
    reminders.add(reminder);
    await _persist(reminders);
    return reminder;
  }

  Future<void> update(ReminderModel reminder) async {
    final reminders = getAll();
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    if (index == -1) return;
    reminders[index] = reminder;
    await _persist(reminders);
  }

  Future<void> delete(int id) async {
    final reminders = getAll()..removeWhere((r) => r.id == id);
    await _persist(reminders);
  }
}

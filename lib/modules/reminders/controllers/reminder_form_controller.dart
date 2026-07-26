import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/notification_service.dart';
import '../../../data/models/reminder_model.dart';
import '../../../data/repositories/reminder_repository.dart';

class ReminderFormController extends GetxController {
  ReminderFormController(this._repository, this._notifications);

  final ReminderRepository _repository;
  final NotificationService _notifications;

  ReminderModel? _editing;
  bool get isEditing => _editing != null;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();
  final errorText = RxnString();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is ReminderModel) {
      _editing = arg;
      titleController.text = arg.title;
      descriptionController.text = arg.description ?? '';
      if (arg.dateTime != null) {
        selectedDate.value = DateTime(
          arg.dateTime!.year,
          arg.dateTime!.month,
          arg.dateTime!.day,
        );
        selectedTime.value = TimeOfDay.fromDateTime(arg.dateTime!);
      }
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) selectedDate.value = picked;
  }

  Future<void> pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? TimeOfDay.now(),
    );
    if (picked != null) selectedTime.value = picked;
  }

  void clearDate() => selectedDate.value = null;
  void clearTime() => selectedTime.value = null;

  Future<void> save() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      errorText.value = 'Please enter a title';
      return;
    }
    errorText.value = null;

    // Build dateTime only when both pickers have a value.
    DateTime? dateTime;
    final date = selectedDate.value;
    final time = selectedTime.value;
    if (date != null && time != null) {
      dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }

    final description = descriptionController.text.trim();

    if (isEditing) {
      final updated = _editing!.copyWith(
        title: title,
        description: description.isEmpty ? null : description,
        clearDescription: description.isEmpty,
        dateTime: dateTime,
        clearDateTime: dateTime == null,
      );
      await _repository.update(updated);
      if (dateTime != null) {
        await _notifications.scheduleReminder(updated);
      } else {
        await _notifications.cancelReminder(updated.id);
      }
    } else {
      final created = await _repository.create(
        title: title,
        description: description.isEmpty ? null : description,
        dateTime: dateTime,
      );
      if (dateTime != null) {
        await _notifications.scheduleReminder(created);
      }
    }
    Get.back();
  }
}

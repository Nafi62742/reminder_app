import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/reminder_form_controller.dart';

class ReminderFormView extends GetView<ReminderFormController> {
  const ReminderFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing ? 'Edit Reminder' : 'New Reminder'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller.titleController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.descriptionController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Date & Time (optional)',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => _PickerTile(
                icon: Icons.calendar_today_outlined,
                label: controller.selectedDate.value == null
                    ? 'Pick a date'
                    : DateFormat('MMM d, y').format(controller.selectedDate.value!),
                hasValue: controller.selectedDate.value != null,
                onTap: () => controller.pickDate(context),
                onClear: controller.clearDate,
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => _PickerTile(
                icon: Icons.access_time_outlined,
                label: controller.selectedTime.value == null
                    ? 'Pick a time'
                    : controller.selectedTime.value!.format(context),
                hasValue: controller.selectedTime.value != null,
                onTap: () => controller.pickTime(context),
                onClear: controller.clearTime,
              ),
            ),
            Obx(() {
              final error = controller.errorText.value;
              if (error == null) return const SizedBox(height: 24);
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: controller.save,
              child: Text(controller.isEditing ? 'Save Changes' : 'Add Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.hasValue,
    required this.onTap,
    required this.onClear,
  });

  final IconData icon;
  final String label;
  final bool hasValue;
  final VoidCallback onTap;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            if (hasValue)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/reminder_tile.dart';
import '../controllers/reminder_history_controller.dart';

class ReminderHistoryView extends GetView<ReminderHistoryController> {
  const ReminderHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Obx(() {
        final reminders = controller.reminders;
        if (reminders.isEmpty) {
          return Center(
            child: Text(
              'No past reminders yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return ReminderTile(
              reminder: reminder,
              onToggle: () => controller.toggleComplete(reminder),
              onTap: () => controller.toggleComplete(reminder),
              onDelete: () => controller.deleteReminder(reminder),
            );
          },
        );
      }),
    );
  }
}

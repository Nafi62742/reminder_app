import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../widgets/reminder_tile.dart';
import '../../../widgets/tab_header.dart';
import '../controllers/reminders_controller.dart';

class RemindersView extends GetView<RemindersController> {
  const RemindersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Obx(
            () => TabHeader(
              title: 'Hi, ${controller.userName}',
              subtitle: '${DateFormat('EEEE, MMM d').format(DateTime.now())} · '
                  '${controller.reminders.length} upcoming',
              trailing: IconButton(
                icon: const Icon(Icons.history, color: Colors.white),
                tooltip: 'History',
                onPressed: controller.goToHistory,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final reminders = controller.reminders;
              if (reminders.isEmpty) {
                return _EmptyState(colorScheme: Theme.of(context).colorScheme);
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return ReminderTile(
                    reminder: reminder,
                    onToggle: () => controller.toggleComplete(reminder),
                    onTap: () => controller.goToEdit(reminder),
                    onDelete: () => controller.deleteReminder(reminder),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToAdd,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 72,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No reminders yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap + to add your first one',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

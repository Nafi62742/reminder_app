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
    final theme = Theme.of(context);
    final topPadding = MediaQuery.of(context).padding.top + 96.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Obx(() {
              final reminders = controller.reminders;
              if (reminders.isEmpty) {
                return _EmptyState(colorScheme: theme.colorScheme);
              }
              return ListView.builder(
                padding: EdgeInsets.only(
                  top: topPadding + 8,
                  bottom: 110,
                ),
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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Obx(
              () => TabHeader(
                title: 'Hi, ${controller.userName}',
                subtitle: '${DateFormat('EEEE, MMM d').format(DateTime.now())} · '
                    '${controller.reminders.length} upcoming',
                trailing: IconButton(
                  icon: const Icon(Icons.history),
                  tooltip: 'History',
                  onPressed: controller.goToHistory,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          onPressed: controller.goToAdd,
          child: const Icon(Icons.add),
        ),
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

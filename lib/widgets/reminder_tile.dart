import 'package:flutter/material.dart';

import '../core/utils/date_time_formatter.dart';
import '../data/models/reminder_model.dart';

class ReminderTile extends StatelessWidget {
  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  final ReminderModel reminder;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOverdue = !reminder.isCompleted &&
        reminder.dateTime != null &&
        reminder.dateTime!.isBefore(DateTime.now());

    final accent = reminder.isCompleted
        ? colorScheme.outline
        : isOverdue
            ? colorScheme.error
            : colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: accent),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    children: [
                      Checkbox(
                        value: reminder.isCompleted,
                        onChanged: (_) => onToggle(),
                        shape: const CircleBorder(),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              reminder.title,
                              style: TextStyle(
                                decoration: reminder.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: reminder.isCompleted
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  size: 13,
                                  color: isOverdue
                                      ? colorScheme.error
                                      : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    reminder.dateTime == null
                                        ? 'No date set'
                                        : DateTimeFormatter.friendly(
                                            reminder.dateTime!),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isOverdue
                                          ? colorScheme.error
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: isOverdue
                                          ? FontWeight.w700
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: colorScheme.onSurfaceVariant,
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

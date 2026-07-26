import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/schedule_time_formatter.dart';
import '../../../widgets/tab_header.dart';
import '../controllers/schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Obx(() {
            final total = controller.items.length;
            final done = controller.completedIds.length;
            final progress = total == 0 ? 0.0 : done / total;
            return TabHeader(
              title: 'Daily Schedule',
              subtitle: DateFormat('EEEE, MMM d').format(DateTime.now()),
              bottom: total == 0
                  ? null
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$done of $total completed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            );
          }),
          Expanded(
            child: Obx(() {
              final items = controller.items;
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.wb_sunny_outlined,
                        size: 72,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No routine items yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add some from the Customize tab',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final done = controller.isCompleted(item.id);
                  final colorScheme = Theme.of(context).colorScheme;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => controller.toggle(item),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            Checkbox(
                              value: done,
                              onChanged: (_) => controller.toggle(item),
                              shape: const CircleBorder(),
                            ),
                            Container(
                              width: 36,
                              height: 36,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: done
                                    ? colorScheme.surfaceContainerHighest
                                    : colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                item.timeMinutes != null
                                    ? Icons.access_time
                                    : Icons.check_circle_outline,
                                size: 18,
                                color: done
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      decoration: done
                                          ? TextDecoration.lineThrough
                                          : null,
                                      color: done
                                          ? colorScheme.onSurfaceVariant
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                  if (item.timeMinutes != null)
                                    Text(
                                      ScheduleTimeFormatter.formatMinutes(
                                          item.timeMinutes!),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

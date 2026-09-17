import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/utils/schedule_time_formatter.dart';
import '../../../widgets/tab_header.dart';
import '../controllers/schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Obx(() {
        final total = controller.items.length;
        final done = controller.completedIds.length;
        final progress = total == 0 ? 0.0 : done / total;
        final hasProgress = total > 0;
        final topPadding = MediaQuery.of(context).padding.top + 96.0 + (hasProgress ? 42.0 : 0.0);

        return Stack(
          children: [
            Positioned.fill(
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
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No routine items yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap below to set up your daily routine',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonalIcon(
                          onPressed: () => Get.toNamed(AppRoutes.customizeSchedule)?.then((_) => controller.reload()),
                          icon: const Icon(Icons.tune_rounded),
                          label: const Text('Customize Routine'),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.only(
                    top: topPadding + 8,
                    bottom: 24,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final done = controller.isCompleted(item.id);
                    final isDark = colorScheme.brightness == Brightness.dark;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: done
                            ? colorScheme.surfaceContainer.withValues(alpha: 0.6)
                            : colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border(
                          left: BorderSide(
                            color: done ? colorScheme.outlineVariant : colorScheme.primary,
                            width: 4,
                          ),
                        ),
                        boxShadow: [
                          if (!done)
                            BoxShadow(
                              color: colorScheme.shadow.withValues(alpha: isDark ? 0.08 : 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => controller.toggle(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            children: [
                              Checkbox(
                                value: done,
                                onChanged: (_) => controller.toggle(item),
                                shape: const CircleBorder(),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: done
                                      ? colorScheme.surfaceContainerHighest
                                      : colorScheme.primaryContainer.withValues(alpha: 0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getTimeIcon(item.timeMinutes),
                                  size: 18,
                                  color: done
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: done ? FontWeight.w500 : FontWeight.w700,
                                        decoration: done ? TextDecoration.lineThrough : null,
                                        color: done
                                            ? colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                    if (item.timeMinutes != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        ScheduleTimeFormatter.formatMinutes(item.timeMinutes!),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
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
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TabHeader(
                title: 'Daily Schedule',
                subtitle: DateFormat('EEEE, MMM d').format(DateTime.now()),
                trailing: IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  tooltip: 'Customize Routine',
                  onPressed: () => Get.toNamed(AppRoutes.customizeSchedule)?.then((_) => controller.reload()),
                ),
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
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  IconData _getTimeIcon(int? minutes) {
    if (minutes == null) return Icons.checklist_rtl_rounded;
    final hour = minutes ~/ 60;
    if (hour < 12) return Icons.wb_twilight_rounded;
    if (hour < 17) return Icons.wb_sunny_rounded;
    return Icons.nightlight_round;
  }
}

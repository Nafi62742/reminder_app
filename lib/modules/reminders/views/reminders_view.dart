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
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    final reminders = controller.reminders;
                    if (reminders.isEmpty) {
                      return _EmptyState(
                        colorScheme: theme.colorScheme,
                        topPadding: topPadding,
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.only(
                        top: topPadding + 8,
                        bottom: 16,
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
                Obx(() {
                  final stats = controller.monthlyStats;
                  final totalCompletions = stats.fold(0, (sum, stat) => sum + stat.completedCount);
                  if (stats.isEmpty || totalCompletions == 0) return const SizedBox.shrink();

                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.26,
                    child: _MonthlyStatsChart(
                      stats: stats,
                      colorScheme: theme.colorScheme,
                    ),
                  );
                }),
              ],
            ),
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
      floatingActionButton: Obx(() {
        final stats = controller.monthlyStats;
        final totalCompletions = stats.fold(0, (sum, stat) => sum + stat.completedCount);
        final hasChart = stats.isNotEmpty && totalCompletions > 0;
        final chartHeight = MediaQuery.of(context).size.height * 0.26;

        return Padding(
          padding: EdgeInsets.only(
            bottom: hasChart ? (chartHeight + 8) : 0,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: FloatingActionButton(
              onPressed: controller.goToAdd,
              elevation: 0,
              hoverElevation: 0,
              focusElevation: 0,
              highlightElevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 28,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.colorScheme,
    required this.topPadding,
  });

  final ColorScheme colorScheme;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: topPadding),
      child: Center(
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
      ),
    );
  }
}

class _MonthlyStatsChart extends StatelessWidget {
  const _MonthlyStatsChart({
    required this.stats,
    required this.colorScheme,
  });

  final List<MonthlyScheduleStat> stats;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final maxVal = stats.map((s) => s.completedCount).reduce((a, b) => a > b ? a : b);
    final maxScale = maxVal == 0 ? 10.0 : maxVal.toDouble();

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Checklist Completion',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.bar_chart_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: stats.map((stat) {
                  final pct = stat.completedCount / maxScale;
                  final barHeight = (pct * 90).clamp(4.0, 90.0);

                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (stat.completedCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${stat.completedCount}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: colorScheme.primary,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 16),
                        Container(
                          width: 14,
                          height: 90,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                            width: 14,
                            height: barHeight,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primary.withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          stat.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/workout_item_model.dart';
import '../../../widgets/tab_header.dart';
import '../controllers/workout_controller.dart';

class WorkoutView extends GetView<WorkoutController> {
  const WorkoutView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Obx(() {
        final total = controller.items.length;
        final done = controller.completedIds.length;
        final progress = total == 0 ? 0.0 : done / total;
        final hasProgress = total > 0;
        final topPadding =
            MediaQuery.of(context).padding.top + 96.0 + (hasProgress ? 42.0 : 0.0);

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
                          Icons.fitness_center_rounded,
                          size: 72,
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No workout routines yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap below to set up your exercises',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.tonalIcon(
                          onPressed: () => Get.toNamed(AppRoutes.customizeWorkout)
                              ?.then((_) => controller.reload()),
                          icon: const Icon(Icons.tune_rounded),
                          label: const Text('Customize Workouts'),
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
                    return Obx(() {
                      final completed = controller.isCompleted(item.id);
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => _showWorkoutDetail(context, item),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: completed,
                                  onChanged: (_) =>
                                      controller.toggleCompletion(item),
                                  shape: const CircleBorder(),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: completed
                                        ? colorScheme.outlineVariant.withValues(alpha: 0.3)
                                        : colorScheme.primaryContainer,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(item.category),
                                    size: 20,
                                    color: completed
                                        ? colorScheme.outline
                                        : colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          decoration: completed
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: completed
                                              ? colorScheme.onSurfaceVariant
                                              : colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _Badge(
                                            icon: Icons.repeat_rounded,
                                            label: '${item.sets} x ${item.targetReps}',
                                            colorScheme: colorScheme,
                                            isCompleted: completed,
                                          ),
                                          const SizedBox(width: 6),
                                          _Badge(
                                            icon: Icons.timer_outlined,
                                            label: '${item.durationMinutes}m',
                                            colorScheme: colorScheme,
                                            isCompleted: completed,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: TabHeader(
                title: 'Daily Workout',
                subtitle: DateFormat('EEEE, MMM d').format(DateTime.now()),
                trailing: IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  tooltip: 'Customize Workouts',
                  onPressed: () => Get.toNamed(AppRoutes.customizeWorkout)
                      ?.then((_) => controller.reload()),
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
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.25),
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$done of $total workouts completed',
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

  void _showWorkoutDetail(BuildContext context, WorkoutItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WorkoutDetailSheet(item: item),
    );
  }

  IconData _getCategoryIcon(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('upper')) return Icons.fitness_center_rounded;
    if (lower.contains('core')) return Icons.accessibility_new_rounded;
    if (lower.contains('lower') || lower.contains('leg')) return Icons.directions_walk_rounded;
    if (lower.contains('cardio')) return Icons.directions_run_rounded;
    return Icons.sports_gymnastics_rounded;
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.isCompleted,
  });

  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isCompleted
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11,
            color: isCompleted ? colorScheme.outline : colorScheme.primary,
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isCompleted
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Interactive detail sheet showing workout instructions and a rep/set customizer.
class _WorkoutDetailSheet extends StatefulWidget {
  const _WorkoutDetailSheet({required this.item});

  final WorkoutItemModel item;

  @override
  State<_WorkoutDetailSheet> createState() => _WorkoutDetailSheetState();
}

class _WorkoutDetailSheetState extends State<_WorkoutDetailSheet> {
  late int _reps;
  late int _sets;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _reps = widget.item.targetReps;
    _sets = widget.item.sets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final controller = Get.find<WorkoutController>();
    final isCompleted = controller.isCompleted(widget.item.id);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Title & Category
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.item.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.item.durationMinutes} min workout',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // How To Do It Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'How to do it',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.instructions.isNotEmpty
                        ? widget.item.instructions
                        : 'Perform this routine with proper form and steady breathing.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Customize Reps & Sets Stepper Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customize Your Target',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Sets Stepper
                      Expanded(
                        child: _StepperControl(
                          label: 'Sets',
                          value: _sets,
                          onDecrement: () {
                            if (_sets > 1) {
                              setState(() {
                                _sets--;
                                _hasChanged = true;
                              });
                            }
                          },
                          onIncrement: () {
                            if (_sets < 20) {
                              setState(() {
                                _sets++;
                                _hasChanged = true;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Reps Stepper
                      Expanded(
                        child: _StepperControl(
                          label: 'Reps',
                          value: _reps,
                          step: 5,
                          onDecrement: () {
                            if (_reps > 1) {
                              setState(() {
                                _reps = (_reps <= 5) ? 1 : _reps - 5;
                                _hasChanged = true;
                              });
                            }
                          },
                          onIncrement: () {
                            if (_reps < 300) {
                              setState(() {
                                _reps += 5;
                                _hasChanged = true;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_hasChanged) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () async {
                          await controller.updateReps(
                            widget.item.id,
                            _reps,
                            sets: _sets,
                          );
                          setState(() => _hasChanged = false);
                          Get.snackbar(
                            'Target Saved',
                            'Updated to $_sets sets of $_reps reps',
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        child: const Text('Save Target Reps'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Complete Button
            FilledButton.icon(
              onPressed: () {
                controller.toggleCompletion(widget.item);
                Navigator.of(context).pop();
              },
              icon: Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline_rounded,
              ),
              label: Text(
                isCompleted ? 'Completed Today (Tap to undo)' : 'Mark as Completed',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: isCompleted
                    ? colorScheme.outlineVariant
                    : colorScheme.primary,
                foregroundColor:
                    isCompleted ? colorScheme.onSurface : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperControl extends StatelessWidget {
  const _StepperControl({
    required this.label,
    required this.value,
    this.step = 1,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int value;
  final int step;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove, size: 18),
                visualDensity: VisualDensity.compact,
                onPressed: onDecrement,
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18),
                visualDensity: VisualDensity.compact,
                onPressed: onIncrement,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

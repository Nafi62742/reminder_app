import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/workout_item_model.dart';
import '../controllers/customize_workout_controller.dart';

class CustomizeWorkoutView extends GetView<CustomizeWorkoutController> {
  const CustomizeWorkoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore_rounded),
            tooltip: 'Reset to Presets',
            onPressed: () => _confirmResetPresets(context),
          ),
        ],
      ),
      body: Obx(() {
        final items = controller.items;
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No workout routines yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap + below to add an exercise or reset presets',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => controller.resetToPresets(),
                  icon: const Icon(Icons.restore_rounded, size: 18),
                  label: const Text('Load Default Presets'),
                ),
              ],
            ),
          );
        }

        return ReorderableListView.builder(
          padding: const EdgeInsets.only(
            top: 12,
            bottom: 88,
          ),
          itemCount: items.length,
          onReorderItem: controller.reorder,
          itemBuilder: (context, index) {
            final item = items[index];
            final colorScheme = Theme.of(context).colorScheme;

            return Card(
              key: ValueKey(item.id),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _iconForCategory(item.category),
                        size: 22,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${item.sets} sets × ${item.targetReps} reps • ${item.durationMinutes}m • ${item.category}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit',
                      onPressed: () => _showAddEditDialog(context, item: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: 'Delete',
                      onPressed: () => controller.deleteItem(item),
                    ),
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.drag_handle,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showAddEditDialog(context),
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
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'core':
        return Icons.sports_gymnastics_rounded;
      case 'cardio':
        return Icons.directions_run_rounded;
      case 'lower body':
        return Icons.accessibility_new_rounded;
      case 'upper body':
      case 'general':
      default:
        return Icons.fitness_center_rounded;
    }
  }

  void _confirmResetPresets(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset to Presets?'),
        content: const Text(
          'This will replace your current workout routines with the default presets. Any custom edits will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.resetToPresets();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {WorkoutItemModel? item}) {
    showDialog(
      context: context,
      builder: (_) => _WorkoutItemDialog(item: item),
    );
  }
}

class _WorkoutItemDialog extends StatefulWidget {
  const _WorkoutItemDialog({this.item});

  final WorkoutItemModel? item;

  @override
  State<_WorkoutItemDialog> createState() => _WorkoutItemDialogState();
}

class _WorkoutItemDialogState extends State<_WorkoutItemDialog> {
  late final _titleController =
      TextEditingController(text: widget.item?.title ?? '');
  late final _instructionsController =
      TextEditingController(text: widget.item?.instructions ?? '');
  late final _durationController = TextEditingController(
      text: (widget.item?.durationMinutes ?? 10).toString());
  late final _repsController =
      TextEditingController(text: (widget.item?.targetReps ?? 15).toString());
  late final _setsController =
      TextEditingController(text: (widget.item?.sets ?? 3).toString());

  String _category = 'Upper Body';
  static const _categories = [
    'Upper Body',
    'Lower Body',
    'Core',
    'Cardio',
    'Full Body',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.item != null && _categories.contains(widget.item!.category)) {
      _category = widget.item!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _instructionsController.dispose();
    _durationController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final instructions = _instructionsController.text.trim();
    final duration = int.tryParse(_durationController.text.trim()) ?? 10;
    final reps = int.tryParse(_repsController.text.trim()) ?? 15;
    final sets = int.tryParse(_setsController.text.trim()) ?? 3;

    final controller = Get.find<CustomizeWorkoutController>();
    if (widget.item == null) {
      controller.addItem(
        title: title,
        instructions: instructions.isEmpty ? 'Perform with good form.' : instructions,
        durationMinutes: duration,
        targetReps: reps,
        sets: sets,
        category: _category,
      );
    } else {
      controller.updateItem(
        widget.item!.copyWith(
          title: title,
          instructions: instructions.isEmpty ? widget.item!.instructions : instructions,
          durationMinutes: duration,
          targetReps: reps,
          sets: sets,
          category: _category,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Workout' : 'New Workout'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Exercise Name *',
                hintText: 'e.g. Pull-ups',
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _category = val);
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target Reps',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Minutes',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _instructionsController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'How to do it (Instructions)',
                hintText: 'Step-by-step guidance on proper form...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/schedule_time_formatter.dart';
import '../../../data/models/schedule_item_model.dart';
import '../../../widgets/tab_header.dart';
import '../controllers/customize_schedule_controller.dart';

class CustomizeScheduleView extends GetView<CustomizeScheduleController> {
  const CustomizeScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const TabHeader(
            title: 'Customize',
            subtitle: 'Edit your daily routine items',
          ),
          Expanded(
            child: Obx(() {
              final items = controller.items;
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    'Tap + to add your first routine item',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              return ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: items.length,
                onReorderItem: controller.reorder,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final colorScheme = Theme.of(context).colorScheme;
                  return Card(
                    key: ValueKey(item.id),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.timeMinutes != null
                                  ? Icons.access_time
                                  : Icons.check_circle_outline,
                              size: 18,
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
                                      fontWeight: FontWeight.w600),
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
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () =>
                                _showItemDialog(context, item: item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showItemDialog(BuildContext context, {ScheduleItemModel? item}) {
    showDialog(
      context: context,
      builder: (_) => _ScheduleItemDialog(item: item),
    );
  }
}

class _ScheduleItemDialog extends StatefulWidget {
  const _ScheduleItemDialog({this.item});

  final ScheduleItemModel? item;

  @override
  State<_ScheduleItemDialog> createState() => _ScheduleItemDialogState();
}

class _ScheduleItemDialogState extends State<_ScheduleItemDialog> {
  late final _titleController = TextEditingController(text: widget.item?.title ?? '');
  TimeOfDay? _time;

  @override
  void initState() {
    super.initState();
    final minutes = widget.item?.timeMinutes;
    if (minutes != null) _time = ScheduleTimeFormatter.fromMinutes(minutes);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final controller = Get.find<CustomizeScheduleController>();
    if (widget.item == null) {
      controller.addItem(title, _time);
    } else {
      controller.updateItem(widget.item!, title, _time);
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Item' : 'New Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _save(),
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickTime,
            borderRadius: BorderRadius.circular(4),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Time (optional)'),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _time == null
                          ? 'No time set'
                          : ScheduleTimeFormatter.format(_time!),
                    ),
                  ),
                  if (_time != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _time = null),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

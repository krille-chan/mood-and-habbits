import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:mood_n_habbits/models/todo.dart';
import 'package:mood_n_habbits/utils/get_l10n.dart';

class TodoCreationBottomSheet extends StatefulWidget {
  final Todo? initialTodo;

  const TodoCreationBottomSheet({this.initialTodo, super.key});

  @override
  State<TodoCreationBottomSheet> createState() =>
      _TodoCreationBottomSheetState();
}

class _TodoCreationBottomSheetState extends State<TodoCreationBottomSheet> {
  @override
  void initState() {
    final initialTodo = widget.initialTodo;
    if (initialTodo != null) {
      _titleController.text = initialTodo.title;
      _descriptionController.text = initialTodo.description ?? '';
      _startDate.value = initialTodo.startDate;
      _dueDate.value = initialTodo.dueDate;
      _canSave.value = true;
    }
    _titleController.addListener(() {
      _canSave.value = _titleController.text.trim().isNotEmpty;
    });

    super.initState();
  }

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final ValueNotifier<DateTime?> _startDate = ValueNotifier(null);

  final ValueNotifier<DateTime?> _dueDate = ValueNotifier(null);

  final ValueNotifier<bool> _canSave = ValueNotifier(false);

  Future<DateTime?> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 365 * 100),
      ),
    );
    if (date == null) return null;
    if (!context.mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    return DateTime(
      date.year,
      date.month,
      date.day,
      time?.hour ?? 0,
      time?.minute ?? 0,
    );
  }

  void _setStartDate(BuildContext context) async {
    final dateTime = await _pickDateTime(context);
    if (dateTime != null) _startDate.value = dateTime;
  }

  void _setDueDate(BuildContext context) async {
    final dateTime = await _pickDateTime(context);
    if (dateTime != null) _dueDate.value = dateTime;
  }

  void _popAndCreateTodo(BuildContext context) => context.pop<Todo>(
        Todo(
          databaseId: widget.initialTodo?.databaseId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text.trim(),
          createdAt: DateTime.now(),
          startDate: _startDate.value,
          dueDate: _dueDate.value,
          finishedAt: widget.initialTodo?.finishedAt,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateButtonStyle = TextButton.styleFrom(
      foregroundColor: theme.colorScheme.onSecondaryContainer,
      backgroundColor: theme.colorScheme.secondaryContainer,
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_outlined),
          onPressed: () => context.pop(null),
        ),
        title: Text(context.l10n.addOneTimeTodo),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: context.l10n.title,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: context.l10n.description,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _startDate,
                  builder: (context, startDate, _) {
                    if (startDate == null) {
                      return TextButton(
                        style: dateButtonStyle,
                        onPressed: () => _setStartDate(context),
                        child: Text(context.l10n.startTime),
                      );
                    }
                    return TextButton.icon(
                      style: dateButtonStyle,
                      label: Text(
                        DateFormat.yMd(context.l10n.localeName)
                            .format(startDate),
                      ),
                      onPressed: () {
                        _startDate.value = null;
                      },
                      icon: const Icon(Icons.cancel_outlined),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _dueDate,
                  builder: (context, dueDate, _) {
                    if (dueDate == null) {
                      return TextButton(
                        style: dateButtonStyle,
                        onPressed: () => _setDueDate(context),
                        child: Text(context.l10n.dueTime),
                      );
                    }
                    return TextButton.icon(
                      style: dateButtonStyle,
                      label: Text(
                        DateFormat.yMd(context.l10n.localeName).format(dueDate),
                      ),
                      onPressed: () {
                        _dueDate.value = null;
                      },
                      icon: const Icon(Icons.cancel_outlined),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: _canSave,
            builder: (context, canSave, _) => ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: canSave ? () => _popAndCreateTodo(context) : null,
              child: Text(context.l10n.save),
            ),
          ),
        ],
      ),
    );
  }
}

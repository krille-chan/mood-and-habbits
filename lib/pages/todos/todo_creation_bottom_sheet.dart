import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:mood_n_habbits/models/todo.dart';
import 'package:mood_n_habbits/utils/get_l10n.dart';

class TodoCreationBottomSheet extends StatelessWidget {
  TodoCreationBottomSheet({super.key}) {
    _titleController.addListener(() {
      _canSave.value = _titleController.text.trim().isNotEmpty;
    });
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
    if (time == null) return null;
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  void _setStartDate(BuildContext context) async {
    final dateTime = await _pickDateTime(context);
    if (dateTime == null) return;
    _startDate.value = dateTime;
  }

  void _setDueDate(BuildContext context) async {
    final dateTime = await _pickDateTime(context);
    if (dateTime == null) return;
    _dueDate.value = dateTime;
  }

  void _popAndCreateTodo(BuildContext context) => context.pop<Todo>(
        Todo(
          title: _titleController.text.trim(),
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text.trim(),
          createdAt: DateTime.now(),
          startDate: _startDate.value,
          dueDate: _dueDate.value,
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
        title: Text(context.l10n.todo),
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
                      label: Text(DateFormat.yMd().format(startDate)),
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
                      label: Text(DateFormat.yMd().format(dueDate)),
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
              onPressed: canSave ? () => _popAndCreateTodo(context) : null,
              child: Text(context.l10n.save),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:mood_n_habits/models/habit.dart';
import 'package:mood_n_habits/utils/get_l10n.dart';

class HabitCreationBottomSheet extends StatefulWidget {
  final Habit? initialHabit;

  const HabitCreationBottomSheet({this.initialHabit, super.key});

  @override
  State<HabitCreationBottomSheet> createState() =>
      _HabitCreationBottomSheetState();
}

class _HabitCreationBottomSheetState extends State<HabitCreationBottomSheet> {
  @override
  void initState() {
    final initialHabit = widget.initialHabit;
    if (initialHabit != null) {
      _titleController.text = initialHabit.title;
      _descriptionController.text = initialHabit.description ?? '';
      _canSave.value = true;
    }
    _titleController.addListener(() {
      _canSave.value = _titleController.text.trim().isNotEmpty;
    });

    super.initState();
  }

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descriptionController = TextEditingController();

  final ValueNotifier<bool> _canSave = ValueNotifier(false);

  void _popAndCreateHabit(BuildContext context) => context.pop<Habit>(
        Habit(
          databaseId: widget.initialHabit?.databaseId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text.trim(),
          createdAt: DateTime.now(),
          interval: HabitInterval.daily,
          days: null,
          emoji: null,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_outlined),
          onPressed: () => context.pop(null),
        ),
        title: Text(context.l10n.newHabit),
        actions: [
          ValueListenableBuilder(
            valueListenable: _canSave,
            builder: (context, canSave, _) => Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                onPressed: canSave ? () => _popAndCreateHabit(context) : null,
                child: Text(context.l10n.save),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
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
        ],
      ),
    );
  }
}

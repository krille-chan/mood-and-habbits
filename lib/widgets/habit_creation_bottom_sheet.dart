import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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

  final ValueNotifier<HabitInterval> _interval =
      ValueNotifier(HabitInterval.daily);

  final ValueNotifier<List<int>?> _days = ValueNotifier(null);

  void _popAndCreateHabit(BuildContext context) => context.pop<Habit>(
        Habit(
          databaseId: widget.initialHabit?.databaseId,
          title: _titleController.text.trim(),
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text.trim(),
          createdAt: DateTime.now(),
          interval: _interval.value,
          days: _days.value,
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
          const SizedBox(height: 16),
          ValueListenableBuilder(
            valueListenable: _interval,
            builder: (context, currentInterval, _) {
              final now = DateTime.now();
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16.0),
                      child: DropdownButton(
                        padding: const EdgeInsets.all(8.0),
                        isExpanded: true,
                        items: HabitInterval.values
                            .map(
                              (interval) => DropdownMenuItem(
                                value: interval,
                                child: Text(interval.name),
                              ),
                            )
                            .toList(),
                        value: currentInterval,
                        onChanged: (interval) {
                          _interval.value = interval ?? HabitInterval.daily;
                          if ({
                            HabitInterval.daysInWeek,
                            HabitInterval.daysInMonth,
                          }.contains(interval)) {
                            _days.value = [];
                          } else {
                            _days.value = null;
                          }
                        },
                      ),
                    ),
                  ),
                  if ({HabitInterval.daysInWeek, HabitInterval.daysInMonth}
                      .contains(currentInterval)) ...[
                    const SizedBox(height: 16),
                    if (currentInterval == HabitInterval.daysInWeek)
                      Builder(
                        builder: (context) {
                          final monday =
                              now.subtract(Duration(days: now.weekday));
                          final formatter = DateFormat.E(
                            context.l10n.localeName,
                          );
                          return ValueListenableBuilder(
                            valueListenable: _days,
                            builder: (context, selectedDays, _) {
                              return Wrap(
                                children: [
                                  for (var day = 0; day < 7; day++)
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Material(
                                        color: selectedDays?.contains(day) ==
                                                true
                                            ? theme.colorScheme.primaryContainer
                                            : theme.colorScheme.surfaceBright,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                          side: BorderSide(
                                            color:
                                                selectedDays?.contains(day) ==
                                                        true
                                                    ? theme.colorScheme.primary
                                                    : theme.dividerColor,
                                          ),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: InkWell(
                                          onTap: () {
                                            if (_days.value!.contains(day)) {
                                              _days.value =
                                                  List.from(_days.value!)
                                                    ..remove(day);
                                            } else {
                                              _days.value =
                                                  List.from(_days.value!)
                                                    ..add(day);
                                            }
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                              horizontal: 10.0,
                                            ),
                                            child: Text(
                                              formatter.format(
                                                monday.add(Duration(days: day)),
                                              ),
                                              style:
                                                  theme.textTheme.titleMedium,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:mood_n_habits/models/habit.dart';
import 'package:mood_n_habits/models/habit_achieved.dart';
import 'package:mood_n_habits/utils/get_l10n.dart';
import 'package:mood_n_habits/utils/same_day.dart';

class HabitListItem extends StatelessWidget {
  final Habit habit;
  final bool reordering;
  final bool flying;
  final ({void Function() onEdit, void Function() onDelete})? settings;
  final List<HabitAchieved> achieved;
  final void Function(HabitAchievedValue? value, DateTime time) onSetAchieved;

  const HabitListItem({
    required this.habit,
    required this.achieved,
    this.reordering = false,
    this.flying = false,
    this.settings,
    required this.onSetAchieved,
    super.key,
  });

  int countAchieved(DateTime time) =>
      achieved.where((a) => a.createdAt.isSameDay(time)).fold(
            0,
            (v, a) => a.value == HabitAchievedValue.achieved ? v + 1 : v - 1,
          );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = habit.description;
    final settings = this.settings;
    final todayAchievedCount = countAchieved(DateTime.now().dateOnly);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        color: theme.colorScheme.surfaceContainer,
        clipBehavior: Clip.hardEdge,
        elevation: flying ? 4 : 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                child: Center(
                  child: Text(
                    habit.emoji ?? habit.title.substring(0, 1).toUpperCase(),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(habit.title)),
                  Text(
                    habit.localizedHabitInterval(context),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
              trailing: reordering
                  ? const Icon(Icons.reorder_outlined)
                  : settings != null
                      ? PopupMenuButton(
                          child: const Icon(Icons.tune_outlined),
                          onSelected: (value) {
                            switch (value) {
                              case HabitListItemActions.edit:
                                settings.onEdit();
                              case HabitListItemActions.delete:
                                settings.onDelete();
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: HabitListItemActions.edit,
                              child: Text(context.l10n.edit),
                            ),
                            PopupMenuItem(
                              value: HabitListItemActions.delete,
                              child: Text(context.l10n.delete),
                            ),
                          ],
                        )
                      : Icon(
                          todayAchievedCount == 0
                              ? Icons.circle_outlined
                              : todayAchievedCount < 0
                                  ? Icons.cancel
                                  : Icons.check_circle,
                          size: 32,
                          color: todayAchievedCount == 0
                              ? null
                              : todayAchievedCount < 0
                                  ? theme.colorScheme.error
                                  : theme.brightness == Brightness.light
                                      ? Colors.green.shade900
                                      : Colors.green.shade300,
                        ),
              onTap: settings == null
                  ? () => onSetAchieved(
                        todayAchievedCount == 0
                            ? HabitAchievedValue.achieved
                            : todayAchievedCount > 0
                                ? HabitAchievedValue.notAchieved
                                : null,
                        DateTime.now(),
                      )
                  : null,
            ),
            if (description != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(description),
              ),
            if (settings != null)
              SizedBox(
                height: 105,
                child: ListView.builder(
                  itemCount: 7,
                  reverse: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final tileDate = DateTime.now().dateOnly.subtract(
                          Duration(days: index),
                        );
                    final isActive = switch (habit.interval) {
                      HabitInterval.daysInMonth =>
                        habit.days!.contains(tileDate.day),
                      HabitInterval.daysInWeek =>
                        habit.days!.contains(tileDate.weekday),
                      HabitInterval.continuesly => true,
                      HabitInterval.daily => true,
                    };
                    final achievedCount = countAchieved(tileDate);

                    return Opacity(
                      opacity: isActive ? 1 : 0.33,
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: 8.0,
                            ),
                            width: 48,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: achievedCount > 0
                                  ? theme.brightness == Brightness.light
                                      ? Colors.green.shade100
                                      : Colors.green.shade900
                                  : achievedCount < 0
                                      ? theme.colorScheme.errorContainer
                                      : Colors.transparent,
                              border: Border.all(
                                color: achievedCount == 0
                                    ? theme.dividerColor
                                    : achievedCount > 0
                                        ? Colors.green
                                        : theme.colorScheme.error,
                              ),
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: InkWell(
                              onTap: !isActive
                                  ? null
                                  : () => onSetAchieved(
                                        achievedCount == 0
                                            ? HabitAchievedValue.achieved
                                            : achievedCount > 0
                                                ? HabitAchievedValue.notAchieved
                                                : null,
                                        tileDate,
                                      ),
                              borderRadius: BorderRadius.circular(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        DateFormat.E(context.l10n.localeName)
                                            .format(tileDate),
                                        style: TextStyle(
                                          color: achievedCount < 0
                                              ? theme
                                                  .colorScheme.onErrorContainer
                                              : theme.colorScheme.onSurface,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: theme.colorScheme.surfaceBright,
                                    borderRadius: BorderRadius.circular(16.0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Center(
                                        child: Text(
                                          tileDate.day.toString(),
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: theme.colorScheme.onSurface,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (achievedCount != 0)
                            Positioned(
                              right: 6,
                              top: 8,
                              child: Icon(
                                achievedCount > 0
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 16,
                                color: achievedCount > 0
                                    ? theme.brightness == Brightness.light
                                        ? Colors.green.shade900
                                        : Colors.green.shade300
                                    : theme.colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum HabitListItemActions { edit, delete }

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:mood_n_habits/models/task.dart';
import 'package:mood_n_habits/utils/get_l10n.dart';

class Habit extends Task {
  final HabitInterval interval;
  final List<int>? days;
  final String? emoji;

  Habit({
    super.databaseId,
    required super.title,
    super.description,
    required super.createdAt,
    required this.interval,
    required this.days,
    required this.emoji,
    super.sortOrder,
  });

  @override
  Map<String, Object?> toDatabaseRow() => {
        ...super.toDatabaseRow(),
        'interval': interval.name,
        'days': days?.join(','),
        'emoji': emoji,
      };

  factory Habit.fromDatabaseRow(Map<String, Object?> row) => Habit(
        databaseId: row['id'] as int?,
        title: row['title'] as String,
        description: row['description'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int),
        interval:
            HabitInterval.values.singleWhere((i) => i.name == row['interval']),
        days: (row['days'] as String?)?.split(',').map(int.parse).toList(),
        emoji: row['emoji'] as String?,
        sortOrder: row['sortOrder'] as int?,
      );

  String localizedHabitInterval(BuildContext context) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday));
    switch (interval) {
      case HabitInterval.daily:
        return context.l10n.daily;
      case HabitInterval.daysInWeek:
        return days!
            .map(
              (day) => DateFormat.E(context.l10n.localeName)
                  .format(monday.add(Duration(days: day))),
            )
            .join(', ');
      case HabitInterval.daysInMonth:
        return context.l10n.monthDays(days!.join(', '));
      case HabitInterval.continuesly:
        return context.l10n.continuesly;
    }
  }
}

enum HabitInterval { daily, daysInWeek, daysInMonth, continuesly }

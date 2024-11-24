import 'package:mood_n_habits/models/task.dart';

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
}

enum HabitInterval { daily, daysInWeek, daysInMonth, continuesly }

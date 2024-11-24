import 'package:mood_n_habits/models/default_database_item.dart';

class HabitAchieved extends DefaultDatabaseItem {
  final int habitId;
  final String? label;
  final HabitAchievedValue value;

  HabitAchieved({
    super.databaseId,
    required super.createdAt,
    required this.habitId,
    required this.label,
    required this.value,
  });

  @override
  Map<String, Object?> toDatabaseRow() => {
        ...super.toDatabaseRow(),
        'habitId': habitId,
        'label': label,
        'value': value.name,
      };

  factory HabitAchieved.fromDatabaseRow(Map<String, Object?> row) =>
      HabitAchieved(
        databaseId: row['id'] as int?,
        habitId: row['habitId'] as int,
        label: row['label'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int),
        value: HabitAchievedValue.values.singleWhere(
          (v) => row['value'] == v.name,
        ),
      );
}

enum HabitAchievedValue { achieved, notAchieved }

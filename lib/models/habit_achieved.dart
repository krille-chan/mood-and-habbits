import 'package:mood_n_habits/models/default_database_item.dart';

class HabitAchieved extends DefaultDatabaseItem {
  final int habbitId;
  final String? label;
  final HabitAchievedValue value;

  HabitAchieved({
    super.databaseId,
    required super.createdAt,
    required this.habbitId,
    required this.label,
    required this.value,
  });

  @override
  Map<String, Object?> toDatabaseRow() => {
        ...super.toDatabaseRow(),
        'habbitId': habbitId,
        'label': label,
        'value': value.name,
      };

  factory HabitAchieved.fromDatabaseRow(Map<String, Object?> row) =>
      HabitAchieved(
        databaseId: row['id'] as int?,
        habbitId: row['habbitId'] as int,
        label: row['label'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int),
        value: HabitAchievedValue.values.singleWhere(
          (v) => row['value'] == v.name,
        ),
      );
}

enum HabitAchievedValue { achieved, notAchieved }

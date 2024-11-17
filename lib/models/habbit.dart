import 'package:mood_n_habbits/models/task.dart';

class Habbit extends Task {
  final HabbitInterval interval;
  final List<int>? days;
  final String? emoji;

  Habbit({
    super.databaseId,
    required super.title,
    super.description,
    required super.createdAt,
    required this.interval,
    required this.days,
    required this.emoji,
  });

  @override
  Map<String, Object?> toDatabaseRow() => {
        ...super.toDatabaseRow(),
        'interval': interval.name,
        'days': days?.join(','),
        'emoji': emoji,
      };

  factory Habbit.fromDatabaseRow(Map<String, Object?> row) => Habbit(
        databaseId: row['id'] as int?,
        title: row['title'] as String,
        description: row['description'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int),
        interval:
            HabbitInterval.values.singleWhere((i) => i.name == row['interval']),
        days: (row['days'] as String?)?.split(',').map(int.parse).toList(),
        emoji: row['emoji'] as String?,
      );
}

enum HabbitInterval { daily, daysInWeek, daysInMonth, continuesly }

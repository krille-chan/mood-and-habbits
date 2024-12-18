import 'package:mood_n_habits/models/task.dart';

class Todo extends Task {
  final DateTime? finishedAt;
  final DateTime? startDate;
  final DateTime? dueDate;

  const Todo({
    super.databaseId,
    required super.title,
    super.description,
    required super.createdAt,
    this.finishedAt,
    this.startDate,
    this.dueDate,
    super.sortOrder,
  });

  @override
  Map<String, Object?> toDatabaseRow() => {
        ...super.toDatabaseRow(),
        'finishedAt': finishedAt?.millisecondsSinceEpoch,
        'startDate': startDate?.millisecondsSinceEpoch,
        'dueDate': dueDate?.millisecondsSinceEpoch,
      };

  factory Todo.fromDatabaseRow(Map<String, Object?> row) => Todo(
        databaseId: row['id'] as int?,
        title: row['title'] as String,
        description: row['description'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int),
        finishedAt: row['finishedAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row['finishedAt'] as int),
        startDate: row['startDate'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row['startDate'] as int),
        dueDate: row['dueDate'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row['dueDate'] as int),
        sortOrder: row['sortOrder'] as int?,
      );
}

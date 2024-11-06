class Todo {
  final int? databaseId;
  final String task;
  final String? description;
  final DateTime createdAt;
  final DateTime? finishedAt;

  const Todo({
    this.databaseId,
    required this.task,
    this.description,
    required this.createdAt,
    this.finishedAt,
  });

  static const String databaseRowName = 'todo';

  Map<String, Object?> toDatabaseRow() => {
        if (databaseId != null) 'id': databaseId,
        'task': task,
        if (description != null) 'description': description,
        'createdAt': createdAt.millisecondsSinceEpoch,
        if (finishedAt != null)
          'finishedAt': finishedAt?.millisecondsSinceEpoch,
      };

  factory Todo.fromDatabaseRow(Map<String, Object?> row) => Todo(
        databaseId: row['id'] as int?,
        task: row['task'] as String,
        description: row['description'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['createdAt'] as int),
        finishedAt: row['finishedAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(row['finishedAt'] as int),
      );
}

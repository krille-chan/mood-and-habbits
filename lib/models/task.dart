abstract class Task {
  final int? databaseId;
  final String title;
  final String? description;
  final DateTime createdAt;

  const Task({
    this.databaseId,
    required this.title,
    this.description,
    required this.createdAt,
  });

  Map<String, Object?> toDatabaseRow() => {
        if (databaseId != null) 'id': databaseId,
        'title': title,
        if (description != null) 'description': description,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };
}

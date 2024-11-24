import 'package:mood_n_habits/models/default_database_item.dart';

abstract class Task extends DefaultDatabaseItem {
  final String title;
  final String? description;

  const Task({
    super.databaseId,
    required this.title,
    this.description,
    required super.createdAt,
  });

  @override
  Map<String, Object?> toDatabaseRow() => {
        ...super.toDatabaseRow(),
        'title': title,
        if (description != null) 'description': description,
      };
}

import 'package:mood_n_habits/models/default_database_item.dart';

abstract class Task extends DefaultDatabaseItem {
  final String title;
  final String? description;
  final int? sortOrder;

  const Task({
    super.databaseId,
    required this.title,
    this.description,
    required super.createdAt,
    this.sortOrder,
  });

  @override
  Map<String, Object?> toDatabaseRow() => {
        ...super.toDatabaseRow(),
        'title': title,
        if (description != null) 'description': description,
        'sortOrder': sortOrder,
      };
}

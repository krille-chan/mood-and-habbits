import 'package:flutter/widgets.dart';

import 'package:sqflite/sqflite.dart';

Future<void> createSchema(Database database) =>
    database.transaction((transaction) async {
      for (final table in DatabaseTables.values) {
        await transaction.execute(
          'CREATE TABLE IF NOT EXISTS ${table.name} ${table.creationQueryColumns}',
        );
      }
    });

enum DatabaseTables {
  mood(
    '(id INTEGER PRIMARY KEY, mood INTEGER NOT NULL, time INTEGER NOT NULL, label TEXT)',
  ),
  todo(
    '(id INTEGER PRIMARY KEY, title TEXT NO NULL, description TEXT, createdAt INTEGER NOT NULL, finishedAt INTEGER, startDate INTEGER, dueDate INTEGER, sortOrder INTEGER NOT NULL)',
  ),
  habit(
    '(id INTEGER PRIMARY KEY, title TEXT NO NULL, description TEXT, createdAt INTEGER NOT NULL, interval TEXT NOT NULL, days TEXT, emoji TEXT, sortOrder INTEGER NOT NULL)',
  ),
  habitAchieved(
    '(id INTEGER PRIMARY KEY, habitId INTEGER NOT NULL, createdAt INTEGER NOT NULL, label TEXT)',
  ),
  ;

  const DatabaseTables(this.creationQueryColumns);

  final String creationQueryColumns;
}

Future<void> upgradeSchema(
  Database database,
  int oldVersion,
  int newVersion,
) async {
  debugPrint('Upgrade Database from version $oldVersion to $newVersion');
  // TODO: Implement database migration
}

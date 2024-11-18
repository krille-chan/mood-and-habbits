import 'package:flutter/widgets.dart';

import 'package:sqflite/sqflite.dart';

import 'package:mood_n_habits/models/mood.dart';
import 'package:mood_n_habits/models/todo.dart';

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
    '(id INTEGER PRIMARY KEY, title TEXT NO NULL, description TEXT, createdAt INTEGER NOT NULL, finishedAt INTEGER, startDate INTEGER, dueDate INTEGER)',
  ),
  habit(
    '(id INTEGER PRIMARY KEY, title TEXT NO NULL, description TEXT, createdAt INTEGER NOT NULL, interval TEXT NOT NULL, days TEXT, emoji TEXT)',
  ),
  ;

  const DatabaseTables(this.creationQueryColumns);

  final String creationQueryColumns;
}

const Set<String> databaseTables = {
  Mood.databaseRowName,
  Todo.databaseRowName,
};

Future<void> upgradeSchema(
  Database database,
  int oldVersion,
  int newVersion,
) async {
  debugPrint('Upgrade Database from version $oldVersion to $newVersion');

  if (oldVersion == 1 && newVersion == 2) {
    debugPrint('Add column Mood.label');
    await database
        .execute('ALTER TABLE ${Mood.databaseRowName} ADD COLUMN label TEXT');
  }
}

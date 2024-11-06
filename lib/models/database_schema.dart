import 'package:flutter/widgets.dart';

import 'package:sqflite/sqflite.dart';

import 'package:mood_n_habbits/models/mood.dart';
import 'package:mood_n_habbits/models/todo.dart';

Future<void> createSchema(Database database) async {
  await database.execute(
    'CREATE TABLE IF NOT EXISTS ${Mood.databaseRowName} (id INTEGER PRIMARY KEY, mood INTEGER NOT NULL, time INTEGER NOT NULL, label TEXT)',
  );
  await database.execute(
    'CREATE TABLE IF NOT EXISTS ${Todo.databaseRowName} (id INTEGER PRIMARY KEY, todo TEXT NOT NULL, description TEXT, createdAt INTEGER NOT NULL, finishedAt INTEGER NOT NULL)',
  );
  return;
}

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

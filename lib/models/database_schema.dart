import 'package:flutter/widgets.dart';

import 'package:sqflite/sqflite.dart';

import 'package:mood_n_habbits/models/mood.dart';

Future<void> createSchema(Database database, int version) async {
  await database.execute(
    'CREATE TABLE ${Mood.databaseRowName} (id INTEGER PRIMARY KEY, mood INTEGER NOT NULL, time INTEGER NOT NULL, label TEXT)',
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

import 'package:sqflite/sqflite.dart';

import 'package:mood_n_habbits/models/mood.dart';

Future<void> createSchema(Database database, int version) async {
  await database.execute(
    'CREATE TABLE ${Mood.databaseRowName} (id INTEGER PRIMARY KEY, mood INTEGER NOT NULL, time INTEGER NOT NULL)',
  );
  return;
}

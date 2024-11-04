import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:mood_n_habbits/config/app_constants.dart';
import 'package:mood_n_habbits/models/database_schema.dart';
import 'package:mood_n_habbits/models/mood.dart';

class AppState {
  final Database _database;
  final SharedPreferences _sharedPreferences;

  const AppState._(this._database, this._sharedPreferences);

  static Future<AppState> init() async {
    final directory = await getDatabasesPath();
    return AppState._(
      await openDatabase(
        path.join(directory, '${AppConstants.applicationName}.sqflite'),
        onCreate: createSchema,
        version: 1,
      ),
      await SharedPreferences.getInstance(),
    );
  }

  ThemeMode get themeMode {
    final storedThemeMode = _sharedPreferences.getString('theme_mode');
    if (storedThemeMode == null) return ThemeMode.system;
    return ThemeMode.values
            .singleWhereOrNull((mode) => mode.name == storedThemeMode) ??
        ThemeMode.system;
  }

  Future<void> addMood(Mood mood) => _database.insert(
        Mood.databaseRowName,
        mood.toDatabaseRow(),
      );

  Future<void> deleteMood(int id) => _database.delete(
        Mood.databaseRowName,
        where: 'id=?',
        whereArgs: [id],
      );

  Future<List<Mood>> getMoods(DateTime since) => _database.query(
        Mood.databaseRowName,
        orderBy: 'time DESC',
        where: 'time > ?',
        whereArgs: [since.millisecondsSinceEpoch],
      ).then((rows) => rows.map((row) => Mood.fromDatabaseRow(row)).toList());
}

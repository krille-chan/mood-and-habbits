import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:mood_n_habbits/config/app_constants.dart';
import 'package:mood_n_habbits/models/database_schema.dart';
import 'package:mood_n_habbits/models/mood.dart';
import 'package:mood_n_habbits/models/preferences_extensions.dart';

class AppState {
  final Database _database;
  final SharedPreferences _sharedPreferences;

  const AppState._(this._database, this._sharedPreferences, this.theme);

  final ValueNotifier<({Color? primaryColor, ThemeMode? themeMode})> theme;

  static Future<AppState> init() async {
    final directory = await getDatabasesPath();
    final preferences = await SharedPreferences.getInstance();

    return AppState._(
      await openDatabase(
        path.join(directory, '${AppConstants.applicationName}.sqflite'),
        onOpen: createSchema,
        onUpgrade: upgradeSchema,
        version: 2,
      ),
      preferences,
      ValueNotifier(
        (
          primaryColor: preferences.themeColor,
          themeMode: preferences.themeMode,
        ),
      ),
    );
  }

  Future<void> resetAllData() => _database.transaction(
        (transaction) =>
            Future.wait(databaseTables.map((db) => transaction.delete(db))),
      );

  Future<String> exportDataAsJson() async {
    final json = <String, Object?>{};
    for (final table in databaseTables) {
      json[table] = await _database.query(table);
    }
    return jsonEncode(json);
  }

  Future<int> importDataFromJson(Map<String, Object?> json) async {
    var counter = 0;
    await _database.transaction((transaction) async {
      for (final table in databaseTables) {
        final rows = List<Map<String, Object?>>.from(json[table] as List);
        for (final row in rows) {
          final result = await transaction.insert(
            table,
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          if (result != 0) counter++;
        }
      }
    });
    return counter;
  }

  void setThemeColor(Color? color) async {
    color == null
        ? await _sharedPreferences.remove('primary_color')
        : await _sharedPreferences.setInt(
            'primary_color',
            color.value,
          );
    theme.value = (
      primaryColor: _sharedPreferences.themeColor,
      themeMode: _sharedPreferences.themeMode,
    );
  }

  void setThemeMode(ThemeMode mode) async {
    await _sharedPreferences.setString(
      'theme_mode',
      mode.name,
    );
    theme.value = (
      primaryColor: _sharedPreferences.themeColor,
      themeMode: _sharedPreferences.themeMode,
    );
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

  Future<List<Mood>> getMoods(DateTime since, DateTime until) =>
      _database.query(
        Mood.databaseRowName,
        orderBy: 'time DESC',
        where: 'time > ? AND time <= ?',
        whereArgs: [since.millisecondsSinceEpoch, until.millisecondsSinceEpoch],
      ).then((rows) => rows.map((row) => Mood.fromDatabaseRow(row)).toList());
}

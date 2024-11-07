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

  Future<List<Mood>> getMoods(DateTime since) => _database.query(
        Mood.databaseRowName,
        orderBy: 'time DESC',
        where: 'time > ?',
        whereArgs: [since.millisecondsSinceEpoch],
      ).then((rows) => rows.map((row) => Mood.fromDatabaseRow(row)).toList());
}

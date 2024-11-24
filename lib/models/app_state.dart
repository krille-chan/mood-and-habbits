import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:mood_n_habits/config/app_constants.dart';
import 'package:mood_n_habits/models/database_schema.dart';
import 'package:mood_n_habits/models/mood.dart';
import 'package:mood_n_habits/models/preferences_extensions.dart';
import 'package:mood_n_habits/models/todo.dart';

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
        version: 1,
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

  Future<void> createTodo(Todo todo) async {
    final minSortOrderResult = await _database.query(
      Todo.databaseRowName,
      columns: ['min(sortOrder)'],
    );
    final minSortOrder =
        (minSortOrderResult.singleOrNull?['min(sortOrder)'] as int?) ?? 0;

    await _database.insert(
      Todo.databaseRowName,
      {
        ...todo.toDatabaseRow(),
        'sortOrder': minSortOrder - 1,
      },
    );
  }

  Future<void> updateTodo(Todo todo) => _database.update(
        Todo.databaseRowName,
        todo.toDatabaseRow(),
        where: 'id = ?',
        whereArgs: [todo.databaseId],
      );

  Future<void> deleteTodo(int id) => _database.delete(
        Todo.databaseRowName,
        where: 'id = ?',
        whereArgs: [id],
      );

  Future<void> clearFinishedTodos() => _database.delete(
        Todo.databaseRowName,
        where: 'finishedAt IS NOT NULL',
      );

  Future<List<Todo>> getAllTodos({DateTime? activeForDate}) {
    final today = activeForDate == null
        ? null
        : DateTime(
            activeForDate.year,
            activeForDate.month,
            activeForDate.day,
          );
    final todayEnd = today?.add(const Duration(days: 1));
    return _database
        .query(
          Todo.databaseRowName,
          orderBy: 'sortOrder',
          where: today != null && todayEnd != null
              ? '(finishedAt >= ? AND finishedAt < ?) OR (finishedAt IS NULL AND startDate IS NULL) OR (finishedAT IS NULL AND startDate < ?)'
              : null,
          whereArgs: today != null && todayEnd != null
              ? [
                  today.millisecondsSinceEpoch,
                  todayEnd.millisecondsSinceEpoch,
                  today.millisecondsSinceEpoch,
                ]
              : null,
        )
        .then(
          (rows) => rows.map((json) => Todo.fromDatabaseRow(json)).toList(),
        );
  }

  Future<void> changeTodoOrders(Todo from, Todo to) {
    assert(from.databaseId != to.databaseId);

    return _database.transaction((transaction) async {
      if (to.sortOrder! > from.sortOrder!) {
        await transaction.rawUpdate(
          'UPDATE ${Todo.databaseRowName} SET sortOrder = sortOrder-1 WHERE sortOrder <= ?',
          [to.sortOrder],
        );
      } else {
        await transaction.rawUpdate(
          'UPDATE ${Todo.databaseRowName} SET sortOrder = sortOrder+1 WHERE sortOrder >= ?',
          [to.sortOrder],
        );
      }
      await transaction.update(
        Todo.databaseRowName,
        {'sortOrder': to.sortOrder},
        where: 'id = ?',
        whereArgs: [from.databaseId],
      );
    });
  }
}

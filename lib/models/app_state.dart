import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:mood_n_habits/config/app_constants.dart';
import 'package:mood_n_habits/models/database_schema.dart';
import 'package:mood_n_habits/models/habit.dart';
import 'package:mood_n_habits/models/habit_achieved.dart';
import 'package:mood_n_habits/models/mood.dart';
import 'package:mood_n_habits/models/preferences_extensions.dart';
import 'package:mood_n_habits/models/todo.dart';
import 'package:mood_n_habits/utils/same_day.dart';

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
        (transaction) => Future.wait(
          DatabaseTables.values.map((db) => transaction.delete(db.name)),
        ),
      );

  Future<String> exportDataAsJson() async {
    final json = <String, Object?>{};
    for (final table in DatabaseTables.values) {
      json[table.name] = await _database.query(table.name);
    }
    return jsonEncode(json);
  }

  Future<int> importDataFromJson(Map<String, Object?> json) async {
    var counter = 0;
    await _database.transaction((transaction) async {
      for (final table in DatabaseTables.values) {
        final rows = List<Map<String, Object?>>.from(json[table.name] as List);
        for (final row in rows) {
          final result = await transaction.insert(
            table.name,
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
      DatabaseTables.todo.name,
      columns: ['min(sortOrder)'],
    );
    final minSortOrder =
        (minSortOrderResult.singleOrNull?['min(sortOrder)'] as int?) ?? 0;

    await _database.insert(
      DatabaseTables.todo.name,
      {
        ...todo.toDatabaseRow(),
        'sortOrder': minSortOrder - 1,
      },
    );
  }

  Future<void> createHabit(Habit habit) async {
    final minSortOrderResult = await _database.query(
      DatabaseTables.habit.name,
      columns: ['min(sortOrder)'],
    );
    final minSortOrder =
        (minSortOrderResult.singleOrNull?['min(sortOrder)'] as int?) ?? 0;

    await _database.insert(
      DatabaseTables.habit.name,
      {
        ...habit.toDatabaseRow(),
        'sortOrder': minSortOrder - 1,
      },
    );
  }

  Future<List<({Habit habit, List<HabitAchieved> achieved})>> getAllHabits({
    DateTime? activeForDate,
  }) async {
    final date = activeForDate?.dateOnly;

    final allHabits = await _database
        .query(
          DatabaseTables.habit.name,
          orderBy: 'sortOrder',
        )
        .then(
          (rows) => rows.map((json) => Habit.fromDatabaseRow(json)).toList(),
        );

    if (date != null) {
      allHabits.removeWhere((habit) {
        switch (habit.interval) {
          case HabitInterval.continuesly:
          case HabitInterval.daily:
            return false;
          case HabitInterval.daysInWeek:
            return habit.days?.contains(date.weekday % 7) == false;
          case HabitInterval.daysInMonth:
            return habit.days?.contains(date.day) == false;
        }
      });
    }

    final habitAchievedSince = date?.millisecondsSinceEpoch ??
        DateTime.now()
            .subtract(const Duration(days: 10))
            .dateOnly
            .millisecondsSinceEpoch;

    final habitAndAchievedMap = <({
      Habit habit,
      List<HabitAchieved> achieved,
    })>[];

    for (final habit in allHabits) {
      habitAndAchievedMap.add(
        (
          habit: habit,
          achieved: await _database.query(
            DatabaseTables.habitAchieved.name,
            where: 'habitId = ? AND createdAt >= ?',
            whereArgs: [habit.databaseId, habitAchievedSince],
          ).then(
            (rows) =>
                rows.map((row) => HabitAchieved.fromDatabaseRow(row)).toList(),
          ),
        ),
      );
    }

    return habitAndAchievedMap;
  }

  Future<void> updateHabit(Habit habit) => _database.update(
        DatabaseTables.habit.name,
        habit.toDatabaseRow(),
        where: 'id = ?',
        whereArgs: [habit.databaseId],
      );

  Future<void> deleteHabit(int id) => _database.delete(
        DatabaseTables.habit.name,
        where: 'id = ?',
        whereArgs: [id],
      );

  Future<void> updateTodo(Todo todo) => _database.update(
        DatabaseTables.todo.name,
        todo.toDatabaseRow(),
        where: 'id = ?',
        whereArgs: [todo.databaseId],
      );

  Future<void> deleteTodo(int id) => _database.delete(
        DatabaseTables.todo.name,
        where: 'id = ?',
        whereArgs: [id],
      );

  Future<void> clearFinishedTodos() => _database.delete(
        DatabaseTables.todo.name,
        where: 'finishedAt IS NOT NULL',
      );

  Future<List<Todo>> getAllTodos({DateTime? activeForDate}) {
    final today = activeForDate?.dateOnly;
    final todayEnd = today?.add(const Duration(days: 1));
    return _database
        .query(
          DatabaseTables.todo.name,
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

  Future<void> createHabitAchieved(HabitAchieved achieved) => _database.insert(
        DatabaseTables.habitAchieved.name,
        achieved.toDatabaseRow(),
      );

  Future<void> deleteHabitAchieved(int habitId, DateTime date) =>
      _database.delete(
        DatabaseTables.habitAchieved.name,
        where: 'habitId = ? AND createdAt >= ? AND createdAt < ?',
        whereArgs: [
          habitId,
          date.millisecondsSinceEpoch,
          date.add(const Duration(days: 1)).millisecondsSinceEpoch,
        ],
      );

  Future<void> changeTodoOrders(Todo from, Todo to) => _changeSortOrders(
        DatabaseTables.todo.name,
        from.databaseId!,
        to.databaseId!,
        from.sortOrder!,
        to.sortOrder!,
      );

  Future<void> changeHabitOrders(Habit from, Habit to) => _changeSortOrders(
        DatabaseTables.habit.name,
        from.databaseId!,
        to.databaseId!,
        from.sortOrder!,
        to.sortOrder!,
      );

  Future<void> _changeSortOrders(
    String table,
    int fromDatabaseId,
    int toDatabaseId,
    int fromSortOrder,
    int toSortOrder,
  ) {
    assert(fromDatabaseId != toDatabaseId);

    return _database.transaction((transaction) async {
      if (toSortOrder > fromSortOrder) {
        await transaction.rawUpdate(
          'UPDATE $table SET sortOrder = sortOrder-1 WHERE sortOrder <= ?',
          [toSortOrder],
        );
      } else {
        await transaction.rawUpdate(
          'UPDATE $table SET sortOrder = sortOrder+1 WHERE sortOrder >= ?',
          [toSortOrder],
        );
      }
      await transaction.update(
        table,
        {'sortOrder': toSortOrder},
        where: 'id = ?',
        whereArgs: [fromDatabaseId],
      );
    });
  }
}

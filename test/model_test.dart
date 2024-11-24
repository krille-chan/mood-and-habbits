// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:mood_n_habits/models/habit.dart';
import 'package:mood_n_habits/models/habit_achieved.dart';
import 'package:mood_n_habits/models/mood.dart';
import 'package:mood_n_habits/models/todo.dart';

void main() {
  test('Moods', () {
    final mood = Mood(
      databaseId: 0,
      mood: MoodValue.good,
      label: 'test',
      dateTime: DateTime.now(),
    );
    expect(
      Mood.fromDatabaseRow(mood.toDatabaseRow()).toDatabaseRow(),
      mood.toDatabaseRow(),
    );
  });
  test('Todos', () {
    final todo = Todo(
      databaseId: 0,
      title: 'test',
      createdAt: DateTime.now(),
      finishedAt: DateTime.now(),
      dueDate: DateTime.now(),
      description: 'test',
      sortOrder: 3,
    );
    expect(
      Todo.fromDatabaseRow(todo.toDatabaseRow()).toDatabaseRow(),
      todo.toDatabaseRow(),
    );
  });
  test('Habits', () {
    final habit = Habit(
      databaseId: 0,
      title: 'test',
      createdAt: DateTime.now(),
      description: 'test',
      interval: HabitInterval.daysInWeek,
      days: [0, 3],
      emoji: '',
    );
    expect(
      Habit.fromDatabaseRow(habit.toDatabaseRow()).toDatabaseRow(),
      habit.toDatabaseRow(),
    );
  });
  test('HabitAchieved', () {
    final habitAchieved = HabitAchieved(
      databaseId: 0,
      label: 'test',
      createdAt: DateTime.now(),
      habitId: 0,
      value: HabitAchievedValue.notAchieved,
    );
    expect(
      HabitAchieved.fromDatabaseRow(habitAchieved.toDatabaseRow())
          .toDatabaseRow(),
      habitAchieved.toDatabaseRow(),
    );
  });
}

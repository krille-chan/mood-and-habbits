// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:mood_n_habbits/models/habbit.dart';
import 'package:mood_n_habbits/models/mood.dart';
import 'package:mood_n_habbits/models/todo.dart';

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
    );
    expect(
      Todo.fromDatabaseRow(todo.toDatabaseRow()).toDatabaseRow(),
      todo.toDatabaseRow(),
    );
  });
  test('Habbits', () {
    final habbit = Habbit(
      databaseId: 0,
      title: 'test',
      createdAt: DateTime.now(),
      description: 'test',
      interval: HabbitInterval.daysInWeek,
      days: [0, 3],
      emoji: '',
    );
    expect(
      Habbit.fromDatabaseRow(habbit.toDatabaseRow()).toDatabaseRow(),
      habbit.toDatabaseRow(),
    );
  });
}

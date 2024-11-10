import 'package:flutter/material.dart';

import 'package:mood_n_habbits/models/app_state.dart';
import 'package:mood_n_habbits/models/todo.dart';
import 'package:mood_n_habbits/pages/todos/todo_creation_bottom_sheet.dart';

class TodosPageState {
  final AppState appState;

  TodosPageState(this.appState) {
    _loadTodos();
  }

  final ValueNotifier<({List<Todo>? todos, bool reordering})> data =
      ValueNotifier(
    (
      todos: null,
      reordering: false,
    ),
  );

  void _loadTodos() async {
    final todos = await appState.getAllTodos();
    data.value = (todos: todos, reordering: data.value.reordering);
  }

  void toggleDone(Todo todo, bool done) async {
    await appState.updateTodo(
      Todo(
        databaseId: todo.databaseId,
        title: todo.title,
        description: todo.description,
        createdAt: todo.createdAt,
        finishedAt: done ? DateTime.now() : null,
        startDate: todo.startDate,
        dueDate: todo.dueDate,
      ),
    );
    _loadTodos();
  }

  void clearFinished() async {
    await appState.clearFinishedTodos();
    _loadTodos();
  }

  void toggleReordering() => data.value =
      (todos: data.value.todos, reordering: !data.value.reordering);

  void createTodo(BuildContext context) async {
    final todo = await showModalBottomSheet<Todo>(
      context: context,
      builder: (context) => TodoCreationBottomSheet(),
    );
    if (todo == null) return;
    if (!context.mounted) return;

    await appState.createTodo(todo);
    _loadTodos();
  }
}

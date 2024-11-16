import 'package:flutter/material.dart';

import 'package:mood_n_habbits/models/app_state.dart';
import 'package:mood_n_habbits/models/todo.dart';
import 'package:mood_n_habbits/pages/todos/todo_creation_bottom_sheet.dart';

mixin TodosStateMixin {
  late AppState appState;

  bool finishedAtBottom = true;
  bool onlyActive = false;

  final ValueNotifier<List<Todo>?> todos = ValueNotifier(null);

  void loadTodos({bool shouldNotBeChanged = false}) async {
    final newTodos = await appState.getAllTodos(
      finishedAtBottom: finishedAtBottom,
      onlyActive: onlyActive,
    );
    if (shouldNotBeChanged) {
      final hasChanged = newTodos.map((todo) => todo.databaseId) !=
          todos.value?.map((todo) => todo.databaseId);
      assert(!hasChanged);
      if (!hasChanged) return;
    }
    todos.value = newTodos;
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
    loadTodos();
  }

  void editTodo(BuildContext context, Todo initialTodo) async {
    final todo = await showModalBottomSheet<Todo>(
      context: context,
      builder: (context) => TodoCreationBottomSheet(initialTodo: initialTodo),
    );
    if (todo == null) return;
    if (!context.mounted) return;

    await appState.updateTodo(todo);
    loadTodos();
  }

  void deleteTodo(int id) async {
    await appState.deleteTodo(id);
    loadTodos();
  }

  void createTodo(BuildContext context) async {
    final todo = await showModalBottomSheet<Todo>(
      context: context,
      builder: (context) => const TodoCreationBottomSheet(),
    );
    if (todo == null) return;
    if (!context.mounted) return;

    await appState.createTodo(todo);
    loadTodos();
  }
}

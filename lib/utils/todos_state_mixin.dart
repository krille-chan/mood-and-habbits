import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_confetti/flutter_confetti.dart';

import 'package:mood_n_habits/models/app_state.dart';
import 'package:mood_n_habits/models/todo.dart';
import 'package:mood_n_habits/widgets/todo_creation_bottom_sheet.dart';

mixin TodosStateMixin {
  late AppState appState;

  DateTime? activeForDate;

  final ValueNotifier<List<Todo>?> todos = ValueNotifier(null);

  void loadTodos({bool shouldNotBeChanged = false}) async {
    final newTodos = await appState.getAllTodos(activeForDate: activeForDate);
    if (shouldNotBeChanged) {
      final hasChanged = newTodos.map((todo) => todo.databaseId) !=
          todos.value?.map((todo) => todo.databaseId);
      assert(!hasChanged);
      if (!hasChanged) return;
    }
    todos.value = newTodos;
  }

  void toggleDone(BuildContext context, Todo todo, bool done) async {
    HapticFeedback.mediumImpact();
    if (done) {
      Confetti.launch(
        context,
        options: const ConfettiOptions(particleCount: 100, spread: 70, y: 0.6),
      );
    }
    await appState.updateTodo(
      Todo(
        databaseId: todo.databaseId,
        title: todo.title,
        description: todo.description,
        createdAt: todo.createdAt,
        finishedAt: done ? DateTime.now() : null,
        startDate: todo.startDate,
        dueDate: todo.dueDate,
        sortOrder: todo.sortOrder,
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

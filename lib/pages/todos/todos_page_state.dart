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

  void _loadTodos({bool shouldNotBeChanged = false}) async {
    final todos = await appState.getAllTodos();
    if (shouldNotBeChanged) {
      final hasChanged = todos.map((todo) => todo.databaseId) !=
          data.value.todos?.map((todo) => todo.databaseId);
      assert(!hasChanged);
      if (!hasChanged) return;
    }
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

  void editTodo(BuildContext context, Todo initialTodo) async {
    final todo = await showModalBottomSheet<Todo>(
      context: context,
      builder: (context) => TodoCreationBottomSheet(initialTodo: initialTodo),
    );
    if (todo == null) return;
    if (!context.mounted) return;

    await appState.updateTodo(todo);
    _loadTodos();
  }

  void clearFinished() async {
    await appState.clearFinishedTodos();
    _loadTodos();
  }

  void deleteTodo(int id) async {
    await appState.deleteTodo(id);
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

  void onReorder(int oldIndex, int newIndex) async {
    final todos = data.value.todos!;

    final fromId = todos[oldIndex].databaseId!;
    final toId = newIndex == 0 ? null : todos[newIndex - 1].databaseId!;

    if (newIndex > oldIndex) newIndex--;
    if (oldIndex == newIndex) return;

    todos.insert(newIndex, todos.removeAt(oldIndex));

    data.value = (reordering: true, todos: todos);

    await appState.changeTodoOrders(fromId, toId);
    _loadTodos(shouldNotBeChanged: false);
  }
}

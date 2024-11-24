import 'package:flutter/material.dart';

import 'package:mood_n_habits/models/app_state.dart';
import 'package:mood_n_habits/utils/todos_state_mixin.dart';

class TodosPageState with TodosStateMixin {
  TodosPageState(AppState appState) {
    this.appState = appState;
    loadTodos();
  }

  final ValueNotifier<bool> reordering = ValueNotifier(false);

  void clearFinished() async {
    await appState.clearFinishedTodos();
    loadTodos();
  }

  void toggleReordering() => reordering.value = !reordering.value;

  void onReorder(int oldIndex, int newIndex) async {
    final todos = this.todos.value!;

    if (newIndex > oldIndex) newIndex--;
    if (oldIndex == newIndex) return;

    final from = todos[oldIndex];
    final to = todos[newIndex];

    todos.insert(newIndex, todos.removeAt(oldIndex));

    this.todos.value = todos;

    await appState.changeTodoOrders(from, to);
    loadTodos(shouldNotBeChanged: false);
  }
}

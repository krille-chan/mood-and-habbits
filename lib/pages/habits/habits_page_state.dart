import 'package:flutter/material.dart';

import 'package:mood_n_habits/models/app_state.dart';
import 'package:mood_n_habits/utils/habits_state_mixin.dart';

class HabitsPageState with HabitsStateMixin {
  HabitsPageState(AppState appState) {
    this.appState = appState;
    loadHabits();
  }

  final ValueNotifier<bool> reordering = ValueNotifier(false);

  void toggleReordering() => reordering.value = !reordering.value;

  void onReorder(int oldIndex, int newIndex) async {
    final habits = this.habits.value!;

    if (newIndex > oldIndex) newIndex--;
    if (oldIndex == newIndex) return;

    final from = habits[oldIndex].habit;
    final to = habits[newIndex].habit;

    habits.insert(newIndex, habits.removeAt(oldIndex));

    this.habits.value = habits;

    await appState.changeHabitOrders(from, to);
    loadHabits();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_confetti/flutter_confetti.dart';

import 'package:mood_n_habits/models/app_state.dart';
import 'package:mood_n_habits/models/habit.dart';
import 'package:mood_n_habits/models/habit_achieved.dart';
import 'package:mood_n_habits/utils/same_day.dart';
import 'package:mood_n_habits/widgets/habit_creation_bottom_sheet.dart';

mixin HabitsStateMixin {
  late AppState appState;

  DateTime? activeForDate;

  final ValueNotifier<
      List<
          ({
            Habit habit,
            List<HabitAchieved> achieved,
          })>?> habits = ValueNotifier(null);

  void loadHabits() async {
    final newHabits = await appState.getAllHabits(activeForDate: activeForDate);

    habits.value = newHabits;
  }

  void editHabit(BuildContext context, Habit initialHabit) async {
    final habit = await showModalBottomSheet<Habit>(
      context: context,
      builder: (context) =>
          HabitCreationBottomSheet(initialHabit: initialHabit),
    );
    if (habit == null) return;
    if (!context.mounted) return;

    await appState.updateHabit(habit);
    loadHabits();
  }

  void deleteHabit(int id) async {
    await appState.deleteHabit(id);
    loadHabits();
  }

  void createHabit(BuildContext context) async {
    final habit = await showModalBottomSheet<Habit>(
      context: context,
      builder: (context) => const HabitCreationBottomSheet(),
    );
    if (habit == null) return;
    if (!context.mounted) return;

    await appState.createHabit(habit);
    loadHabits();
  }

  void setAchieved(
    BuildContext context,
    Habit habit,
    HabitAchievedValue? value,
    DateTime? date,
  ) async {
    HapticFeedback.mediumImpact();
    if (value == HabitAchievedValue.achieved) {
      Confetti.launch(
        context,
        options: const ConfettiOptions(particleCount: 100, spread: 70, y: 0.6),
      );
    }
    date ??= DateTime.now().dateOnly;

    if (value == null || habit.interval != HabitInterval.continuesly) {
      await appState.deleteHabitAchieved(habit.databaseId!, date.dateOnly);
    }
    if (value != null) {
      await appState.createHabitAchieved(
        HabitAchieved(
          createdAt: date,
          habitId: habit.databaseId!,
          label: null,
          value: value,
        ),
      );
    }
    loadHabits();
  }
}

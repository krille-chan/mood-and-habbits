import 'package:flutter/material.dart';

import 'package:mood_n_habbits/models/app_state.dart';
import 'package:mood_n_habbits/models/mood.dart';
import 'package:mood_n_habbits/utils/get_l10n.dart';

class TodayPageState {
  final AppState appState;
  TodayPageState(this.appState);

  final ValueNotifier<DateTime?> date = ValueNotifier(null);

  void addMoodAction(
    BuildContext context,
    MoodValue moodValue,
  ) async {
    await appState.addMood(
      Mood(
        mood: moodValue,
        dateTime: date.value ?? DateTime.now(),
      ),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.hasBeenSaved(moodValue.emoji)),
        showCloseIcon: true,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void setActiveDate(DateTime newDate) => date.value = newDate;

  void changeDate(BuildContext context) async {
    final oldDate = date.value ?? DateTime.now();

    final newDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(
        const Duration(days: 365 * 100),
      ),
      lastDate: DateTime.now(),
      initialDate: date.value ?? DateTime.now(),
    );
    if (newDate == null) return;
    if (!context.mounted) return;

    date.value = DateTime(
      newDate.year,
      newDate.month,
      newDate.day,
      oldDate.hour,
      oldDate.minute,
    );
  }

  void changeMoodTime(BuildContext context) async {
    final oldDate = date.value ?? DateTime.now();
    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(oldDate),
    );
    if (timeOfDay == null) return;
    if (!context.mounted) return;

    date.value = DateTime(
      oldDate.year,
      oldDate.month,
      oldDate.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
  }
}

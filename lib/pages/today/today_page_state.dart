import 'package:flutter/material.dart';

import 'package:mood_n_habbits/models/app_state.dart';
import 'package:mood_n_habbits/models/mood.dart';
import 'package:mood_n_habbits/utils/get_l10n.dart';

class TodayPageState {
  final AppState appState;
  TodayPageState(this.appState);

  final ValueNotifier<DateTime?> newMoodDateTime = ValueNotifier(null);

  void addMoodAction(
    BuildContext context,
    MoodValue moodValue,
  ) async {
    await appState.addMood(
      Mood(
        mood: moodValue,
        dateTime: newMoodDateTime.value ?? DateTime.now(),
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
}

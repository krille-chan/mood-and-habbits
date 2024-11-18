import 'package:flutter/material.dart';

import 'package:mood_n_habits/config/router.dart';
import 'package:mood_n_habits/models/app_state.dart';
import 'package:mood_n_habits/widgets/mood_and_habits_app.dart';

void main() async {
  debugPrint('Starting app "Mood and Habits"...');

  WidgetsFlutterBinding.ensureInitialized();

  final appState = await AppState.init();

  runApp(
    MoodAndHabitsApp(
      appState: appState,
      router: buildRouter(appState),
    ),
  );
}

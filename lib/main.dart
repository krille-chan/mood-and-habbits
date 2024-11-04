import 'package:flutter/material.dart';

import 'package:mood_n_habbits/models/app_state.dart';
import 'package:mood_n_habbits/widgets/mood_and_habbits_app.dart';

void main() async {
  debugPrint('Starting app "Mood and Habbits"...');

  WidgetsFlutterBinding.ensureInitialized();

  final appState = await AppState.init();

  runApp(MoodAndHabbitsApp(appState));
}

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:mood_n_habits/config/router.dart';
import 'package:mood_n_habits/models/app_state.dart';
import 'package:mood_n_habits/widgets/mood_and_habits_app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final appState = await AppState.init();
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MoodAndHabitsApp(
        appState: appState,
        router: buildRouter(appState),
      ),
    );
  });
}

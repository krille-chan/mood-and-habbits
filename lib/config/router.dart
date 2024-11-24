import 'package:go_router/go_router.dart';

import 'package:mood_n_habits/models/app_state.dart';
import 'package:mood_n_habits/pages/habits/habits_page.dart';
import 'package:mood_n_habits/pages/habits/habits_page_state.dart';
import 'package:mood_n_habits/pages/mood_stats/mood_stats_page.dart';
import 'package:mood_n_habits/pages/mood_stats/mood_stats_state.dart';
import 'package:mood_n_habits/pages/settings/settings_page.dart';
import 'package:mood_n_habits/pages/settings/settings_page_state.dart';
import 'package:mood_n_habits/pages/today/today_page.dart';
import 'package:mood_n_habits/pages/today/today_page_state.dart';
import 'package:mood_n_habits/pages/todos/todos_page.dart';
import 'package:mood_n_habits/pages/todos/todos_page_state.dart';
import 'package:mood_n_habits/widgets/bottom_navigation_shell.dart';

GoRouter buildRouter(AppState appState) => GoRouter(
      routes: [
        ShellRoute(
          builder: (context, state, child) => BottomNavigationShell(
            pathSegments: state.fullPath?.split('/') ?? [''],
            child: child,
          ),
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => TodayPage(TodayPageState(appState)),
              routes: [
                GoRoute(
                  path: '/habits',
                  builder: (context, state) =>
                      HabitsPage(HabitsPageState(appState)),
                ),
                GoRoute(
                  path: '/todos',
                  builder: (context, state) =>
                      TodosPage(TodosPageState(appState)),
                ),
                GoRoute(
                  path: '/settings',
                  builder: (context, state) =>
                      SettingsPage(SettingsPageState(appState)),
                ),
                GoRoute(
                  path: '/today/mood_stats',
                  builder: (context, state) =>
                      MoodStatsPage(MoodStatsState(appState)),
                ),
              ],
            ),
          ],
        ),
      ],
    );

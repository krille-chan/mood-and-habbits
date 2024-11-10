import 'package:go_router/go_router.dart';

import 'package:mood_n_habbits/models/app_state.dart';
import 'package:mood_n_habbits/pages/habbits/habbits_page.dart';
import 'package:mood_n_habbits/pages/mood_stats/mood_stats_page.dart';
import 'package:mood_n_habbits/pages/mood_stats/mood_stats_state.dart';
import 'package:mood_n_habbits/pages/settings/settings_page.dart';
import 'package:mood_n_habbits/pages/settings/settings_page_state.dart';
import 'package:mood_n_habbits/pages/today/today_page.dart';
import 'package:mood_n_habbits/pages/today/today_page_state.dart';
import 'package:mood_n_habbits/pages/todos/todos_page.dart';
import 'package:mood_n_habbits/pages/todos/todos_page_state.dart';
import 'package:mood_n_habbits/widgets/bottom_navigation_shell.dart';

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
                  path: '/habbits',
                  builder: (context, state) => const HabbitsPage(),
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

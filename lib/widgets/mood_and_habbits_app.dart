import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:mood_n_habbits/config/app_constants.dart';
import 'package:mood_n_habbits/config/theme.dart';
import 'package:mood_n_habbits/models/app_state.dart';

class MoodAndHabbitsApp extends StatelessWidget {
  final AppState appState;
  final GoRouter router;

  const MoodAndHabbitsApp({
    required this.appState,
    required this.router,
    super.key,
  });

  static final GlobalKey routerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (light, dark) => ValueListenableBuilder(
        valueListenable: appState.theme,
        builder: (context, appTheme, _) {
          return MaterialApp.router(
            key: routerKey,
            title: AppConstants.applicationName,
            routerConfig: router,
            theme: buildTheme(
              Brightness.light,
              appTheme.primaryColor ?? light?.primary,
            ),
            darkTheme: buildTheme(
              Brightness.dark,
              appTheme.primaryColor ?? dark?.primary,
            ),
            themeMode: appTheme.themeMode,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}

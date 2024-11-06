import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:mood_n_habbits/config/app_constants.dart';
import 'package:mood_n_habbits/config/router.dart';
import 'package:mood_n_habbits/config/theme.dart';
import 'package:mood_n_habbits/models/app_state.dart';

class MoodAndHabbitsApp extends StatelessWidget {
  final AppState appState;

  const MoodAndHabbitsApp(this.appState, {super.key});

  static final GlobalKey router = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (light, dark) => MaterialApp.router(
        key: router,
        title: AppConstants.applicationName,
        routerConfig: buildRouter(appState),
        theme: buildTheme(
          Brightness.light,
          appState.getColorScheme(Brightness.light) ?? light,
        ),
        darkTheme: buildTheme(
          Brightness.dark,
          appState.getColorScheme(Brightness.light) ?? dark,
        ),
        themeMode: appState.themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}

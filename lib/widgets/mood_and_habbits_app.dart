import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:mood_n_habbits/config/app_constants.dart';
import 'package:mood_n_habbits/config/router.dart';
import 'package:mood_n_habbits/models/app_state.dart';

class MoodAndHabbitsApp extends StatelessWidget {
  final AppState appState;

  const MoodAndHabbitsApp(this.appState, {super.key});

  static final GlobalKey router = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      key: router,
      title: AppConstants.applicationName,
      routerConfig: buildRouter(appState),
      themeMode: appState.themeMode,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

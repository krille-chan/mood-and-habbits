import 'package:flutter/material.dart';

import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension PreferencesExtensions on SharedPreferences {
  Color? get themeColor {
    final storedColorInt = getInt('primary_color');
    if (storedColorInt == null) return null;
    return Result(() => Color(storedColorInt)).asValue?.value;
  }

  ThemeMode get themeMode {
    final storedThemeMode = getString('theme_mode');
    if (storedThemeMode == null) return ThemeMode.system;
    return ThemeMode.values
            .singleWhereOrNull((mode) => mode.name == storedThemeMode) ??
        ThemeMode.system;
  }
}

import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness, ColorScheme? colorScheme) =>
    ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );

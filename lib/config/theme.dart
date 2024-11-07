import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness, Color? color) => ThemeData(
      brightness: brightness,
      colorSchemeSeed: color,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );

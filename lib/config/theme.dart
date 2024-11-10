import 'package:flutter/material.dart';

ThemeData buildTheme(Brightness brightness, Color? color) => ThemeData(
      brightness: brightness,
      colorSchemeSeed: color,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        border: UnderlineInputBorder(),
      ),
    );

const List<Color?> customColors = [
  null,
  Colors.indigo,
  Colors.blue,
  Colors.blueAccent,
  Colors.teal,
  Colors.tealAccent,
  Colors.green,
  Colors.greenAccent,
  Colors.yellow,
  Colors.yellowAccent,
  Colors.orange,
  Colors.orangeAccent,
  Colors.red,
  Colors.redAccent,
  Colors.pink,
  Colors.pinkAccent,
  Colors.purple,
  Colors.purpleAccent,
  Colors.blueGrey,
  Colors.grey,
];

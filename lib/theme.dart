import 'package:flutter/material.dart';

const seedColor = Colors.deepPurple;

final lightTheme = ThemeData.from(
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
);

final darkTheme = ThemeData.from(
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);

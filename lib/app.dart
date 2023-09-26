import 'dart:ui';

import 'package:flutter/material.dart';

import 'utils/prefs.dart';
import 'pages/home_page/home_page.dart';
import 'theme.dart' as theme;

class App extends StatefulWidget {
  const App({super.key});

  static void changeThemeMode(BuildContext context, ThemeMode mode) {
    final state = context.findAncestorStateOfType<_AppState>()!;
    state.changeThemeMode(mode);
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _themeMode = switch (prefs.getString("theme_mode")) {
      "light" => ThemeMode.light,
      "dark" => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Combinat",
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.touch,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.unknown,
        },
        scrollbars: true,
      ),
      themeMode: _themeMode,
      theme: theme.lightTheme,
      darkTheme: theme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
      },
    );
  }

  void changeThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }
}

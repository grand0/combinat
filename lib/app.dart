import 'dart:ui';

import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'theme.dart' as theme;

class App extends StatefulWidget {
  const App({super.key});

  static void switchThemeMode(BuildContext context) {
    final state = context.findAncestorStateOfType<_AppState>()!;
    final themeMode = switch (Theme.of(context).brightness) {
      Brightness.light => ThemeMode.dark,
      Brightness.dark => ThemeMode.light,
    };
    state.changeThemeMode(themeMode);
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeMode _themeMode = ThemeMode.system;

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

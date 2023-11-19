import 'dart:math';

import 'package:flutter/material.dart';

import '../../app.dart';
import '../../utils/prefs.dart';

class SettingsDestination extends StatefulWidget {
  const SettingsDestination({super.key});

  @override
  State<SettingsDestination> createState() => _SettingsDestinationState();
}

class _SettingsDestinationState extends State<SettingsDestination> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: min(MediaQuery.of(context).size.width, 400),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              ListTile(
                title: const Text("Theme mode"),
                trailing: DropdownButton<ThemeMode>(
                  value: switch (prefs.getString("theme_mode")) {
                    "light" => ThemeMode.light,
                    "dark" => ThemeMode.dark,
                    _ => ThemeMode.system,
                  },
                  onChanged: (value) {
                    App.changeThemeMode(context, value ?? ThemeMode.system);
                    setState(() {
                      final prefValue = switch (value) {
                        ThemeMode.light => "light",
                        ThemeMode.dark => "dark",
                        _ => "system",
                      };
                      prefs.setString("theme_mode", prefValue);
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text("System"),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text("Light"),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text("Dark"),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text("Fraction digits"),
                trailing: DropdownButton<int>(
                  value: prefs.getInt("fraction_digits") ?? -1,
                  onChanged: (value) {
                    setState(() {
                      prefs.setInt("fraction_digits", value ?? -1);
                    });
                  },
                  items: List.generate(
                    11,
                        (index) {
                      if (index == 0) {
                        return const DropdownMenuItem(
                          value: -1,
                          child: Text("Not fixed"),
                        );
                      }
                      return DropdownMenuItem(
                        value: index,
                        child: Text("$index"),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 64),
              Image.asset(
                "assets/icon.png",
                width: 96,
                height: 96,
              ),
              const Text(
                "combinat",
                style: TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const Text(
                "v1.5.1",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

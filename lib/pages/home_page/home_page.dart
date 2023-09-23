import 'package:combinat/responsive.dart';
import 'package:flutter/material.dart';

import 'formulas_destination.dart';
import 'models_destination.dart';
import 'settings_destination.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> pages = [
    const FormulasDestination(),
    const ModelsDestination(),
    const SettingsDestination(),
  ];

  int index = 0;
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (MediaQuery.of(context).size.width >= 640)
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    hovering = true;
                  });
                },
                onExit: (_) {
                  setState(() {
                    hovering = false;
                  });
                },
                child: NavigationRail(
                  elevation: 2.0,
                  onDestinationSelected: (index) {
                    setState(() {
                      this.index = index;
                    });
                  },
                  selectedIndex: index,
                  labelType: isPointerDevice(context)
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.selected,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.calculate_outlined),
                      selectedIcon: Icon(Icons.calculate),
                      label: Text("Formulas"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.lightbulb_outline),
                      selectedIcon: Icon(Icons.lightbulb),
                      label: Text("Models"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text("Settings"),
                    ),
                  ],
                  groupAlignment: 0.0,
                  extended: isPointerDevice(context) ? hovering : false,
                  leading: Image.asset(
                    "assets/icon.png",
                    width: 48,
                  ),
                ),
              ),
            Expanded(
              child: pages[index],
            ),
          ],
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 640
          ? BottomNavigationBar(
              currentIndex: index,
              onTap: (index) {
                setState(() {
                  this.index = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.calculate_outlined),
                  activeIcon: Icon(Icons.calculate),
                  label: "Formulas",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.lightbulb_outline),
                  activeIcon: Icon(Icons.lightbulb),
                  label: "Models",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: "Settings",
                ),
              ],
            )
          : null,
    );
  }
}

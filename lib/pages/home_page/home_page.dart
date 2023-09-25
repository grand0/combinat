import 'package:combinat/pages/common/resizable_panel.dart';
import 'package:combinat/responsive.dart';
import 'package:flutter/material.dart';

import '../common/history_widget.dart';
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
  bool showHistory = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (isWideEnough(context))
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
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  pages[index],
                  if (index != 2)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton.filledTonal(
                        onPressed: () {
                          if (isWideEnough(context)) {
                            setState(() {
                              showHistory = !showHistory;
                            });
                          } else {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) => const HistoryWidget(),
                            );
                          }
                        },
                        isSelected: isWideEnough(context) && showHistory,
                        icon: const Icon(Icons.history),
                      ),
                    ),
                ],
              ),
            ),
            ResizablePanel(
              initialWidth: 300,
              minWidth: 200,
              maxWidth: 400,
              show: isWideEnough(context) && showHistory && index != 2,
              child: HistoryWidget(),
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

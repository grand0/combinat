import 'dart:math';

import 'package:combinat/app.dart';
import 'package:combinat/math/formulas.dart';
import 'package:combinat/math/models.dart';
import 'package:combinat/pages/common/number_field.dart';
import 'package:combinat/pages/common/result_widget.dart';
import 'package:combinat/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../math/fraction.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> pages = [
    const FormulasPage(),
    const ModelsPage(),
    const SettingsPage(),
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

class FormulasPage extends StatefulWidget {
  const FormulasPage({super.key});

  @override
  State<FormulasPage> createState() => _FormulasPageState();
}

class _FormulasPageState extends State<FormulasPage> {
  final _formKey = GlobalKey<FormState>();
  BigInt? _result;
  Formula _formula = Formula.placementsNoRep;
  bool _hovering = false;
  List<Widget> _fields = [];
  List<TextEditingController> _controllers = [];
  bool _firstBuild = true;
  List<int> _multiVarLastIndexes = [];
  List<int> _multiVarCounts = [];

  @override
  Widget build(BuildContext context) {
    if (_firstBuild) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _firstBuild = false;
          _rebuildVariableFields();
        });
      });
    }
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: min(MediaQuery.of(context).size.width, 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButton<Formula>(
                        isExpanded: true,
                        value: _formula,
                        items: Formula.values
                            .map<DropdownMenuItem<Formula>>(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _formula = value!;
                            _rebuildVariableFields();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Math.tex(
                          _formula.tex,
                          textStyle: TextStyle(
                            fontSize: 28,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final field in _fields) ...[
                        field,
                        const SizedBox(height: 16),
                      ],
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.decelerate,
                        width: _hovering ? 240 : 180,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                final vars = _controllers
                                    .map((e) => BigInt.parse(e.text))
                                    .toList();
                                try {
                                  _result = _formula.calculate(vars);
                                } on FormulaException catch (e) {
                                  _showSnackBar(
                                    icon: Icon(
                                      Icons.error_outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    ),
                                    text: Text("${e.message}"),
                                  );
                                } catch (e) {
                                  _showSnackBar(
                                    icon: const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                                    text: Text("$e"),
                                  );
                                }
                              });
                            }
                          },
                          onHover: (hover) {
                            if (hover != _hovering) {
                              setState(() {
                                _hovering = hover;
                              });
                            }
                          },
                          child: const Text("Calculate"),
                        ),
                      ),
                      if (_result != null) ...[
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: "$_result"));
                            _showSnackBar(
                              icon: Icon(
                                Icons.copy,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                              ),
                              text: Text("Copied $_result"),
                            );
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 24.0,
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontSize: 28),
                                    children: <TextSpan>[
                                      const TextSpan(
                                        text: "= ",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      TextSpan(
                                        text: "$_result",
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 24,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      stops: const [0.2, 1.0],
                                      colors: [
                                        Theme.of(context)
                                            .colorScheme
                                            .background,
                                        Theme.of(context)
                                            .colorScheme
                                            .background
                                            .withAlpha(0),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: 24,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      stops: const [0.0, 0.8],
                                      colors: [
                                        Theme.of(context)
                                            .colorScheme
                                            .background
                                            .withAlpha(0),
                                        Theme.of(context)
                                            .colorScheme
                                            .background,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _rebuildVariableFields() {
    _controllers = <TextEditingController>[];
    _multiVarLastIndexes = <int>[];
    _multiVarCounts = <int>[];

    _fields = _formula.variables.map<Widget>(
      (e) {
        final controller = TextEditingController(text: "0");
        _controllers.add(controller);
        return NumberField(
          controller: controller,
          decoration: InputDecoration(
            prefixIconConstraints: const BoxConstraints.tightForFinite(),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Math.tex(
                "$e=",
                textStyle: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            isDense: true,
          ),
          validator: (input) {
            if (input == null || input.isEmpty) {
              return "Can't be empty";
            }
            return null;
          },
        );
      },
    ).toList();

    for (int i = 0; i < _formula.multiVariables.length; i++) {
      final multiVar = _formula.multiVariables[i];
      final controller = TextEditingController(text: "0");
      _controllers.add(controller);
      _fields.add(
        NumberField(
          controller: controller,
          decoration: InputDecoration(
            prefixIconConstraints: const BoxConstraints.tightForFinite(),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Math.tex(
                "${multiVar}_1=",
                textStyle: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            isDense: true,
          ),
          validator: (input) {
            if (input == null || input.isEmpty) {
              return "Can't be empty";
            }
            return null;
          },
        ),
      );
      _fields.add(
        TextButton.icon(
          onPressed: () {
            setState(() {
              final indexToInsertField = _multiVarLastIndexes[i];
              _multiVarCounts[i]++;
              for (int j = i; j < _multiVarLastIndexes.length; j++) {
                _multiVarLastIndexes[j]++;
              }
              final controller = TextEditingController(text: "0");
              int indexToInsertController = _formula.variables.length;
              for (int j = 0; j <= i; j++) {
                indexToInsertController += _multiVarCounts[j];
              }
              indexToInsertController--;
              _controllers.insert(indexToInsertController, controller);
              _fields.insert(
                indexToInsertField,
                NumberField(
                  controller: controller,
                  decoration: InputDecoration(
                    prefixIconConstraints:
                        const BoxConstraints.tightForFinite(),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Math.tex(
                        "${multiVar}_{${_multiVarCounts[i]}}=",
                        textStyle: TextStyle(
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    isDense: true,
                  ),
                  validator: (input) {
                    if (input == null || input.isEmpty) {
                      return "Can't be empty";
                    }
                    return null;
                  },
                ),
              );
            });
          },
          icon: const Icon(Icons.add),
          label: const Text("Add a variable"),
        ),
      );
      _multiVarLastIndexes.add(_fields.length - 1);
      _multiVarCounts.add(1);
    }
  }

  void _showSnackBar({Widget? icon, required Widget text}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: (icon != null)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    icon,
                    const SizedBox(width: 8.0),
                    Expanded(child: text),
                  ],
                )
              : text,
          dismissDirection: DismissDirection.horizontal,
          shape: RoundedRectangleBorder(
            side: const BorderSide(),
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: const EdgeInsets.all(8.0),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class ModelsPage extends StatefulWidget {
  const ModelsPage({super.key});

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  final _formKey = GlobalKey<FormState>();
  Fraction? _result;
  Model _model = Model.allMarked;
  bool _hovering = false;
  List<Widget> _fields = [];
  List<TextEditingController> _controllers = [];
  bool _firstBuild = true;
  List<int> _multiVarLastIndexes = [];
  List<int> _multiVarCounts = [];

  @override
  Widget build(BuildContext context) {
    if (_firstBuild) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _firstBuild = false;
          _rebuildVariableFields();
        });
      });
    }
    return Center(
      child: SingleChildScrollView(
        child: SizedBox(
          width: min(MediaQuery.of(context).size.width, 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButton<Model>(
                        isExpanded: true,
                        value: _model,
                        items: Model.values
                            .map<DropdownMenuItem<Model>>(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _model = value!;
                            _rebuildVariableFields();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(_model.description),
                      const SizedBox(height: 16),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Math.tex(
                          _model.tex,
                          textStyle: TextStyle(
                            fontSize: 28,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final field in _fields) ...[
                        field,
                        const SizedBox(height: 16),
                      ],
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.decelerate,
                        width: _hovering ? 240 : 180,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                final vars = _controllers
                                    .map((e) => BigInt.parse(e.text))
                                    .toList();
                                try {
                                  _result = _model.calculate(vars);
                                } on ModelException catch (e) {
                                  _showSnackBar(
                                    icon: Icon(
                                      Icons.error_outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                    ),
                                    text: Text("${e.message}"),
                                  );
                                } catch (e) {
                                  _showSnackBar(
                                    icon: const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                                    text: Text("$e"),
                                  );
                                }
                              });
                            }
                          },
                          onHover: (hover) {
                            if (hover != _hovering) {
                              setState(() {
                                _hovering = hover;
                              });
                            }
                          },
                          child: const Text("Calculate"),
                        ),
                      ),
                      if (_result != null) ...[
                        const SizedBox(height: 24),
                        ResultWidget(
                          result: "$_result",
                          copyCallback: (copied) {
                            _showSnackBar(
                              icon: Icon(
                                Icons.copy,
                                color:
                                Theme.of(context).colorScheme.onSecondary,
                              ),
                              text: Text("Copied $copied"),
                            );
                          },
                        ),
                        // const SizedBox(height: 8),
                        ResultWidget(
                          result: "(${_result?.doubleValue()})",
                          resultToCopy: "${_result?.doubleValue()}",
                          prefix: "",
                          fontSize: 16,
                          style: const TextStyle(color: Colors.grey),
                          copyCallback: (copied) {
                            _showSnackBar(
                              icon: Icon(
                                Icons.copy,
                                color:
                                Theme.of(context).colorScheme.onSecondary,
                              ),
                              text: Text("Copied $copied"),
                            );
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _rebuildVariableFields() {
    _controllers = <TextEditingController>[];
    _multiVarLastIndexes = <int>[];
    _multiVarCounts = <int>[];

    _fields = _model.variables.map<Widget>(
      (e) {
        final controller = TextEditingController(text: "0");
        _controllers.add(controller);
        return NumberField(
          controller: controller,
          decoration: InputDecoration(
            prefixIconConstraints: const BoxConstraints.tightForFinite(),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Math.tex(
                "$e=",
                textStyle: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            isDense: true,
          ),
          validator: (input) {
            if (input == null || input.isEmpty) {
              return "Can't be empty";
            }
            return null;
          },
        );
      },
    ).toList();

    for (int i = 0; i < _model.multiVariables.length; i++) {
      final multiVar = _model.multiVariables[i];
      final controller = TextEditingController(text: "0");
      _controllers.add(controller);
      _fields.add(
        NumberField(
          controller: controller,
          decoration: InputDecoration(
            prefixIconConstraints: const BoxConstraints.tightForFinite(),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: Math.tex(
                "${multiVar}_1=",
                textStyle: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            isDense: true,
          ),
          validator: (input) {
            if (input == null || input.isEmpty) {
              return "Can't be empty";
            }
            return null;
          },
        ),
      );
      _fields.add(
        TextButton.icon(
          onPressed: () {
            setState(() {
              final indexToInsertField = _multiVarLastIndexes[i];
              _multiVarCounts[i]++;
              for (int j = i; j < _multiVarLastIndexes.length; j++) {
                _multiVarLastIndexes[j]++;
              }
              final controller = TextEditingController(text: "0");
              int indexToInsertController = _model.variables.length;
              for (int j = 0; j <= i; j++) {
                indexToInsertController += _multiVarCounts[j];
              }
              indexToInsertController--;
              _controllers.insert(indexToInsertController, controller);
              _fields.insert(
                indexToInsertField,
                NumberField(
                  controller: controller,
                  decoration: InputDecoration(
                    prefixIconConstraints:
                        const BoxConstraints.tightForFinite(),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: Math.tex(
                        "${multiVar}_{${_multiVarCounts[i]}}=",
                        textStyle: TextStyle(
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    isDense: true,
                  ),
                  validator: (input) {
                    if (input == null || input.isEmpty) {
                      return "Can't be empty";
                    }
                    return null;
                  },
                ),
              );
            });
          },
          icon: const Icon(Icons.add),
          label: const Text("Add a variable"),
        ),
      );
      _multiVarLastIndexes.add(_fields.length - 1);
      _multiVarCounts.add(1);
    }
  }

  void _showSnackBar({Widget? icon, required Widget text}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: (icon != null)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    icon,
                    const SizedBox(width: 8.0),
                    Expanded(child: text),
                  ],
                )
              : text,
          dismissDirection: DismissDirection.horizontal,
          shape: RoundedRectangleBorder(
            side: const BorderSide(),
            borderRadius: BorderRadius.circular(8.0),
          ),
          margin: const EdgeInsets.all(8.0),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          SwitchListTile.adaptive(
            title: const Text("Dark mode"),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (value) => App.switchThemeMode(context),
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
            "v1.0.1",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

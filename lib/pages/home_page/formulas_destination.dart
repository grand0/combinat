import 'dart:math';

import 'package:combinat/pages/common/result_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../math/formulas.dart';
import '../common/number_field.dart';

class FormulasDestination extends StatefulWidget {
  const FormulasDestination({super.key});

  @override
  State<FormulasDestination> createState() => _FormulasDestinationState();
}

class _FormulasDestinationState extends State<FormulasDestination> {
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

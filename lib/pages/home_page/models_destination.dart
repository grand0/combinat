import 'dart:math';

import 'package:combinat/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../math/fraction.dart';
import '../../math/models.dart';
import '../../prefs.dart';
import '../common/number_field.dart';
import '../common/result_widget.dart';

class ModelsDestination extends StatefulWidget {
  const ModelsDestination({super.key});

  @override
  State<ModelsDestination> createState() => _ModelsDestinationState();
}

class _ModelsDestinationState extends State<ModelsDestination> with AutomaticKeepAliveClientMixin<ModelsDestination> {
  @override
  bool get wantKeepAlive => true;

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
    super.build(context);

    if (_firstBuild) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _firstBuild = false;
          _rebuildVariableFields();
        });
      });
    }
    int? fractionDigits = prefs.getInt("fraction_digits");
    if (fractionDigits == -1) fractionDigits = null;
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
                                  if (_result != null) {
                                    HistoryStorage.addWithFraction(_model.tex, _result!);
                                  }
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
                        if (!_result!.isShortForm)
                          ResultWidget(
                            result: "${_result?.shortForm}",
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
                        ResultWidget(
                          result:
                              "(${fractionDigits == null ? _result?.doubleValue : _result?.doubleValue.toStringAsFixed(fractionDigits)})",
                          resultToCopy:
                              "${fractionDigits == null ? _result?.doubleValue : _result?.doubleValue.toStringAsFixed(fractionDigits)}",
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
